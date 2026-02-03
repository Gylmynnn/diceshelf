import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/colors.dart';
import '../constants/strings.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  /// Get theme data based on theme mode
  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return _darkTheme;
      case AppThemeMode.sepia:
        return _sepiaTheme;
      case AppThemeMode.light:
        return _lightTheme;
    }
  }

  /// Dark theme (default Everblush)
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: EverblushColors.background,
    colorScheme: const ColorScheme.dark(
      primary: EverblushColors.primary,
      secondary: EverblushColors.secondary,
      surface: EverblushColors.surface,
      error: EverblushColors.error,
      onPrimary: EverblushColors.background,
      onSecondary: EverblushColors.background,
      onSurface: EverblushColors.textPrimary,
      onError: EverblushColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: EverblushColors.background,
      foregroundColor: EverblushColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
    cardTheme: CardThemeData(
      color: EverblushColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: EverblushColors.surface,
      selectedItemColor: EverblushColors.primary,
      unselectedItemColor: EverblushColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: EverblushColors.primary,
      foregroundColor: EverblushColors.background,
      elevation: 2,
    ),
    iconTheme: const IconThemeData(
      color: EverblushColors.textPrimary,
      size: 24,
    ),
    textTheme: _textTheme(EverblushColors.textPrimary),
    inputDecorationTheme: _inputDecorationTheme(
      EverblushColors.surface,
      EverblushColors.primary,
    ),
    dividerTheme: const DividerThemeData(
      color: EverblushColors.surfaceLight,
      thickness: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: EverblushColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: EverblushColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: EverblushColors.surfaceLight,
      contentTextStyle: const TextStyle(color: EverblushColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  /// Sepia theme for comfortable reading
  static final ThemeData _sepiaTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: SepiaThemeColors.background,
    colorScheme: const ColorScheme.dark(
      primary: SepiaThemeColors.primary,
      secondary: EverblushColors.yellow,
      surface: SepiaThemeColors.surface,
      error: EverblushColors.error,
      onPrimary: EverblushColors.background,
      onSecondary: EverblushColors.background,
      onSurface: SepiaThemeColors.textPrimary,
      onError: EverblushColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: SepiaThemeColors.background,
      foregroundColor: SepiaThemeColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
    cardTheme: CardThemeData(
      color: SepiaThemeColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: SepiaThemeColors.surface,
      selectedItemColor: SepiaThemeColors.primary,
      unselectedItemColor: SepiaThemeColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: SepiaThemeColors.primary,
      foregroundColor: EverblushColors.background,
      elevation: 2,
    ),
    iconTheme: const IconThemeData(
      color: SepiaThemeColors.textPrimary,
      size: 24,
    ),
    textTheme: _textTheme(SepiaThemeColors.textPrimary),
    inputDecorationTheme: _inputDecorationTheme(
      SepiaThemeColors.surface,
      SepiaThemeColors.primary,
    ),
    dividerTheme: DividerThemeData(
      color: SepiaThemeColors.surface.withValues(alpha: 0.5),
      thickness: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: SepiaThemeColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: SepiaThemeColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: SepiaThemeColors.surface,
      contentTextStyle: const TextStyle(color: SepiaThemeColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  /// Light theme (Warm White)
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: LightThemeColors.background,
    colorScheme: const ColorScheme.light(
      primary: LightThemeColors.primary,
      secondary: LightThemeColors.secondary,
      surface: LightThemeColors.surface,
      error: EverblushColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: LightThemeColors.textPrimary,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: LightThemeColors.background,
      foregroundColor: LightThemeColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    cardTheme: CardThemeData(
      color: LightThemeColors.surface,
      elevation: 1,
      shadowColor: LightThemeColors.border.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: LightThemeColors.border.withValues(alpha: 0.3)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: LightThemeColors.surface,
      selectedItemColor: LightThemeColors.primary,
      unselectedItemColor: LightThemeColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: LightThemeColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    iconTheme: const IconThemeData(
      color: LightThemeColors.textPrimary,
      size: 24,
    ),
    textTheme: _textTheme(LightThemeColors.textPrimary),
    inputDecorationTheme: _inputDecorationTheme(
      LightThemeColors.surfaceVariant,
      LightThemeColors.primary,
    ),
    dividerTheme: const DividerThemeData(
      color: LightThemeColors.divider,
      thickness: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: LightThemeColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: LightThemeColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: LightThemeColors.textPrimary,
      contentTextStyle: const TextStyle(color: LightThemeColors.surface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  /// Common text theme
  static TextTheme _textTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textColor.withValues(alpha: 0.7),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textColor.withValues(alpha: 0.7),
      ),
    );
  }

  /// Common input decoration theme
  static InputDecorationTheme _inputDecorationTheme(
    Color fillColor,
    Color primaryColor,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: EverblushColors.error, width: 1),
      ),
      hintStyle: const TextStyle(color: EverblushColors.textMuted),
    );
  }
}
