import 'package:flutter/material.dart';
import 'colors.dart';

/// Centralized theme configuration for the app
class AppTheme {
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;

  // Tile sizing (will be calculated based on screen size)
  static const double tileAspectRatio = 1.0;
  static const double tileSpacing = 8.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  /// Get the Material theme for the app
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.skyTop,
        secondary: AppColors.tileSelected,
        surface: Colors.white,
        error: AppColors.tileIncorrect,
      ),
      scaffoldBackgroundColor: AppColors.skyBottom,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: elevationMedium,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
        ),
      ),
    );
  }

  /// Get color for a tile based on its state and color index
  static Color getTileColor(String state, {int colorIndex = 0}) {
    switch (state) {
      case 'selected':
        return AppColors.tileSelected;
      case 'correct':
        return AppColors
            .categoryColors[colorIndex % AppColors.categoryColors.length];
      case 'incorrect':
        return AppColors.tileIncorrect;
      default:
        return AppColors.tileNormal;
    }
  }

  /// Get border color for a tile based on its state
  static Color getTileBorderColor(String state, {int colorIndex = 0}) {
    switch (state) {
      case 'selected':
        return AppColors.tileSelectedBorder;
      case 'correct':
        final baseColor = AppColors
            .categoryColors[colorIndex % AppColors.categoryColors.length];
        return baseColor.withOpacity(0.8);
      case 'incorrect':
        return AppColors.tileIncorrectBorder;
      default:
        return AppColors.tileNormalBorder;
    }
  }
}
