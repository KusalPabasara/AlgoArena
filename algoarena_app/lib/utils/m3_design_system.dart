import 'package:flutter/material.dart';

/// Material Design 3 Design System for Universal Device Compatibility
/// 
/// This system ensures the app looks consistent across all device sizes
/// by using proper dp/sp units and responsive scaling.
/// 
/// Design reference: Pixel 9 Pro (412 x 915 dp)
class M3DesignSystem {
  // Reference device dimensions (Pixel 9 Pro)
  static const double _referenceWidth = 412.0;
  static const double _referenceHeight = 915.0;
  
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _scaleFactor;
  static late double _textScaleFactor;
  static late double _devicePixelRatio;
  static late EdgeInsets _safeArea;
  static late bool _isInitialized;
  
  /// Initialize the design system - call this in your root widget
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _devicePixelRatio = mediaQuery.devicePixelRatio;
    _safeArea = mediaQuery.padding;
    
    // Calculate scale factor based on width (most important for UI)
    _scaleFactor = (_screenWidth / _referenceWidth).clamp(0.75, 1.35);
    
    // Text scale factor - respect system settings but clamp for design consistency
    _textScaleFactor = mediaQuery.textScaleFactor.clamp(0.85, 1.15);
    
    _isInitialized = true;
  }
  
  /// Check if initialized
  static bool get isInitialized => _isInitialized;
  
  /// Screen dimensions
  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;
  static EdgeInsets get safeArea => _safeArea;
  
  // ============================================================
  // DEVICE TYPE DETECTION
  // ============================================================
  
  /// Device type based on screen width
  static DeviceType get deviceType {
    if (_screenWidth < 360) return DeviceType.smallPhone;
    if (_screenWidth < 400) return DeviceType.phone;
    if (_screenWidth < 600) return DeviceType.largePhone;
    if (_screenWidth < 840) return DeviceType.tablet;
    return DeviceType.desktop;
  }
  
  static bool get isSmallPhone => deviceType == DeviceType.smallPhone;
  static bool get isPhone => deviceType == DeviceType.phone || deviceType == DeviceType.largePhone;
  static bool get isTablet => deviceType == DeviceType.tablet;
  static bool get isDesktop => deviceType == DeviceType.desktop;
  
  // ============================================================
  // MATERIAL DESIGN 3 - INPUT FIELD STANDARDS
  // ============================================================
  
  /// Standard M3 TextField height (56dp)
  static double get inputHeight => 56.0 * _scaleFactor;
  
  /// Minimum touch target (48dp)
  static double get minTouchTarget => 48.0;
  
  /// Input field corner radius (M3: 4-8dp, we use 8dp for modern look)
  static double get inputRadius => 8.0 * _scaleFactor;
  
  /// Pill-shaped input radius (for rounded inputs)
  static double get inputRadiusPill => 28.0 * _scaleFactor;
  
  /// Input border width - normal state
  static double get inputBorderNormal => 1.0;
  
  /// Input border width - focused/error state
  static double get inputBorderFocused => 2.0;
  
  /// Input horizontal padding (M3: 16dp)
  static double get inputPaddingHorizontal => 16.0 * _scaleFactor;
  
  /// Input vertical padding (M3: 12dp)
  static double get inputPaddingVertical => 12.0 * _scaleFactor;
  
  /// Input content padding
  static EdgeInsets get inputContentPadding => EdgeInsets.symmetric(
    horizontal: inputPaddingHorizontal,
    vertical: inputPaddingVertical,
  );
  
  /// Input content padding with icons
  static EdgeInsets get inputContentPaddingWithIcon => EdgeInsets.only(
    left: 8.0 * _scaleFactor,
    right: inputPaddingHorizontal,
    top: inputPaddingVertical,
    bottom: inputPaddingVertical,
  );
  
  // ============================================================
  // MATERIAL DESIGN 3 - TYPOGRAPHY (SP units)
  // ============================================================
  
  /// Display Large - 57sp
  static double get displayLarge => 57.0 * _textScaleFactor;
  
  /// Display Medium - 45sp
  static double get displayMedium => 45.0 * _textScaleFactor;
  
  /// Display Small - 36sp
  static double get displaySmall => 36.0 * _textScaleFactor;
  
  /// Headline Large - 32sp
  static double get headlineLarge => 32.0 * _textScaleFactor;
  
  /// Headline Medium - 28sp
  static double get headlineMedium => 28.0 * _textScaleFactor;
  
  /// Headline Small - 24sp
  static double get headlineSmall => 24.0 * _textScaleFactor;
  
  /// Title Large - 22sp
  static double get titleLarge => 22.0 * _textScaleFactor;
  
  /// Title Medium - 16sp
  static double get titleMedium => 16.0 * _textScaleFactor;
  
  /// Title Small - 14sp
  static double get titleSmall => 14.0 * _textScaleFactor;
  
  /// Body Large - 16sp (Input text)
  static double get bodyLarge => 16.0 * _textScaleFactor;
  
  /// Body Medium - 14sp
  static double get bodyMedium => 14.0 * _textScaleFactor;
  
  /// Body Small - 12sp (Helper text, error text)
  static double get bodySmall => 12.0 * _textScaleFactor;
  
  /// Label Large - 14sp
  static double get labelLarge => 14.0 * _textScaleFactor;
  
  /// Label Medium - 12sp (Floating label)
  static double get labelMedium => 12.0 * _textScaleFactor;
  
  /// Label Small - 11sp
  static double get labelSmall => 11.0 * _textScaleFactor;
  
  /// Input text size (M3: 16sp)
  static double get inputTextSize => bodyLarge;
  
  /// Hint/Placeholder size (M3: 16sp)
  static double get hintTextSize => bodyLarge;
  
  /// Floating label size (M3: 12sp)
  static double get floatingLabelSize => labelMedium;
  
  /// Helper/Error text size (M3: 12sp)
  static double get helperTextSize => bodySmall;
  
  // ============================================================
  // MATERIAL DESIGN 3 - SPACING
  // ============================================================
  
  /// Extra small spacing - 4dp
  static double get spacingXS => 4.0 * _scaleFactor;
  
  /// Small spacing - 8dp
  static double get spacingS => 8.0 * _scaleFactor;
  
  /// Medium spacing - 16dp (default)
  static double get spacingM => 16.0 * _scaleFactor;
  
  /// Large spacing - 24dp
  static double get spacingL => 24.0 * _scaleFactor;
  
  /// Extra large spacing - 32dp
  static double get spacingXL => 32.0 * _scaleFactor;
  
  /// XXL spacing - 48dp
  static double get spacingXXL => 48.0 * _scaleFactor;
  
  /// Space between input fields (M3: 16dp)
  static double get inputFieldSpacing => spacingM;
  
  /// Space between input and button (M3: 24dp)
  static double get inputToButtonSpacing => spacingL;
  
  /// Space between section title and input (M3: 8-12dp)
  static double get sectionToInputSpacing => spacingS;
  
  // ============================================================
  // MATERIAL DESIGN 3 - ICONS
  // ============================================================
  
  /// Standard icon size (M3: 24dp)
  static double get iconSize => 24.0 * _scaleFactor;
  
  /// Small icon size (M3: 20dp) - clear/close icons
  static double get iconSizeSmall => 20.0 * _scaleFactor;
  
  /// Large icon size (M3: 32dp)
  static double get iconSizeLarge => 32.0 * _scaleFactor;
  
  /// Icon to text padding (M3: 8dp)
  static double get iconTextPadding => 8.0 * _scaleFactor;
  
  // ============================================================
  // MATERIAL DESIGN 3 - BUTTONS
  // ============================================================
  
  /// Standard button height (M3: 40dp, but 56dp for prominent actions)
  static double get buttonHeight => 56.0 * _scaleFactor;
  
  /// Small button height (M3: 40dp)
  static double get buttonHeightSmall => 40.0 * _scaleFactor;
  
  /// Button corner radius (M3: 20dp for filled, 8dp for outlined)
  static double get buttonRadius => 28.0 * _scaleFactor;
  
  /// Button horizontal padding (M3: 24dp)
  static double get buttonPaddingHorizontal => 24.0 * _scaleFactor;
  
  // ============================================================
  // MATERIAL DESIGN 3 - CARDS & CONTAINERS
  // ============================================================
  
  /// Card corner radius (M3: 12dp)
  static double get cardRadius => 12.0 * _scaleFactor;
  
  /// Card elevation
  static double get cardElevation => 1.0;
  
  /// Screen horizontal padding
  static double get screenPaddingHorizontal => 24.0 * _scaleFactor;
  
  /// Screen vertical padding
  static double get screenPaddingVertical => 16.0 * _scaleFactor;
  
  /// Screen padding
  static EdgeInsets get screenPadding => EdgeInsets.symmetric(
    horizontal: screenPaddingHorizontal,
    vertical: screenPaddingVertical,
  );
  
  // ============================================================
  // RESPONSIVE SCALING METHODS
  // ============================================================
  
  /// Scale a dp value for the current screen
  static double dp(double value) => value * _scaleFactor;
  
  /// Scale a sp value for text (respects system text scaling)
  static double sp(double value) => value * _textScaleFactor;
  
  /// Get percentage of screen width
  static double w(double percentage) => _screenWidth * (percentage / 100);
  
  /// Get percentage of screen height
  static double h(double percentage) => _screenHeight * (percentage / 100);
  
  /// Get safe width (excluding safe area)
  static double sw(double percentage) {
    final safeWidth = _screenWidth - _safeArea.left - _safeArea.right;
    return safeWidth * (percentage / 100);
  }
  
  /// Get safe height (excluding safe area)
  static double sh(double percentage) {
    final safeHeight = _screenHeight - _safeArea.top - _safeArea.bottom;
    return safeHeight * (percentage / 100);
  }
  
  /// Clamp a value between min and max based on device type
  static double clampForDevice(double value, {double? min, double? max}) {
    double minVal = min ?? value * 0.75;
    double maxVal = max ?? value * 1.35;
    return (value * _scaleFactor).clamp(minVal, maxVal);
  }
}

