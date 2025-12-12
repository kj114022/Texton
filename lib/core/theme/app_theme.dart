import 'package:flutter/cupertino.dart';

/// Pomegranate by Entropy color palette
/// Rich reds and deep maroons for a striking dark theme
class AppColors {
  AppColors._();

  // Core brand colors - Pomegranate palette
  static const Color primary = Color(0xFFBA0109);      // Bright red
  static const Color primaryLight = Color(0xFFCC1D2C); // Red/crimson
  static const Color primaryDark = Color(0xFF7B0005);  // Deep red

  // Accent/highlight
  static const Color accent = Color(0xFF44010A);       // Dark red/maroon

  // Dark theme colors (primary)
  static const Color background = Color(0xFF150003);   // Very dark red (almost black)
  static const Color surface = Color(0xFF1A0205);      // Slightly lighter dark red
  static const Color surfaceVariant = Color(0xFF220308);
  static const Color surfaceElevated = Color(0xFF2A040A);
  static const Color cardBackground = Color(0xFF1A0205);

  // Text colors
  static const Color textPrimary = Color(0xFFF5E6E8);  // Warm white with red tint
  static const Color textSecondary = Color(0xFFB89A9E);
  static const Color textTertiary = Color(0xFF8A6A6E);

  // Dividers and borders
  static const Color divider = Color(0xFF3D1218);
  static const Color border = Color(0xFF3D1218);
  static const Color borderLight = Color(0xFF4A1A20);

  // Status colors
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFCC1D2C);
  static const Color warning = Color(0xFFE67E22);

  // Interactive states
  static const Color ripple = Color(0x1ABA0109);
  static const Color overlay = Color(0x80150003);

  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFFBA0109),
    Color(0xFF7B0005),
  ];

  // Format badge colors - adjusted for pomegranate theme
  static const Color pdfBadge = Color(0xFFBA0109);     // Primary red
  static const Color epubBadge = Color(0xFF44010A);    // Maroon
  static const Color mobiBadge = Color(0xFFCC1D2C);    // Crimson
  static const Color azw3Badge = Color(0xFF7B0005);    // Deep red

  // Legacy aliases for compatibility
  static const Color xBlue = primary;
  static const Color xBlueLight = primaryLight;
  static const Color xBlueDark = primaryDark;
}

/// Cupertino theme configuration for dark mode with Pomegranate palette
class AppTheme {
  AppTheme._();

  static CupertinoThemeData get darkTheme {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      primaryContrastingColor: AppColors.textPrimary,
      scaffoldBackgroundColor: AppColors.background,
      barBackgroundColor: AppColors.surface,
      textTheme: CupertinoTextThemeData(
        primaryColor: AppColors.primary,
        textStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontFamily: '.SF Pro Text',
        ),
        navTitleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          fontFamily: '.SF Pro Text',
        ),
        navLargeTitleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 34,
          fontWeight: FontWeight.bold,
          fontFamily: '.SF Pro Display',
        ),
        tabLabelTextStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontFamily: '.SF Pro Text',
        ),
      ),
    );
  }
}
