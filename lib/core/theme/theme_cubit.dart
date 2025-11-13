import 'package:flutter_bloc/flutter_bloc.dart';

sealed class ThemeState {}

class ThemeLight extends ThemeState {}

class ThemeDark extends ThemeState {}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeLight());

  bool get isDark => state is ThemeDark;

  void toggleTheme() {
    if (state is ThemeLight) {
      emit(ThemeDark());
    } else {
      emit(ThemeLight());
    }
  }

  void setDarkMode(bool isDark) {
    if (isDark) {
      emit(ThemeDark());
    } else {
      emit(ThemeLight());
    }
  }
}
