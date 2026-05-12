import 'package:finly/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'app_theme_builder.dart';
part 'app_theme_component_themes.dart';
part 'app_theme_color_schemes.dart';
part 'app_theme_misc_themes.dart';

class _ThemeTokens {
  const _ThemeTokens({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.primary,
    required this.primaryContainer,
    required this.onPrimary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.debit,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color primary;
  final Color primaryContainer;
  final Color onPrimary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color debit;
}

final class AppTheme {
  AppTheme._();

  static const _lightTokens = _ThemeTokens(
    background: AppLightColors.background,
    surface: AppLightColors.surface,
    surfaceElevated: AppLightColors.surfaceElevated,
    border: AppLightColors.border,
    primary: AppLightColors.primary,
    primaryContainer: AppLightColors.primaryContainer,
    onPrimary: AppLightColors.onPrimary,
    textPrimary: AppLightColors.textPrimary,
    textSecondary: AppLightColors.textSecondary,
    textMuted: AppLightColors.textMuted,
    debit: AppLightColors.debit,
  );

  static const _darkTokens = _ThemeTokens(
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceElevated: AppColors.surfaceElevated,
    border: AppColors.border,
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryContainer,
    onPrimary: AppColors.onPrimary,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
    debit: AppColors.debit,
  );

  static ThemeData get light => _build(
    colorScheme: _lightScheme,
    tokens: _lightTokens,
    statusIconBrightness: Brightness.dark,
  );

  static ThemeData get dark => _build(
    colorScheme: _darkScheme,
    tokens: _darkTokens,
    statusIconBrightness: Brightness.light,
  );

  static ThemeData _build({
    required ColorScheme colorScheme,
    required _ThemeTokens tokens,
    required Brightness statusIconBrightness,
  }) {
    return _buildThemeData(
      colorScheme: colorScheme,
      tokens: tokens,
      statusIconBrightness: statusIconBrightness,
    );
  }
}
