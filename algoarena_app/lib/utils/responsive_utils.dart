import 'package:flutter/material.dart';

/// Responsive utility class for making UI adapt to any screen size
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

  /// Initialize responsive values - call this in build method
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    textScaleFactor = _mediaQueryData.textScaleFactor.clamp(0.8, 1.2);
    devicePixelRatio = _mediaQueryData.devicePixelRatio;

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

  /// Get responsive font size
  static double sp(double size) {
    // Base design width is 390 (iPhone 14)
    double scaleFactor = screenWidth / 390;
    return (size * scaleFactor).clamp(size * 0.8, size * 1.3);
  }

  /// Get responsive radius
  static double r(double radius) {
    double scaleFactor = screenWidth / 390;
    return radius * scaleFactor;
  }

  /// Check if device is tablet
  static bool get isTablet => screenWidth >= 600;

  /// Check if device is small phone
  static bool get isSmallPhone => screenWidth < 360;

  /// Check if device is large phone
  static bool get isLargePhone => screenWidth >= 400;

  /// Get adaptive padding
  static EdgeInsets adaptivePadding({
    double horizontal = 16,
    double vertical = 16,
  }) {
    return EdgeInsets.symmetric(
      horizontal: w(horizontal / 3.9),
      vertical: h(vertical / 8.44),
    );
  }

  /// Get device type string
  static String get deviceType {
    if (isTablet) return 'tablet';
    if (isSmallPhone) return 'small_phone';
    if (isLargePhone) return 'large_phone';
    return 'phone';
  }
}

/// Extension methods for responsive sizing
extension ResponsiveExtension on num {
  /// Responsive width
  double get w => ResponsiveUtils.w(toDouble());
  
  /// Responsive height
  double get h => ResponsiveUtils.h(toDouble());
  
  /// Responsive font size
  double get sp => ResponsiveUtils.sp(toDouble());
  
  /// Responsive radius
  double get r => ResponsiveUtils.r(toDouble());
  
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
