part of 'app_cubit.dart';

@immutable
class AppState {
  final bool autoModeOn;

  AppState({this.autoModeOn = true});

  AppState copyWith({bool? autoModeOn}) {
    return AppState(autoModeOn: autoModeOn ?? this.autoModeOn);
  }
}
