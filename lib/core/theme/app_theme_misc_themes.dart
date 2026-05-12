part of 'app_theme.dart';

DividerThemeData _buildDividerTheme(_ThemeTokens tokens) =>
    DividerThemeData(color: tokens.border, thickness: 0.5, space: 0);

ListTileThemeData _buildListTileTheme(_ThemeTokens tokens) => ListTileThemeData(
  iconColor: tokens.textSecondary,
  textColor: tokens.textPrimary,
  subtitleTextStyle: TextStyle(color: tokens.textSecondary, fontSize: 13),
);

FloatingActionButtonThemeData _buildFabTheme(_ThemeTokens tokens) {
  const radius = Radius.circular(kRadius16);
  return FloatingActionButtonThemeData(
    backgroundColor: tokens.primary,
    foregroundColor: tokens.onPrimary,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(radius),
    ),
  );
}

SnackBarThemeData _buildSnackBarTheme(_ThemeTokens tokens) {
  const radius = Radius.circular(kRadius12);
  return SnackBarThemeData(
    backgroundColor: tokens.surfaceElevated,
    contentTextStyle: TextStyle(color: tokens.textPrimary),
    actionTextColor: tokens.primary,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(radius)),
    behavior: SnackBarBehavior.floating,
  );
}

ChipThemeData _buildChipTheme(_ThemeTokens tokens) => ChipThemeData(
  backgroundColor: tokens.surfaceElevated,
  selectedColor: tokens.primaryContainer,
  side: BorderSide(color: tokens.border, width: 0.5),
  labelStyle: TextStyle(color: tokens.textPrimary, fontSize: 13),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius8)),
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
);

DropdownMenuThemeData _buildDropdownMenuTheme(_ThemeTokens tokens) =>
    DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(tokens.surfaceElevated),
      ),
    );

DatePickerThemeData _buildDatePickerTheme(_ThemeTokens tokens) {
  const radius = Radius.circular(kRadius16);
  return DatePickerThemeData(
    backgroundColor: tokens.surface,
    headerBackgroundColor: tokens.primaryContainer,
    headerForegroundColor: tokens.primary,
    dayForegroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? tokens.onPrimary
          : tokens.textPrimary,
    ),
    dayBackgroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? tokens.primary
          : Colors.transparent,
    ),
    todayForegroundColor: WidgetStatePropertyAll(tokens.primary),
    todayBorder: BorderSide(color: tokens.primary),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(radius)),
  );
}
