import 'package:finly/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        cs: _lightScheme,
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
        statusIconBrightness: Brightness.dark,
      );

  static ThemeData get dark => _build(
        cs: _darkScheme,
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
        statusIconBrightness: Brightness.light,
      );

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppLightColors.primary,
    onPrimary: AppLightColors.onPrimary,
    primaryContainer: AppLightColors.primaryContainer,
    onPrimaryContainer: AppLightColors.primaryDark,
    secondary: AppLightColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: AppLightColors.secondaryContainer,
    onSecondaryContainer: AppLightColors.secondary,
    surface: AppLightColors.surface,
    onSurface: AppLightColors.textPrimary,
    surfaceContainerHighest: AppLightColors.surfaceElevated,
    onSurfaceVariant: AppLightColors.textSecondary,
    outline: AppLightColors.border,
    outlineVariant: AppLightColors.border,
    error: AppLightColors.debit,
    onError: Colors.white,
    scrim: Colors.black54,
    inverseSurface: AppLightColors.textPrimary,
    onInverseSurface: AppLightColors.background,
    inversePrimary: AppLightColors.primaryDark,
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.primary,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.secondary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceElevated,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
    error: AppColors.debit,
    onError: Colors.white,
    scrim: Colors.black87,
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.background,
    inversePrimary: AppColors.primaryDark,
  );

  static ThemeData _build({
    required ColorScheme cs,
    required Color background,
    required Color surface,
    required Color surfaceElevated,
    required Color border,
    required Color primary,
    required Color primaryContainer,
    required Color onPrimary,
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
    required Color debit,
    required Brightness statusIconBrightness,
  }) {
    const r12 = Radius.circular(kRadius12);
    const r16 = Radius.circular(kRadius16);
    final borderSide = BorderSide(color: border);

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: background,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadius16),
          side: BorderSide(color: border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: statusIconBrightness,
          systemNavigationBarColor: surface,
        ),
        iconTheme: IconThemeData(color: textPrimary),
        actionsIconTheme: IconThemeData(color: textSecondary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              color: s.contains(WidgetState.selected) ? primary : textMuted,
              size: 22,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((s) {
          final on = s.contains(WidgetState.selected);
          return TextStyle(
            color: on ? primary : textMuted,
            fontSize: 11,
            fontWeight: on ? FontWeight.w600 : FontWeight.w400,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadius12),
          borderSide: borderSide,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadius12),
          borderSide: borderSide,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadius12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadius12),
          borderSide: BorderSide(color: debit),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadius12),
          borderSide: BorderSide(color: debit, width: 1.5),
        ),
        labelStyle: TextStyle(color: textSecondary, fontSize: 14),
        hintStyle: TextStyle(color: textMuted, fontSize: 14),
        prefixStyle: TextStyle(color: textSecondary),
        suffixIconColor: textMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadius12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: borderSide,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadius12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 0.5, space: 0),
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        textColor: textPrimary,
        subtitleTextStyle: TextStyle(color: textSecondary, fontSize: 13),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(r16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: TextStyle(color: textPrimary),
        actionTextColor: primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(r12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevated,
        selectedColor: primaryContainer,
        side: BorderSide(color: border, width: 0.5),
        labelStyle: TextStyle(color: textPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadius8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(surfaceElevated),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        headerBackgroundColor: primaryContainer,
        headerForegroundColor: primary,
        dayForegroundColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? onPrimary : textPrimary),
        dayBackgroundColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : Colors.transparent),
        todayForegroundColor: WidgetStatePropertyAll(primary),
        todayBorder: BorderSide(color: primary),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(r16),
        ),
      ),
    );
  }
}
