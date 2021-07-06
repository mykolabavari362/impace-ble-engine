import 'dart:io';

import 'package:app/cubit/ble/constants.dart';
import 'package:app/cubit/scanner_cubit.dart';
import 'package:app/utils/extensions.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:logging/logging.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:permission_handler/permission_handler.dart';

import 'scanner_state_ble.dart';

final log = Logger('ScannerCubitBle');

// BLE implementation of ScannerCubit
class ScannerCubitBle extends ScannerCubit {
  ScannerCubitBle() : super(ScannerStateIdle()) {
    var bleManager = BleManager();
    bleManager.createClient().then((value) => startScan());
  }

  @override
  Future<bool> startScan() async {
    emit(ScannerStateScanning());
    var bleManager = BleManager();
    if (Platform.isAndroid) {
      if (!await Permission.locationWhenInUse.isGranted) {
        if (await Permission.locationWhenInUse.request() !=
            PermissionStatus.granted) {
          emit(ScannerStateIdle());
          return false;
        }
      }
    }

    try {
      await bleManager.stopPeripheralScan();
      bleManager.startPeripheralScan(uuids: [
        IMPACT_SERVICE_UUID,
      ], scanMode: ScanMode.balanced).listen((scanResult) {
        log.info('BLE scan result: $scanResult');

        final scannerStateScanning = state.castOrNull<ScannerStateScanning>();
        if (scannerStateScanning == null) {
          return;
        }

        emit(scannerStateScanning.copyWith(results: {
          ...scannerStateScanning.results,
          scanResult.peripheral.identifier: ScannerResultBle(scanResult)
        }));
      }, onDone: () {
        log.info('BLE scanning done');
        emit(ScannerStateIdle());
      }, onError: (dynamic e) {
        log.warning('BLE scanning error $e');
        emit(ScannerStateIdle());
      }, cancelOnError: true);
    } catch (e) {
      log.warning('Failed to start BLE scanning $e');
      emit(ScannerStateIdle());
      return false;
    }

    return true;
  }

  @override
  Future<void> stopScan() async {
    emit(ScannerStateIdle());
    var bleManager = BleManager();
    await bleManager.stopPeripheralScan();
  }
}
