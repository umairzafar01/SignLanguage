import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
//  Dark theme tokens  (original, preserved)
// ─────────────────────────────────────────────────────────────
abstract class AppColors {
  // ── Backgrounds
  static const bg       = Color(0xFF070B12);
  static const bg2      = Color(0xFF0C1220);
  static const surface  = Color(0xFF111827);
  static const surface2 = Color(0xFF1A2336);
  static const surface3 = Color(0xFF222E42);

  // ── Module Accents
  static const cyan     = Color(0xFF22D3EE); // Sign → Text
  static const cyanDim  = Color(0xFF0891B2);
  static const amber    = Color(0xFFF59E0B); // Text → Speech
  static const amberDim = Color(0xFFB45309);
  static const violet   = Color(0xFF8B5CF6); // Speech → Text
  static const rose     = Color(0xFFF43F5E); // Text → Sign
  static const emerald  = Color(0xFF10B981); // Online/success

  // ── Text
  static const text1    = Color(0xFFF1F5F9);
  static const text2    = Color(0xFF94A3B8);
  static const text3    = Color(0xFF475569);
  static const text4    = Color(0xFF2A3A52);

  // ── Borders
  static const border   = Color(0x12FFFFFF); // 7% white
  static const border2  = Color(0x0AFFFFFF); // 4% white
}

// ─────────────────────────────────────────────────────────────
//  Light theme tokens  (new)
// ─────────────────────────────────────────────────────────────
abstract class LightColors {
  // ── Backgrounds
  static const bg       = Color(0xFFF7F9FC); // off-white scaffold
  static const surface  = Color(0xFFFFFFFF); // card / field surface
  static const surface2 = Color(0xFFF0F4F8); // subtle variant

  // ── Primary (calm blue)
  static const primary      = Color(0xFF4A90E2);
  static const primaryLight = Color(0xFFEBF4FF);

  // ── Module Accents — slightly muted for light bg
  static const cyan     = Color(0xFF0891B2); // Sign → Text
  static const cyanBg   = Color(0xFFE0F7FA);
  static const amber    = Color(0xFFF59E0B); // Streak / speech
  static const amberBg  = Color(0xFFFFF8E1);
  static const violet   = Color(0xFF7C3AED); // AI / Speech
  static const violetBg = Color(0xFFF3EEFF);
  static const rose     = Color(0xFFEF4444); // Text → Sign / errors
  static const roseBg   = Color(0xFFFEF2F2);
  static const emerald  = Color(0xFF10B981); // Online / success
  static const emeraldBg= Color(0xFFECFDF5);

  // ── Text
  static const text1    = Color(0xFF1A202C); // headings
  static const text2    = Color(0xFF4A5568); // body
  static const text3    = Color(0xFF718096); // captions / muted
  static const text4    = Color(0xFFA0AEC0); // placeholder

  // ── Borders
  static const border   = Color(0x14000000); // 8% black
  static const border2  = Color(0x0A000000); // 4% black

  // ── Shadow (used in BoxShadow)
  static const shadow   = Color(0x0D000000); // soft card shadow
}
