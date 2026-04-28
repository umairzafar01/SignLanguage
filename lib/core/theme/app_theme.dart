import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ─────────────────────────────────────────
  //  DARK THEME (original, preserved)
  // ─────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.cyan,
      secondary: AppColors.violet,
      surface: AppColors.surface,
      error: AppColors.rose,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.dark().textTheme,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
    dividerColor: AppColors.border,
  );

  // ─────────────────────────────────────────
  //  LIGHT THEME (redesigned)
  // ─────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: LightColors.bg,

    colorScheme: const ColorScheme.light(
      primary: LightColors.primary,
      onPrimary: Colors.white,
      secondary: LightColors.violet,
      onSecondary: Colors.white,
      surface: LightColors.surface,
      onSurface: LightColors.text1,
      error: LightColors.rose,
      onError: Colors.white,
      outline: LightColors.border,
      outlineVariant: LightColors.border2,
      surfaceContainerHighest: LightColors.surface2,
    ),

    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.light().textTheme.apply(
        bodyColor: LightColors.text2,
        displayColor: LightColors.text1,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: LightColors.bg,
      foregroundColor: LightColors.text1,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: LightColors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),

    cardTheme: CardThemeData(
      color: LightColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: LightColors.border),
      ),
      margin: EdgeInsets.zero,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LightColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LightColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LightColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LightColors.primary, width: 1.5),
      ),
      hintStyle: GoogleFonts.plusJakartaSans(
        color: LightColors.text4,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    dividerColor: LightColors.border,
    dividerTheme: const DividerThemeData(
      color: LightColors.border,
      thickness: 1,
      space: 1,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: LightColors.surface,
      selectedItemColor: LightColors.primary,
      unselectedItemColor: LightColors.text3,
      elevation: 0,
    ),
  );
}
