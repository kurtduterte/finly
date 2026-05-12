part of 'app_theme.dart';

ThemeData _buildThemeData({
  required ColorScheme colorScheme,
  required _ThemeTokens tokens,
  required Brightness statusIconBrightness,
}) {
  final borderSide = BorderSide(color: tokens.border);
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: tokens.background,
    cardTheme: _buildCardTheme(tokens),
    appBarTheme: _buildAppBarTheme(tokens, statusIconBrightness),
    navigationBarTheme: _buildNavigationBarTheme(tokens),
    inputDecorationTheme: _buildInputDecorationTheme(tokens, borderSide),
    filledButtonTheme: _buildFilledButtonTheme(tokens),
    outlinedButtonTheme: _buildOutlinedButtonTheme(tokens, borderSide),
    textButtonTheme: _buildTextButtonTheme(tokens),
    dividerTheme: _buildDividerTheme(tokens),
    listTileTheme: _buildListTileTheme(tokens),
    floatingActionButtonTheme: _buildFabTheme(tokens),
    snackBarTheme: _buildSnackBarTheme(tokens),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: tokens.primary),
    chipTheme: _buildChipTheme(tokens),
    dropdownMenuTheme: _buildDropdownMenuTheme(tokens),
    datePickerTheme: _buildDatePickerTheme(tokens),
  );
}
