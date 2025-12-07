import 'package:flutter/material.dart';
import '../config/environment.dart';

/// App-wide constants and configuration
class AppConstants {
  // App Info
  static const String appName = 'Leo Connect';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Social networking platform for Leo Clubs';
  
  // API Endpoints - Now uses Environment config
  // To switch between dev/prod, update Environment.init() in main.dart
  static String get baseApiUrl => Environment.apiBaseUrl;
  
  // LeoAssist Chatbot
  static const String chatbotBaseUrl = 'https://v7q4gmwfs544kyun3ta77hgy.agents.do-ai.run';
  static const String chatbotAgentId = '11e6bc4e-ad0a-11f0-b074-4e013e2ddde4';
  static const String chatbotId = 'p2qYRpi8plPD9ygp-DUyk0HyVA08RNh0';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  static const Duration bubbleAnimation = Duration(milliseconds: 600);
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration chatTimeout = Duration(seconds: 60);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 25.0;
  
  // Colors (as hex values for reference)
  static const int primaryColorValue = 0xFFFFD700; // Gold
  static const int secondaryColorValue = 0xFF02091A; // Dark Blue
  static const int accentColorValue = 0xFF8F7902; // Brown Gold
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_complete';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxUsernameLength = 30;
  static const int maxBioLength = 150;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
}

/// App theme colors
class AppColors {
  // Primary Colors
  static const primaryGold = Color(0xFFFFD700);
  static const darkBlue = Color(0xFF02091A);
  static const brownGold = Color(0xFF8F7902);
  
  // UI Colors
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF3F5F6);
  static const inputBackground = Color(0xFFE8EBF0);
  
  // Text Colors
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF444444);
  static const textHint = Color(0xFF888888);
  
  // Status Colors
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFF44336);
  static const warning = Color(0xFFFF9800);
  static const info = Color(0xFF2196F3);
  
  // Gradient Colors
  static const gradientStart = Color(0xFFFFD700);
  static const gradientEnd = Color(0xFF8F7902);
}
