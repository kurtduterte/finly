part of 'app_theme.dart';

CardThemeData _buildCardTheme(_ThemeTokens tokens) => CardThemeData(
  color: tokens.surface,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(kRadius16),
    side: BorderSide(color: tokens.border, width: 0.5),
  ),
  margin: EdgeInsets.zero,
);

AppBarTheme _buildAppBarTheme(
  _ThemeTokens tokens,
  Brightness statusIconBrightness,
) => AppBarTheme(
  backgroundColor: tokens.background,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  systemOverlayStyle: SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: statusIconBrightness,
    systemNavigationBarColor: tokens.surface,
  ),
  iconTheme: IconThemeData(color: tokens.textPrimary),
  actionsIconTheme: IconThemeData(color: tokens.textSecondary),
  titleTextStyle: TextStyle(
    color: tokens.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  ),
);

NavigationBarThemeData _buildNavigationBarTheme(_ThemeTokens tokens) {
  return NavigationBarThemeData(
    backgroundColor: tokens.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    height: 64,
    indicatorColor: tokens.primaryContainer,
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        color: states.contains(WidgetState.selected)
            ? tokens.primary
            : tokens.textMuted,
        size: 22,
      ),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => TextStyle(
        color: states.contains(WidgetState.selected)
            ? tokens.primary
            : tokens.textMuted,
        fontSize: 11,
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w600
            : FontWeight.w400,
      ),
    ),
  );
}

InputDecorationTheme _buildInputDecorationTheme(
  _ThemeTokens tokens,
  BorderSide borderSide,
) => InputDecorationTheme(
  filled: true,
  fillColor: tokens.surfaceElevated,
  border: _inputBorder(borderSide),
  enabledBorder: _inputBorder(borderSide),
  focusedBorder: _inputBorder(BorderSide(color: tokens.primary, width: 1.5)),
  errorBorder: _inputBorder(BorderSide(color: tokens.debit)),
  focusedErrorBorder: _inputBorder(BorderSide(color: tokens.debit, width: 1.5)),
  labelStyle: TextStyle(color: tokens.textSecondary, fontSize: 14),
  hintStyle: TextStyle(color: tokens.textMuted, fontSize: 14),
  prefixStyle: TextStyle(color: tokens.textSecondary),
  suffixIconColor: tokens.textMuted,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
);

OutlineInputBorder _inputBorder(BorderSide borderSide) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(kRadius12),
  borderSide: borderSide,
);

FilledButtonThemeData _buildFilledButtonTheme(_ThemeTokens tokens) =>
    FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tokens.primary,
        foregroundColor: tokens.onPrimary,
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
    );

OutlinedButtonThemeData _buildOutlinedButtonTheme(
  _ThemeTokens tokens,
  BorderSide borderSide,
) => OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    foregroundColor: tokens.textPrimary,
    side: borderSide,
    minimumSize: const Size.fromHeight(50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kRadius12),
    ),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
  ),
);

TextButtonThemeData _buildTextButtonTheme(_ThemeTokens tokens) =>
    TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: tokens.primary),
    );
