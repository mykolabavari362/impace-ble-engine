import 'package:app/cubit/scanner_cubit.dart';

class ScannerResultTest extends ScannerResult {
  final String _name;
  ScannerResultTest(this._name);

  @override
  String get name => _name;
}
