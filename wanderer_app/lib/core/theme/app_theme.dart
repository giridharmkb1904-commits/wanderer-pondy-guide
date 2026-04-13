import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: WandererColors.background,
      colorScheme: const ColorScheme.dark(
        primary: WandererColors.primary,
        secondary: WandererColors.secondary,
        surface: WandererColors.surface,
        error: WandererColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: WandererColors.textPrimary,
        displayColor: WandererColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WandererColors.surfaceLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        hintStyle: const TextStyle(color: WandererColors.textMuted),
      ),
    );
  }
}
