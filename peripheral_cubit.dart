import 'dart:math';

import 'package:app/cubit/scanner_cubit.dart';
import 'package:app/data/intensities.dart';
import 'package:app/utils/extensions.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

part 'peripheral_state.dart';
part 'peripheral_types.dart';

final log = Logger('PeripheralCubit');

const interval = Duration(milliseconds: 10);
const maxDataInterval = Duration(seconds: 2);

abstract class PeripheralCubit extends Cubit<PeripheralState> {
  PeripheralCubit(PeripheralState state) : super(state);

  Future<void> disconnect();
  Future<bool> connect(ScannerResult scannerResult);

  Future<bool> commitPatternMode(
      ConnectedPeripheral connectedPeripheral, PeripheralPatternMode mode);
  Future<bool> commitPatternParams(
      ConnectedPeripheral connectedPeripheral, PeripheralPatternParams params);
  Future<bool> updateDataFromDevice(
      {bool updatePatternMode, bool updatePatternParams});

  Future<bool> updatePatternMode(PeripheralPatternMode mode) async {
    var peripheralStateConnected = state.castOrNull<PeripheralStateConnected>();
    if (peripheralStateConnected == null) {
      return false;
    }

    var newState = peripheralStateConnected.copyWith(
        currentPattern:
            peripheralStateConnected.currentPattern.copyWith(mode: mode));

    if (!await commitPatternMode(
        peripheralStateConnected.peripheral, newState.currentPattern.mode)) {
      return false;
    }

    if (!await commitPatternParams(
        peripheralStateConnected.peripheral,
        newState.currentPattern.intensity
            .toParams(newState.currentPattern.mode))) {
      return false;
    }

    emit(newState);

    return await updateDataFromDevice(
        updatePatternMode: true, updatePatternParams: true);
  }

  Future<bool> updatePatternIntensity(
      PeripheralPatternIntensity intensity) async {
    var peripheralStateConnected = state.castOrNull<PeripheralStateConnected>();
    if (peripheralStateConnected == null) {
      return false;
    }

    var newState = peripheralStateConnected.copyWith(
        currentPattern: peripheralStateConnected.currentPattern
            .copyWith(intensity: intensity));

    if (!await commitPatternParams(
        peripheralStateConnected.peripheral,
        newState.currentPattern.intensity
            .toParams(peripheralStateConnected.currentPattern.mode))) {
      return false;
    }

    emit(newState);

    return await updateDataFromDevice(updatePatternParams: true);
  }
}
