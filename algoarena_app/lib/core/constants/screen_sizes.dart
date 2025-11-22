/// Screen size categories for responsive design
enum ScreenSize {
  small,      // < 360px width or < 640px height
  medium,     // 360-414px width or 640-896px height
  large,       // 414-480px width or 896-1024px height
  extraLarge,  // > 480px width or > 1024px height
}

/// Device type categories
enum DeviceType {
  phone,
  tablet,
  foldable,
}

/// Reference device dimensions (Pixel 9 Pro - baseline)
/// This is the design reference - all dimensions scale from this
class ReferenceDevice {
  // Use logical pixels (dp) instead of physical pixels
  // Pixel 9 Pro logical width in dp (360dp is standard for most phones)
  static const double width = 360.0;  // Logical pixels (dp)
  static const double height = 800.0;  // Logical pixels (dp) - approximate
  static const double density = 360.0; // DPI
  static const double aspectRatio = width / height; // ~0.45
}

/// Screen size breakpoints
class Breakpoints {
  // Width breakpoints
  static const double smallMax = 360.0;
  static const double mediumMax = 414.0;
  static const double largeMax = 480.0;
  
  // Height breakpoints
  static const double smallHeightMax = 640.0;
  static const double mediumHeightMax = 896.0;
  static const double largeHeightMax = 1024.0;
  
  // Tablet breakpoint
  static const double tabletMinWidth = 600.0;
  
  // Foldable breakpoint
  static const double foldableMinWidth = 800.0;
}

