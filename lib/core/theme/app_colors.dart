import 'package:flutter/material.dart';

Color parseHexColor(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

abstract final class AppColors {
  // Backgrounds — deep navy-black layers
  static const Color background = Color(0xFF0B0D12);
  static const Color surface = Color(0xFF141720);
  static const Color surfaceElevated = Color(0xFF1C2030);
  static const Color border = Color(0xFF272B3E);

  // Primary — emerald green (growth/plant metaphor)
  static const Color primary = Color(0xFF22C55E);
  static const Color primaryDark = Color(0xFF16A34A);
  static const Color primaryContainer = Color(0xFF0D2318);
  static const Color onPrimary = Color(0xFF000000);

  // Secondary — soft indigo (AI features)
  static const Color secondary = Color(0xFF818CF8);
  static const Color secondaryContainer = Color(0xFF1A1C38);

  // Text hierarchy
  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8892A4);
  static const Color textMuted = Color(0xFF434C63);

  // Semantic
  static const Color debit = Color(0xFFF87171);
  static const Color credit = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
}

// Gradient background used in spending card and total-balance header
const kCardGradientStart = Color(0xFF0F2B1A);
const kCardGradientEnd = Color(0xFF0D1F2D);

// Common border radii
const kRadius8 = 8.0;
const kRadius10 = 10.0;
const kRadius12 = 12.0;
const kRadius14 = 14.0;
const kRadius16 = 16.0;
const kRadius20 = 20.0;

abstract final class AppLightColors {
  // Backgrounds — clean white layers
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);

  // Primary — darker green for light-bg contrast
  static const Color primary = Color(0xFF16A34A);
  static const Color primaryDark = Color(0xFF15803D);
  static const Color primaryContainer = Color(0xFFDCFCE7);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary — indigo
  static const Color secondary = Color(0xFF6366F1);
  static const Color secondaryContainer = Color(0xFFEEF2FF);

  // Text hierarchy
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Semantic
  static const Color debit = Color(0xFFDC2626);
  static const Color credit = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
}
