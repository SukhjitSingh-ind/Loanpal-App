import 'package:flutter/material.dart';

class LoanPalTheme {
  static const Color primaryNavy = Color(0xFF173F73);
  static const Color primaryDark = Color(0xFF002956);
  static const Color primaryLight = Color(0xFF8AACE6);
  // INFO: secondaryTeal overrides the design system's #006B58 with a slightly
  // lighter teal (#16866F) to maintain WCAG AA contrast on white surfaces.
  static const Color secondaryTeal = Color(0xFF16866F);

  static const Color burdenLow = Color(0xFF168A5B);
  static const Color burdenModerate = Color(0xFFF4C430);
  static const Color burdenHigh = Color(0xFFF28C28);
  static const Color burdenHeavy = Color(0xFFD64545);

  static const Color background = Color(0xFFF7F9FC);
  static const Color surfaceCard = Colors.white;
  static const Color textMain = Color(0xFF191C1E);
  static const Color textSecondary = Color(0xFF43474F);
  static const Color outlineColor = Color(0xFFC3C6D1);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNavy,
        primary: primaryNavy,
        secondary: secondaryTeal,
        surface: surfaceCard,
        error: burdenHeavy,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
          color: textMain,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
          color: textMain,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: textMain,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textMain,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textMain,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.05,
          color: textSecondary,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: secondaryTeal,
        inactiveTrackColor: outlineColor.withValues(alpha: 0.5),
        thumbColor: secondaryTeal,
        trackHeight: 6.0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: outlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primaryNavy, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        floatingLabelStyle: const TextStyle(color: primaryNavy),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 1,
        shadowColor: primaryNavy.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    );
  }
}
