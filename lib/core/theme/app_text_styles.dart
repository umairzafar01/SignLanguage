import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// ─────────────────────────────────────────────────────────────
//  AppTextStyles — theme-aware helpers
//
//  Each method accepts an optional [Color]. When null, the color
//  is resolved from the nearest Theme's ColorScheme at call-site
//  using the static `resolve` helper.
// ─────────────────────────────────────────────────────────────

abstract class AppTextStyles {
  // ── Resolve a color against the current theme (light/dark safe)
  static Color _t1(BuildContext? ctx, Color? override) {
    if (override != null) return override;
    if (ctx != null) return Theme.of(ctx).colorScheme.onSurface;
    return AppColors.text1;
  }

  static Color _t2(BuildContext? ctx, Color? override) {
    if (override != null) return override;
    if (ctx != null) {
      final cs = Theme.of(ctx).colorScheme;
      return cs.brightness == Brightness.light
          ? const Color(0xFF4A5568)
          : AppColors.text2;
    }
    return AppColors.text2;
  }

  static Color _t3(BuildContext? ctx, Color? override) {
    if (override != null) return override;
    if (ctx != null) {
      final cs = Theme.of(ctx).colorScheme;
      return cs.brightness == Brightness.light
          ? const Color(0xFF718096)
          : AppColors.text3;
    }
    return AppColors.text3;
  }

  // ── Styles (context-free versions kept for backward compat) ──

  static TextStyle display({Color? color}) => GoogleFonts.outfit(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.4,
        color: color ?? AppColors.text1,
        height: 1.05,
      );

  static TextStyle heading({double size = 20, Color? color}) =>
      GoogleFonts.outfit(
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color ?? AppColors.text1,
      );

  static TextStyle subheading({Color? color}) => GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.text1,
      );

  static TextStyle body({double size = 14, Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.text2,
        height: 1.65,
      );

  static TextStyle bodyMedium({double size = 13, Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.text2,
      );

  static TextStyle label({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: color ?? AppColors.text3,
      );

  static TextStyle caption({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.text3,
      );

  // ── Theme-aware versions (recommended for new code) ──

  static TextStyle displayOf(BuildContext ctx, {Color? color}) =>
      GoogleFonts.outfit(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.4,
        color: _t1(ctx, color),
        height: 1.05,
      );

  static TextStyle headingOf(BuildContext ctx,
          {double size = 20, Color? color}) =>
      GoogleFonts.outfit(
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: _t1(ctx, color),
      );

  static TextStyle bodyOf(BuildContext ctx,
          {double size = 14, Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: _t2(ctx, color),
        height: 1.65,
      );

  static TextStyle bodyMediumOf(BuildContext ctx,
          {double size = 13, Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: _t2(ctx, color),
      );

  static TextStyle labelOf(BuildContext ctx, {Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: _t3(ctx, color),
      );

  static TextStyle captionOf(BuildContext ctx, {Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: _t3(ctx, color),
      );
}
