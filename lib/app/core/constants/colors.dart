import 'package:flutter/material.dart';

/// Everblush color palette
/// A beautiful, soft color scheme inspired by nature
class EverblushColors {
  EverblushColors._();

  // Base colors
  static const Color background = Color(0xFF141B1E);
  static const Color backgroundLight = Color(0xFF1E2528);
  static const Color surface = Color(0xFF232A2D);
  static const Color surfaceLight = Color(0xFF2D3437);

  // Text colors
  static const Color textPrimary = Color(0xFFDADFE7);
  static const Color textSecondary = Color(0xFF8B9093);
  static const Color textMuted = Color(0xFF5C6366);

  // Accent colors
  static const Color red = Color(0xFFE57474);
  static const Color orange = Color(0xFFF4A674);
  static const Color yellow = Color(0xFFE5C76B);
  static const Color green = Color(0xFF8CCF7E);
  static const Color cyan = Color(0xFF67B0E8);
  static const Color blue = Color(0xFF6CB5EC);
  static const Color purple = Color(0xFFC47FD5);
  static const Color pink = Color(0xFFEF7D90);

  // Semantic colors
  static const Color primary = cyan;
  static const Color secondary = purple;
  static const Color success = green;
  static const Color warning = yellow;
  static const Color error = red;

  // Highlight colors (for annotations)
  static const List<Color> highlightColors = [
    Color(0x80E5C76B), // Yellow
    Color(0x808CCF7E), // Green
    Color(0x8067B0E8), // Cyan
    Color(0x80C47FD5), // Purple
    Color(0x80EF7D90), // Pink
    Color(0x80F4A674), // Orange
  ];

  // Sepia mode colors
  static const Color sepiaBackground = Color(0xFF2A2520);
  static const Color sepiaSurface = Color(0xFF352F29);
  static const Color sepiaText = Color(0xFFE8DFD5);
}

/// Dark theme colors (default)
class DarkThemeColors {
  DarkThemeColors._();

  static const Color background = EverblushColors.background;
  static const Color surface = EverblushColors.surface;
  static const Color primary = EverblushColors.primary;
  static const Color textPrimary = EverblushColors.textPrimary;
  static const Color textSecondary = EverblushColors.textSecondary;
}

/// Sepia theme colors
class SepiaThemeColors {
  SepiaThemeColors._();

  static const Color background = EverblushColors.sepiaBackground;
  static const Color surface = EverblushColors.sepiaSurface;
  static const Color primary = EverblushColors.orange;
  static const Color textPrimary = EverblushColors.sepiaText;
  static const Color textSecondary = Color(0xFFB8A99A);
}

/// Light theme colors (Warm White)
class LightThemeColors {
  LightThemeColors._();

  // Background colors - warm off-white
  static const Color background = Color(0xFFF8F6F4);
  static const Color backgroundDark = Color(0xFFF0EDE9);

  // Surface colors - pure white for cards
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F3F0);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5C5C5C);
  static const Color textMuted = Color(0xFF9A9A9A);

  // Keep Everblush accent colors
  static const Color primary = EverblushColors.cyan;
  static const Color secondary = EverblushColors.purple;

  // Border/divider
  static const Color divider = Color(0xFFE8E5E1);
  static const Color border = Color(0xFFDDD9D4);
}
