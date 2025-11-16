import 'package:flutter_bloc/flutter_bloc.dart';

/// Base class for theme states
sealed class ThemeState {}

/// Light theme state
class ThemeLight extends ThemeState {}

/// Dark theme state
class ThemeDark extends ThemeState {}

/// Cubit for managing application theme
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeLight());

  /// Returns true if the current theme is dark mode
  bool get isDark => state is ThemeDark;

  /// Sets the theme based on the isDark parameter
  void setDarkMode(bool isDark) {
    if (isDark) {
      emit(ThemeDark());
    } else {
      emit(ThemeLight());
    }
  }
}
