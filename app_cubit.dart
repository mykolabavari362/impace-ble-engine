// ignore: import_of_legacy_library_into_null_safe
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState());

  void setAutoModeOn(bool value) {
    emit(state.copyWith(autoModeOn: value));
  }
}
