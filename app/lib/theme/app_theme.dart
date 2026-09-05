import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brand,
        primary: AppColors.brand,
        surface: AppColors.surface,
        error: AppColors.brand,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: GoogleFonts.archivo().fontFamily,
    );

    return base.copyWith(
      textTheme: GoogleFonts.archivoTextTheme(base.textTheme).apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.chrome,
        foregroundColor: AppColors.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: AppColors.hover,
      dividerColor: AppColors.divider,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.chrome,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

/// Common text weights used throughout the prototype (Archivo 600/800).
extension AppTextStyles on BuildContext {
  TextStyle get heading =>
      const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.02, color: AppColors.ink);
  TextStyle get label => TextStyle(
        fontSize: 11,
        letterSpacing: 0.09,
        fontWeight: FontWeight.w600,
        color: AppColors.inkAlpha(0.55),
      );
}
