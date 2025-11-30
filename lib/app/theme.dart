import 'package:flutter/material.dart';

/// Selona color palette - Dark theme only
class SelonaColors {
  SelonaColors._();

  // Primary backgrounds
  static const Color backgroundPrimary = Color(0xFF0D1117);
  static const Color backgroundSecondary = Color(0xFF161B22);
  static const Color backgroundTertiary = Color(0xFF21262D);
  static const Color surface = Color(0xFF30363D);

  // Accent colors
  static const Color primaryAccent = Color(0xFF7C8DB5);
  static const Color secondaryAccent = Color(0xFF9BA8C7);
  static const Color moonGlow = Color(0xFFC9D1D9);

  // Text colors
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF6E7681);

  // Semantic colors
  static const Color success = Color(0xFF3FB950);
  static const Color warning = Color(0xFFD29922);
  static const Color error = Color(0xFFF85149);
  static const Color info = Color(0xFF58A6FF);

  // Border
  static const Color border = Color(0xFF30363D);
}

/// Selona theme configuration
class SelonaTheme {
  SelonaTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SelonaColors.backgroundPrimary,
      colorScheme: const ColorScheme.dark(
        surface: SelonaColors.backgroundPrimary,
        primary: SelonaColors.primaryAccent,
        secondary: SelonaColors.secondaryAccent,
        error: SelonaColors.error,
        onPrimary: SelonaColors.textPrimary,
        onSecondary: SelonaColors.textPrimary,
        onSurface: SelonaColors.textPrimary,
        onError: SelonaColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SelonaColors.backgroundPrimary,
        foregroundColor: SelonaColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: SelonaColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: SelonaColors.textPrimary,
        ),
      ),
      cardTheme: CardTheme(
        color: SelonaColors.backgroundSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SelonaColors.primaryAccent,
          foregroundColor: SelonaColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SelonaColors.primaryAccent,
          side: const BorderSide(color: SelonaColors.primaryAccent),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SelonaColors.primaryAccent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SelonaColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SelonaColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SelonaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SelonaColors.primaryAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SelonaColors.error),
        ),
        hintStyle: const TextStyle(color: SelonaColors.textMuted),
        labelStyle: const TextStyle(color: SelonaColors.textSecondary),
      ),
      iconTheme: const IconThemeData(
        color: SelonaColors.textPrimary,
        size: 24,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: SelonaColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: SelonaColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: SelonaColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: SelonaColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: SelonaColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: SelonaColors.textSecondary,
        ),
        labelMedium: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: SelonaColors.textSecondary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: SelonaColors.border,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SelonaColors.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: SelonaColors.backgroundSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: SelonaColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: SelonaColors.textSecondary,
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: SelonaColors.primaryAccent,
        inactiveTrackColor: SelonaColors.surface,
        thumbColor: SelonaColors.moonGlow,
        overlayColor: Color(0x297C8DB5),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return SelonaColors.moonGlow;
          }
          return SelonaColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return SelonaColors.primaryAccent;
          }
          return SelonaColors.surface;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: SelonaColors.primaryAccent,
        linearTrackColor: SelonaColors.surface,
        circularTrackColor: SelonaColors.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SelonaColors.backgroundTertiary,
        contentTextStyle: const TextStyle(color: SelonaColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
