import 'package:flutter/material.dart';

/// Color palette for the Wordcraft game
class AppColors {
  // Background gradient colors (sky blue theme)
  static const skyTop = Color(0xFF87CEEB);
  static const skyBottom = Color(0xFFE0F6FF);

  // Tile state colors
  static const tileNormal = Color(0xFFE8F4F8);
  static const tileNormalBorder = Color(0xFFB0D4E3);
  static const tileSelected = Color(0xFF64B5F6);
  static const tileSelectedBorder = Color(0xFF1976D2);

  // Word category colors (matching reference images)
  static const List<Color> categoryColors = [
    Color(0xFF4CAF50), // 0: Green (Giường/Bed)
    Color(0xFF5C6BC0), // 1: Blue (Tay/Hand)
    Color(0xFFAB47BC), // 2: Purple (Câu hỏi/Question)
    Color(0xFFFFCA28), // 3: Yellow (Buồn/Sad)
    Color(0xFFFF7043), // 4: Orange/Pink (Đi/Go)
    Color(0xFF00BCD4), // 5: Cyan
    Color(0xFF795548), // 6: Brown
    Color(0xFF9E9E9E), // 7: Grey
    Color(0xFFFF4081), // 8: Pink
    Color(0xFFCDDC39), // 9: Lime
    Color(0xFF673AB7), // 10: Deep Purple
    Color(0xFF009688), // 11: Teal
  ];

  // Incorrect state
  static const tileIncorrect = Color(0xFFEF5350);
  static const tileIncorrectBorder = Color(0xFFC62828);

  // Text colors
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textOnColor = Colors.white;

  // Decorative colors
  static const grassGreen = Color(0xFF8BC34A);
  static const cloudWhite = Color(0xFFFAFAFA);
}
