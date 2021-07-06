import 'dart:typed_data';

import 'package:app/cubit/ble/constants.dart';
import 'package:app/cubit/peripheral_cubit.dart';
import 'package:app/cubit/scanner_cubit.dart';
import 'package:app/utils/extensions.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:logging/logging.dart';

import 'scanner_state_ble.dart';

final log = Logger('PeripheralCubitBle');

Uint8List encodePatternParams(PeripheralPatternParams params) {
  return _encodeListOfFloats(
    Float32List.fromList(
      [
        params.amplitude1,
        params.midpoint1,
        params.frequency1,
        params.amplitude2,
        params.midpoint2,
        params.frequency2,
      ],
    ),
  );
}

Float32List _decodeToListOfFloats(Uint8List data) {
  final byteData = ByteData.sublistView(data);

  var floats = Float32List(data.length ~/ 4);
  for (var i = 0; i < floats.length; i++) {
    floats[i] = byteData.getFloat32(i * 4, Endian.little);
  }

  return floats;
}

PeripheralPatternParams decodePatternParams(Uint8List data) {
  final floats = _decodeToListOfFloats(data);
  return PeripheralPatternParams(
      amplitude1: floats[0],
      midpoint1: floats[1],
      frequency1: floats[2],
      amplitude2: floats[3],
      midpoint2: floats[4],
      frequency2: floats[5]);
}

PeripheralPatternMode decodePatternMode(Uint8List data) {
  return PeripheralPatternMode.values[data[0]];
}

Uint8List encodePatternMode(PeripheralPatternMode mode) =>
    Uint8List.fromList([mode.index]);

Uint8List _encodeListOfFloats(Float32List floats) {
  var byteData = ByteData(floats.length * 4);
  floats.asMap().forEach((i, singleFloat) {
    byteData.setFloat32(i * 4, singleFloat, Endian.little);
  });

  return Uint8List.sublistView(byteData);
}

const interval = Duration(milliseconds: 10);
const maxDataInterval = Duration(seconds: 2);

class PeripheralCubitBle extends PeripheralCubit {
  double divisor = 0;
  List<double> values = [];

  PeripheralCubitBle() : super(PeripheralStateDisconnected());

  @override
  Future<void> disconnect() async {
    var connectedPeripheral = state
        .castOrNull<PeripheralStateConnected>()
        ?.peripheral
        .castOrNull<ConnectedPeripheralBle>();

    if (connectedPeripheral == null) {
      return;
    }

    await disconnectBlePeripheral(connectedPeripheral);
    emit(PeripheralStateDisconnected());
  }

  @override
  Future<bool> connect(ScannerResult scannerResult) async {
    var scannerResultBle = scannerResult.castOrNull<ScannerResultBle>();
    if (scannerResultBle == null) {
      return false;
    }

    var currentPeripheral = state
        .castOrNull<PeripheralStateConnected>()
        ?.peripheral
        .castOrNull<ConnectedPeripheralBle>()
        ?.bleLibPeripheral;

    // Start connecting
    emit(PeripheralStateConnecting());

    if (!await connectBlePeripheral(
        scannerResultBle.bleLibScanResult.peripheral, currentPeripheral)) {
      emit(PeripheralStateDisconnected());
    }

    return await updateDataFromDevice(
        updatePatternMode: true, updatePatternParams: true);
  }

  Future disconnectBlePeripheral(
    ConnectedPeripheralBle connectedPeripheral,
  ) async {
    await connectedPeripheral.bleLibPeripheral.disconnectOrCancelConnection();
  }

  Future<bool> connectBlePeripheral(
      Peripheral peripheral, Peripheral? currentPeripheral) async {
    // Check current state
    if (currentPeripheral != null) {
      // Already connected to this peripheral
      if (peripheral.identifier == currentPeripheral.identifier) {
        return true;
      }

      await currentPeripheral.disconnectOrCancelConnection();
    }

    // Try connecting
    try {
      await peripheral.connect(timeout: Duration(seconds: 5));
    } catch (_) {
      log.warning('Failed to connect');
      return false;
    }

    peripheral.observeConnectionState().listen((connectionState) {
      if (connectionState == PeripheralConnectionState.disconnected) {
        emit(PeripheralStateDisconnected());
      }
    });

    await peripheral.discoverAllServicesAndCharacteristics();

    emit(PeripheralStateConnected.newlyConnected(
        peripheral: ConnectedPeripheralBle(bleLibPeripheral: peripheral)));

    return true;
  }

  @override
  Future<bool> commitPatternMode(
    ConnectedPeripheral connectedPeripheral,
    PeripheralPatternMode mode,
  ) async {
    var blePeripheral = connectedPeripheral
        .castOrNull<ConnectedPeripheralBle>()
        ?.bleLibPeripheral;

    if (blePeripheral == null) {
      return false;
    }

    try {
      await blePeripheral.writeCharacteristic(
        IMPACT_SERVICE_UUID,
        PATTERN_MODE_UUID,
        encodePatternMode(mode),
        true,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> commitPatternParams(
    ConnectedPeripheral connectedPeripheral,
    PeripheralPatternParams params,
  ) async {
    var blePeripheral = connectedPeripheral
        .castOrNull<ConnectedPeripheralBle>()
        ?.bleLibPeripheral;

    if (blePeripheral == null) {
      return false;
    }

    try {
      await blePeripheral.writeCharacteristic(
        IMPACT_SERVICE_UUID,
        PATTERN_PARAMS_UUID,
        encodePatternParams(params),
        true,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> updateDataFromDevice({
    bool updatePatternMode = false,
    bool updatePatternParams = false,
  }) async {
    var connectedState = state.castOrNull<PeripheralStateConnected>();

    if (connectedState == null) {
      return false;
    }

    var blePeripheral = connectedState.peripheral
        .castOrNull<ConnectedPeripheralBle>()
        ?.bleLibPeripheral;

    if (blePeripheral == null) {
      return false;
    }

    try {
      CharacteristicWithValue charWithValue;

      PeripheralPatternMode? mode;
      if (updatePatternMode) {
        charWithValue = await blePeripheral.readCharacteristic(
          IMPACT_SERVICE_UUID,
          PATTERN_MODE_UUID,
        );

        mode = decodePatternMode(charWithValue.value);
      }

      PeripheralPatternIntensity? intensity;
      if (updatePatternParams) {
        charWithValue = await blePeripheral.readCharacteristic(
          IMPACT_SERVICE_UUID,
          PATTERN_PARAMS_UUID,
        );

        intensity = PeripheralPatternIntensity.fromParams(
            decodePatternParams(charWithValue.value));
      }

      emit(
        connectedState.copyWith(
          currentPattern: connectedState.currentPattern
              .copyWith(mode: mode, intensity: intensity),
        ),
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}

class ConnectedPeripheralBle extends ConnectedPeripheral {
  final Peripheral bleLibPeripheral;

  ConnectedPeripheralBle({
    required this.bleLibPeripheral,
  });

  @override
  String get name => bleLibPeripheral.name;
}
