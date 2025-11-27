import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFFFD700); // Gold
  static const Color primaryDark = Color(0xFFB8860B);
  
  // Neutral Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F8F8);
  static const Color backgroundLight = Color(0xFFFAF8F8);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF202020);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
  
  // Accent Colors
  static const Color blue = Color(0xFF004CFF);
  static const Color orange = Color(0xFFFFB700);
  static const Color green = Color(0xFF00D390);
  static const Color pink = Color(0xFFF43098);
  
  // UI Elements
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFCCCCCC);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  
  // Opacity variants
  static Color blackOpacity40 = black.withOpacity(0.4);
  static Color blackOpacity60 = black.withOpacity(0.6);
  static Color whiteOpacity68 = white.withOpacity(0.68);
  static Color whiteOpacity90 = white.withOpacity(0.9);
  
  // Event Card Colors (from Figma)
  static const Color eventPurple = Color.fromRGBO(125, 78, 148, 0.2);
  static const Color eventBlack = Color.fromRGBO(0, 0, 0, 0.2);
  static const Color eventCyan = Color.fromRGBO(0, 177, 255, 0.2);
  static const Color eventRed = Color.fromRGBO(255, 0, 0, 0.2);
  
  // Gold variants (from Figma)
  static const Color goldDark = Color(0xFF8F7902);
  static const Color goldLight = Color(0xFFFFF1C6);
  static const Color goldTint = Color.fromRGBO(255, 215, 0, 0.18);
}
