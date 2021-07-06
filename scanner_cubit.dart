// ignore: import_of_legacy_library_into_null_safe
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'scanner_state.dart';
part 'scanner_types.dart';

abstract class ScannerCubit extends Cubit<ScannerState> {
  ScannerCubit(ScannerState state) : super(state);

  Future<void> startScan();
  Future<void> stopScan();
}
