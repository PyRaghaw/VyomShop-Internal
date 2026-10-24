import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  // Neo-Brutalism Style Tokens
  static const double borderWidth = 2.0;
  static const double borderRadius = 16.0;
  static const Offset shadowOffset = Offset(3.5, 3.5);

  static TextStyle get headingStyle => GoogleFonts.dmSerifDisplay(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: AppColors.foreground,
      );

  static List<BoxShadow> get neoShadow => [
        const BoxShadow(
          color: AppColors.foreground,
          offset: shadowOffset,
          blurRadius: 0,
        ),
      ];

  static List<BoxShadow> get neoShadowSmall => [
        const BoxShadow(
          color: AppColors.foreground,
          offset: Offset(2.0, 2.0),
          blurRadius: 0,
        ),
      ];

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.manropeTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.background,
        onSurface: AppColors.foreground,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
        ),
        displayMedium: GoogleFonts.dmSerifDisplay(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
        ),
        titleLarge: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.foreground,
        ),
        titleMedium: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.foreground,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.mutedText,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.foreground),
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          fontSize: 22,
          color: AppColors.foreground,
        ),
      ),
    );
  }
}
