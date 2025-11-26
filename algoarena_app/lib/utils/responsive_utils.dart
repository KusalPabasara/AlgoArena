import 'package:flutter/material.dart';

/// Responsive utility class for making UI adapt to any screen size
/// 
/// Reference design: Pixel 9 Pro (412 x 915 dp)
/// Uses MediaQuery to calculate responsive dimensions
class ResponsiveUtils {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late double textScaleFactor;
  static late double devicePixelRatio;
  static late double _scaleFactor;
  
  // Reference device (Pixel 9 Pro)
  static const double _referenceWidth = 412.0;
  static const double _referenceHeight = 915.0;

  /// Initialize responsive values - call this in build method
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    
    // Clamp text scale factor for design consistency
    textScaleFactor = _mediaQueryData.textScaleFactor.clamp(0.85, 1.15);
    devicePixelRatio = _mediaQueryData.devicePixelRatio;
    
    // Calculate scale factor based on width ratio to reference device
    _scaleFactor = (screenWidth / _referenceWidth).clamp(0.75, 1.35);

    safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;
  }

  /// Get responsive width (percentage of screen width)
  static double w(double percentage) => blockSizeHorizontal * percentage;

  /// Get responsive height (percentage of screen height)
  static double h(double percentage) => blockSizeVertical * percentage;

  /// Get responsive width with safe area
  static double sw(double percentage) => safeBlockHorizontal * percentage;

  /// Get responsive height with safe area
  static double sh(double percentage) => safeBlockVertical * percentage;

  /// Get responsive font size (sp - scaled pixels)
  /// Base design is for Pixel 9 Pro (412dp width)
  static double sp(double size) {
    return (size * _scaleFactor * textScaleFactor).clamp(size * 0.75, size * 1.35);
  }

  /// Get responsive radius
  static double r(double radius) {
    return (radius * _scaleFactor).clamp(radius * 0.75, radius * 1.35);
  }
  
  /// Get responsive dp value (density-independent pixels)
  static double dp(double value) {
    return (value * _scaleFactor).clamp(value * 0.75, value * 1.35);
  }

  /// Check if device is tablet
  static bool get isTablet => screenWidth >= 600;

  /// Check if device is small phone
  static bool get isSmallPhone => screenWidth < 360;

  /// Check if device is large phone
  static bool get isLargePhone => screenWidth >= 400;
  
  /// Check if device is medium phone (reference size)
  static bool get isMediumPhone => screenWidth >= 360 && screenWidth < 400;

  /// Get adaptive padding
  static EdgeInsets adaptivePadding({
    double horizontal = 24,
    double vertical = 16,
  }) {
    return EdgeInsets.symmetric(
      horizontal: dp(horizontal),
      vertical: dp(vertical),
    );
  }
  
  /// Get adaptive horizontal padding
  static double get adaptiveHorizontalPadding {
    if (isSmallPhone) return dp(16);
    if (isTablet) return dp(32);
    return dp(24);
  }

  /// Get device type string
  static String get deviceType {
    if (isTablet) return 'tablet';
    if (isSmallPhone) return 'small_phone';
    if (isLargePhone) return 'large_phone';
    return 'phone';
  }
  
  /// Get scale factor
  static double get scaleFactor => _scaleFactor;
  
  // ============================================================
  // MATERIAL DESIGN 3 STANDARD DIMENSIONS
  // ============================================================
  
  /// M3 standard input field height (56dp)
  static double get inputHeight => dp(56);
  
  /// M3 minimum touch target (48dp)
  static double get minTouchTarget => 48.0;
  
  /// M3 button height (56dp for prominent, 40dp for standard)
  static double get buttonHeight => dp(56);
  static double get buttonHeightSmall => dp(40);
  
  /// M3 input corner radius (4-8dp)
  static double get inputRadius => dp(8);
  
  /// M3 button corner radius (20-28dp for pill shape)
  static double get buttonRadius => dp(28);
  
  /// M3 card corner radius (12dp)
  static double get cardRadius => dp(12);
  
  /// M3 icon sizes
  static double get iconSize => dp(24);
  static double get iconSizeSmall => dp(20);
  static double get iconSizeLarge => dp(32);
  
  // ============================================================
  // MATERIAL DESIGN 3 SPACING
  // ============================================================
  
  /// Extra small (4dp)
  static double get spacingXS => dp(4);
  
  /// Small (8dp)
  static double get spacingS => dp(8);
  
  /// Medium (16dp) - default
  static double get spacingM => dp(16);
  
  /// Large (24dp)
  static double get spacingL => dp(24);
  
  /// Extra large (32dp)
  static double get spacingXL => dp(32);
  
  /// XXL (48dp)
  static double get spacingXXL => dp(48);
  
  // ============================================================
  // MATERIAL DESIGN 3 TYPOGRAPHY (SP)
  // ============================================================
  
  /// Display Large - 57sp
  static double get displayLarge => sp(57);
  
  /// Display Medium - 45sp
  static double get displayMedium => sp(45);
  
  /// Display Small - 36sp
  static double get displaySmall => sp(36);
  
  /// Headline Large - 32sp
  static double get headlineLarge => sp(32);
  
  /// Headline Medium - 28sp
  static double get headlineMedium => sp(28);
  
  /// Headline Small - 24sp
  static double get headlineSmall => sp(24);
  
  /// Title Large - 22sp
  static double get titleLarge => sp(22);
  
  /// Title Medium - 16sp
  static double get titleMedium => sp(16);
  
  /// Title Small - 14sp
  static double get titleSmall => sp(14);
  
  /// Body Large - 16sp (Input text)
  static double get bodyLarge => sp(16);
  
  /// Body Medium - 14sp
  static double get bodyMedium => sp(14);
  
  /// Body Small - 12sp (Helper/Error text)
  static double get bodySmall => sp(12);
  
  /// Label Large - 14sp
  static double get labelLarge => sp(14);
  
  /// Label Medium - 12sp (Floating label)
  static double get labelMedium => sp(12);
  
  /// Label Small - 11sp
  static double get labelSmall => sp(11);
  
  // ============================================================
  // KEYBOARD UTILITIES
  // ============================================================
  
  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
  
  /// Get keyboard height
  static double keyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }
  
  /// Get available height (screen height minus keyboard)
  static double availableHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height - mediaQuery.viewInsets.bottom;
  }
  
  /// Get bottom padding for keyboard (use with ScrollView)
  static double keyboardBottomPadding(BuildContext context, {double extra = 20}) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return keyboardHeight > 0 ? keyboardHeight + extra : 0;
  }
}

/// Extension methods for responsive sizing
extension ResponsiveExtension on num {
  /// Responsive width (percentage of screen)
  double get w => ResponsiveUtils.w(toDouble());
  
  /// Responsive height (percentage of screen)
  double get h => ResponsiveUtils.h(toDouble());
  
  /// Responsive font size (sp - scaled pixels)
  double get sp => ResponsiveUtils.sp(toDouble());
  
  /// Responsive radius
  double get r => ResponsiveUtils.r(toDouble());
  
  /// Responsive dp (density-independent pixels)
  double get dp => ResponsiveUtils.dp(toDouble());
  
  /// Safe width
  double get sw => ResponsiveUtils.sw(toDouble());
  
  /// Safe height
  double get sh => ResponsiveUtils.sh(toDouble());
}

/// Widget for responsive building
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints, ResponsiveUtils utils) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, constraints, ResponsiveUtils());
      },
    );
  }
}

/// Responsive SizedBox
class ResponsiveSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const ResponsiveSizedBox({
    super.key,
    this.width,
    this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    return SizedBox(
      width: width != null ? ResponsiveUtils.w(width!) : null,
      height: height != null ? ResponsiveUtils.h(height!) : null,
      child: child,
    );
  }
}
