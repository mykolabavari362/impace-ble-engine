import 'package:app/cubit/scanner_cubit.dart';
import 'package:app/cubit/test/scanner_state_test.dart';

// Test implementation of ScannerCubit
class ScannerCubitTest extends ScannerCubit {
  ScannerCubitTest() : super(ScannerStateIdle()) {
    startScan();
  }

  @override
  Future<void> startScan() async {
    emit(ScannerStateScanning(results: {}));
    emit(ScannerStateScanning(
        results: {'Dummy': ScannerResultTest('Dummy device')}));
  }

  @override
  Future<void> stopScan() async {
    emit(ScannerStateIdle());
  }
}
