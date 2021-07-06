part of 'scanner_cubit.dart';

abstract class ScannerState {}

class ScannerStateIdle implements ScannerState {}

@immutable
class ScannerStateScanning implements ScannerState {
  final Map<String, ScannerResult> results;
  ScannerStateScanning({this.results = const {}});

  ScannerStateScanning copyWith({Map<String, ScannerResult>? results}) {
    return ScannerStateScanning(
      results: results ?? this.results,
    );
  }
}
