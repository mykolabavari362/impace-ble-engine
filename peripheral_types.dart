part of 'peripheral_cubit.dart';

extension PeripheralPatternModeValues on PeripheralPatternMode {
  String get name {
    switch (index) {
      case 0:
        return 'OFF';
      case 1:
        return 'SMOOTH';
      case 2:
        return 'PULSE';
      case 3:
        return 'HEARTBEAT';
      case 4:
        return 'SHARP';
    }

    return '';
  }

  String? get iconFilepath {
    switch (index) {
      case 0:
        return null;
      case 1:
        return 'assets/icons/svg/patterns/smooth.svg';
      case 2:
        return 'assets/icons/svg/patterns/pulse.svg';
      case 3:
        return 'assets/icons/svg/patterns/heartbeat.svg';
      case 4:
        return 'assets/icons/svg/patterns/sharp.svg';
      default:
        return 'assets/icons/svg/patterns/smooth.svg';
    }
  }
}

enum PeripheralPatternMode { Off, Smooth, Pulse, HeartBeat, Sharp }

class PeripheralPatternIntensity {
  // intensity is a scale between 1-10
  late final int value;
  static const MIN_VALUE = 1;
  static const MAX_VALUE = 10;

  PeripheralPatternIntensity({
    required int value,
  }) {
    this.value = min(MAX_VALUE, max(MIN_VALUE, value));
  }

  static PeripheralPatternIntensity? fromParams(
      PeripheralPatternParams decodePatternParams) {
    log.warning('fromParams is not implemented for intensity!');
    return null;
  }

  PeripheralPatternParams toParams(PeripheralPatternMode mode) {
    return paramsFromModeAndIntensity(mode, this);
  }

  String get name {
    switch (value) {
      case 1:
      case 2:
      case 3:
        return 'LOW INTENSITY';
      case 4:
      case 5:
      case 6:
      case 7:
        return 'MEDIUM INTENSITY';
      case 8:
      case 9:
      case 10:
        return 'HIGH INTENSITY';
    }

    return '';
  }
}

enum PeripheralPatternParamsType { None, Simple, Double }

double lerp(double a, double b, double v) {
  final vClamped = v.clamp(0, 1);
  return a * (1 - vClamped) + b * vClamped;
}

@immutable
class PeripheralPatternParams {
  final double amplitude1,
      midpoint1,
      frequency1,
      amplitude2,
      midpoint2,
      frequency2;

  PeripheralPatternParams({
    required this.amplitude1,
    required this.midpoint1,
    required this.frequency1,
    required this.amplitude2,
    required this.midpoint2,
    required this.frequency2,
  });

  PeripheralPatternParams.single(double a, double m, double f)
      : amplitude1 = a,
        midpoint1 = m,
        frequency1 = f,
        amplitude2 = 8,
        midpoint2 = 10,
        frequency2 = 60;

  PeripheralPatternParams.double(
      double a1, double m1, double f1, double a2, double m2, double f2)
      : amplitude1 = a1,
        midpoint1 = m1,
        frequency1 = f1,
        amplitude2 = a2,
        midpoint2 = m2,
        frequency2 = f2;

  PeripheralPatternParams.normal()
      : amplitude1 = 8,
        midpoint1 = 10,
        frequency1 = 40,
        amplitude2 = 8,
        midpoint2 = 10,
        frequency2 = 60;

  @override
  String toString() =>
      '$amplitude1/$midpoint1/$frequency1, $amplitude2/$midpoint2/$frequency2';
}

@immutable
class PeripheralPattern {
  final PeripheralPatternMode mode;
  final PeripheralPatternIntensity intensity;

  PeripheralPattern({
    required this.mode,
    required this.intensity,
  });

  @override
  String toString() => '$mode: $intensity';

  PeripheralPattern copyWith({
    PeripheralPatternMode? mode,
    PeripheralPatternIntensity? intensity,
  }) {
    return PeripheralPattern(
        mode: mode ?? this.mode, intensity: intensity ?? this.intensity);
  }
}
