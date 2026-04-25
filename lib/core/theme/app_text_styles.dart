import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  static TextStyle display({Color color = AppColors.text1}) =>
      GoogleFonts.outfit(
        fontSize: 34, fontWeight: FontWeight.w800,
        letterSpacing: -1.4, color: color, height: 1.05,
      );

  static TextStyle heading({double size = 20, Color color = AppColors.text1}) =>
      GoogleFonts.outfit(
        fontSize: size, fontWeight: FontWeight.w700,
        letterSpacing: -0.5, color: color,
      );

  static TextStyle subheading({Color color = AppColors.text1}) =>
      GoogleFonts.outfit(
        fontSize: 15, fontWeight: FontWeight.w700, color: color,
      );

  static TextStyle body({double size = 14, Color color = AppColors.text2}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size, fontWeight: FontWeight.w400,
        color: color, height: 1.65,
      );

  static TextStyle bodyMedium({double size = 13, Color color = AppColors.text2}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size, fontWeight: FontWeight.w500, color: color,
      );

  static TextStyle label({Color color = AppColors.text3}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 9.5, fontWeight: FontWeight.w700,
        letterSpacing: 1.2, color: color,
      );

  static TextStyle caption({Color color = AppColors.text3}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 11, fontWeight: FontWeight.w400, color: color,
      );
}
