import 'package:app/cubit/scanner_cubit.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

class ScannerResultBle extends ScannerResult {
  ScanResult bleLibScanResult;
  ScannerResultBle(this.bleLibScanResult);

  @override
  String get name => bleLibScanResult.peripheral.name;
}
