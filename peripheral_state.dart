part of 'peripheral_cubit.dart';

abstract class PeripheralState {}

abstract class ConnectedPeripheral {
  String get name;
}

@immutable
class PeripheralStateDisconnected implements PeripheralState {
  PeripheralStateDisconnected();
}

@immutable
class PeripheralStateConnecting implements PeripheralState {
  PeripheralStateConnecting();
}

@immutable
class PeripheralStateConnected implements PeripheralState {
  final ConnectedPeripheral peripheral;
  final PeripheralPattern currentPattern;

  PeripheralStateConnected({
    required this.peripheral,
    required this.currentPattern,
  });

  PeripheralStateConnected.newlyConnected({
    required this.peripheral,
  }) : currentPattern = PeripheralPattern(
            mode: PeripheralPatternMode.Off,
            intensity: PeripheralPatternIntensity(value: 1));

  PeripheralStateConnected copyWith(
      {ConnectedPeripheral? peripheral, PeripheralPattern? currentPattern}) {
    return PeripheralStateConnected(
      peripheral: peripheral ?? this.peripheral,
      currentPattern: currentPattern ?? this.currentPattern,
    );
  }
}