/// Device type enumeration
enum DeviceType {
  smallPhone,  // < 360dp
  phone,       // 360-400dp
  largePhone,  // 400-600dp
  tablet,      // 600-840dp
  desktop,     // > 840dp
}

/// M3 Color scheme for input states
class M3InputColors {
  // Normal state
  static const Color borderNormal = Color(0xFF79747E);
  static const Color labelNormal = Color(0xFF49454F);
  static const Color hintNormal = Color(0xFF49454F);
  
  // Focused state
  static const Color borderFocused = Color(0xFF6750A4);
  static const Color labelFocused = Color(0xFF6750A4);
  
  // Error state
  static const Color borderError = Color(0xFFB3261E);
  static const Color labelError = Color(0xFFB3261E);
  static const Color textError = Color(0xFFB3261E);
  
  // Disabled state
  static const Color borderDisabled = Color(0x1F1C1B1F);
  static const Color textDisabled = Color(0x611C1B1F);
  
  // For dark backgrounds (like auth screens)
  static const Color borderDark = Color(0x66FFFFFF);
  static const Color textDark = Colors.white;
  static const Color hintDark = Color(0xFFD2D2D2);
  static const Color fillDark = Color(0x66000000);
}

/// Extension for easy responsive values
extension M3Responsive on num {
  /// Convert to scaled dp
  double get dp => M3DesignSystem.dp(toDouble());
  
  /// Convert to scaled sp (for text)
  double get sp => M3DesignSystem.sp(toDouble());
  
  /// Convert to percentage of screen width
  double get w => M3DesignSystem.w(toDouble());
  
  /// Convert to percentage of screen height
  double get h => M3DesignSystem.h(toDouble());
}
