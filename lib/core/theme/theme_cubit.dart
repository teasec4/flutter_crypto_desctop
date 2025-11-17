import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Base class for theme states
sealed class ThemeState {}

/// Light theme state
class ThemeLight extends ThemeState {}

/// Dark theme state
class ThemeDark extends ThemeState {}

/// Cubit for managing application theme with persistence
class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'isDarkMode';
  late SharedPreferences _prefs;

  ThemeCubit() : super(ThemeLight());

  /// Initialize shared preferences and load saved theme
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final isDark = _prefs.getBool(_themeKey) ?? false;
    emit(isDark ? ThemeDark() : ThemeLight());
  }

  /// Returns true if the current theme is dark mode
  bool get isDark => state is ThemeDark;

  /// Sets the theme based on the isDark parameter and saves it
  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(_themeKey, isDark);
    if (isDark) {
      emit(ThemeDark());
    } else {
      emit(ThemeLight());
    }
  }

  /// Toggle the theme between dark and light
  Future<void> toggleTheme() async {
    await setDarkMode(!isDark);
  }
}
