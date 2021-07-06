import 'package:app/cubit/peripheral_cubit.dart';
import 'package:app/cubit/scanner_cubit.dart';
import 'package:app/utils/extensions.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:logging/logging.dart';

const interval = Duration(milliseconds: 10);
const maxDataInterval = Duration(seconds: 2);

final log = Logger('PeripheralCubitTest');

class PeripheralCubitTest extends PeripheralCubit {
  PeripheralCubitTest() : super(PeripheralStateDisconnected());

  @override
  Future<void> disconnect() async {
    emit(PeripheralStateDisconnected());
  }

  @override
  Future<bool> connect(ScannerResult scannerPeripheral) async {
    emit(PeripheralStateConnecting());

    emit(PeripheralStateConnected.newlyConnected(
      peripheral: ConnectedPeripheralTest(scannerPeripheral.name),
    ));

    return true;
  }

  @override
  Future<bool> commitPatternMode(
    ConnectedPeripheral connectedPeripheral,
    PeripheralPatternMode mode,
  ) async {
    log.info('Committing pattern mode: $mode');
    return true;
  }

  @override
  Future<bool> commitPatternParams(
    ConnectedPeripheral connectedPeripheral,
    PeripheralPatternParams params,
  ) async {
    log.info('Committing pattern params: $params');
    return true;
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

    log.fine(
        'Reading from device: [updatePatternMode: $updatePatternMode, updatePatternParams: $updatePatternParams]');
    return true;
  }
}

class ConnectedPeripheralTest extends ConnectedPeripheral {
  final String _name;
  ConnectedPeripheralTest(this._name);

  @override
  String get name => _name;
}
