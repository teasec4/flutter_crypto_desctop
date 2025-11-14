import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const primaryColor = Color(0xFF6366F1);
  static const secondaryColor = Color(0xFF8B5CF6);
  static const surfaceColor = Color(0xFFF8FAFC);

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        outline: Color(0xFFE2E8F0),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFFF5F5F5),
        foregroundColor: primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
       ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: const Color(0xFFF5F5F5),
        selectedIconTheme: const IconThemeData(
          color: primaryColor,
          size: 28,
        ),
        unselectedIconTheme: IconThemeData(
          color: Colors.grey.shade500,
          size: 24,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withValues(alpha: 0.3);
          }
          return Colors.grey.shade300;
        }),
      ),
      listTileTheme: const ListTileThemeData(
        selectedColor: Colors.white,
        selectedTileColor: Color(0xFF6366F1),
        iconColor: Colors.black87,
        textColor: Colors.black87,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: const Color(0xFFF5F5F5),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade800,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Color(0xFF1E293B),
        outline: Color(0xFF475569),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: primaryColor,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: const Color(0xFF1E293B),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 28,
        ),
        unselectedIconTheme: IconThemeData(
          color: Colors.grey.shade600,
          size: 24,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: primaryColor,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.grey.shade700;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withValues(alpha: 0.3);
          }
          return Colors.grey.shade700;
        }),
      ),
      listTileTheme: const ListTileThemeData(
        selectedColor: Colors.white,
        selectedTileColor: Color(0xFF6366F1),
        iconColor: Colors.white70,
        textColor: Colors.white70,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: const Color(0xFF334155),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade200,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade300,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}
