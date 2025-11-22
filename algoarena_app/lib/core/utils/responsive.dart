import 'package:flutter/material.dart';
import '../constants/screen_sizes.dart';

/// Responsive helper utility for making the app work on all device sizes
/// 
/// This utility provides methods to calculate responsive dimensions,
/// font sizes, padding, and spacing based on the current device's screen size.
/// 
/// Reference device: Pixel 9 Pro (960×2142px, 360 DPI)
class ResponsiveHelper {
  /// Get the current screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < Breakpoints.smallMax) {
      return ScreenSize.small;
    } else if (width < Breakpoints.mediumMax) {
      return ScreenSize.medium;
    } else if (width < Breakpoints.largeMax) {
      return ScreenSize.large;
    } else {
      return ScreenSize.extraLarge;
    }
  }
  
  /// Get the device type (phone, tablet, foldable)
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= Breakpoints.foldableMinWidth) {
      return DeviceType.foldable;
    } else if (width >= Breakpoints.tabletMinWidth) {
      return DeviceType.tablet;
    } else {
      return DeviceType.phone;
    }
  }
  
  /// Get responsive width based on reference device (960px)
  /// 
  /// Example: getResponsiveWidth(context, 500) on a 480px wide device
  /// will return 250 (scaled down proportionally)
  static double getResponsiveWidth(BuildContext context, double width) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (width / ReferenceDevice.width) * screenWidth;
  }
  
  /// Get responsive height based on reference device (2142px)
  /// 
  /// Example: getResponsiveHeight(context, 650) on a 1600px tall device
  /// will scale proportionally
  static double getResponsiveHeight(BuildContext context, double height) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (height / ReferenceDevice.height) * screenHeight;
  }
  
  /// Get responsive font size with smart scaling
  /// 
  /// Scales between 0.8x and 1.2x based on screen width
  /// Ensures readability on all devices
  static double getResponsiveFontSize(BuildContext context, double fontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = (screenWidth / ReferenceDevice.width).clamp(0.8, 1.2);
    return fontSize * scaleFactor;
  }
  
  /// Get responsive padding that scales with screen size
  static EdgeInsets getResponsivePadding(
    BuildContext context,
    EdgeInsets padding,
  ) {
    return EdgeInsets.only(
      left: getResponsiveWidth(context, padding.left),
      top: getResponsiveHeight(context, padding.top),
      right: getResponsiveWidth(context, padding.right),
      bottom: getResponsiveHeight(context, padding.bottom),
    );
  }
  
  /// Get responsive symmetric padding
  static EdgeInsets getResponsiveSymmetricPadding(
    BuildContext context, {
    double? horizontal,
    double? vertical,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal != null 
          ? getResponsiveWidth(context, horizontal)
          : 0,
      vertical: vertical != null
          ? getResponsiveHeight(context, vertical)
          : 0,
    );
  }
  
  /// Get responsive spacing (for SizedBox height/width)
  static double getResponsiveSpacing(
    BuildContext context,
    double spacing, {
    bool isHorizontal = false,
  }) {
    if (isHorizontal) {
      return getResponsiveWidth(context, spacing);
    } else {
      return getResponsiveHeight(context, spacing);
    }
  }
  
  /// Get responsive size for icons
  /// Icons scale less aggressively than text
  static double getResponsiveIconSize(BuildContext context, double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = (screenWidth / ReferenceDevice.width).clamp(0.85, 1.15);
    return size * scaleFactor;
  }
  
  /// Get responsive border radius
  static double getResponsiveRadius(BuildContext context, double radius) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (radius / ReferenceDevice.width) * screenWidth;
  }
  
  /// Get scale factor for the current device
  /// Returns a value between 0.8 and 1.2
  static double getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth / ReferenceDevice.width).clamp(0.8, 1.2);
  }
  
  /// Get responsive size for a square widget (maintains aspect ratio)
  static double getResponsiveSquareSize(BuildContext context, double size) {
    // Use width for square sizes to maintain consistency
    return getResponsiveWidth(context, size);
  }
  
  /// Check if device is small screen
  static bool isSmallScreen(BuildContext context) {
    return getScreenSize(context) == ScreenSize.small;
  }
  
  /// Check if device is medium screen
  static bool isMediumScreen(BuildContext context) {
    return getScreenSize(context) == ScreenSize.medium;
  }
  
  /// Check if device is large screen
  static bool isLargeScreen(BuildContext context) {
    return getScreenSize(context) == ScreenSize.large;
  }
  
  /// Check if device is extra large screen
  static bool isExtraLargeScreen(BuildContext context) {
    return getScreenSize(context) == ScreenSize.extraLarge;
  }
  
  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }
  
  /// Check if device is foldable
  static bool isFoldable(BuildContext context) {
    return getDeviceType(context) == DeviceType.foldable;
  }
  
  /// Get safe area insets
  static EdgeInsets getSafeAreaInsets(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
  
  /// Get screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  /// Get screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  /// Get screen aspect ratio
  static double getAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width / size.height;
  }
  
  /// Get responsive percentage width
  /// 
  /// Example: getPercentageWidth(context, 0.5) returns 50% of screen width
  static double getPercentageWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }
  
  /// Get responsive percentage height
  /// 
  /// Example: getPercentageHeight(context, 0.3) returns 30% of screen height
  static double getPercentageHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }
  
  /// Get responsive size for bubbles (used in auth screens)
  /// Bubbles scale more aggressively to maintain visual impact
  static double getResponsiveBubbleSize(
    BuildContext context,
    double size, {
    bool useHeight = false,
  }) {
    if (useHeight) {
      final screenHeight = MediaQuery.of(context).size.height;
      final scaleFactor = (screenHeight / ReferenceDevice.height).clamp(0.7, 1.3);
      return size * scaleFactor;
    } else {
      final screenWidth = MediaQuery.of(context).size.width;
      final scaleFactor = (screenWidth / ReferenceDevice.width).clamp(0.7, 1.3);
      return size * scaleFactor;
    }
  }
  
  /// Get responsive position offset (for absolute positioning)
  static Offset getResponsiveOffset(
    BuildContext context,
    double left,
    double top,
  ) {
    return Offset(
      getResponsiveWidth(context, left),
      getResponsiveHeight(context, top),
    );
  }
}

/// Extension methods for easier access to responsive helpers
extension ResponsiveExtension on BuildContext {
  /// Get responsive width
  double rw(double width) => ResponsiveHelper.getResponsiveWidth(this, width);
  
  /// Get responsive height
  double rh(double height) => ResponsiveHelper.getResponsiveHeight(this, height);
  
  /// Get responsive font size
  double rfs(double fontSize) => ResponsiveHelper.getResponsiveFontSize(this, fontSize);
  
  /// Get responsive spacing
  double rs(double spacing, {bool isHorizontal = false}) =>
      ResponsiveHelper.getResponsiveSpacing(this, spacing, isHorizontal: isHorizontal);
  
  /// Get responsive icon size
  double ris(double size) => ResponsiveHelper.getResponsiveIconSize(this, size);
  
  /// Get screen width
  double get sw => ResponsiveHelper.getScreenWidth(this);
  
  /// Get screen height
  double get sh => ResponsiveHelper.getScreenHeight(this);
  
  /// Get scale factor
  double get scale => ResponsiveHelper.getScaleFactor(this);
  
  /// Check if small screen
  bool get isSmall => ResponsiveHelper.isSmallScreen(this);
  
  /// Check if tablet
  bool get isTablet => ResponsiveHelper.isTablet(this);
}

