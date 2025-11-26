import 'package:flutter/material.dart';
import '../../utils/m3_design_system.dart';

/// Responsive scaffold that ensures UI fits all screen sizes
/// 
/// Features:
/// - Automatic safe area handling
/// - Responsive padding
/// - Scroll handling for smaller screens
/// - Keyboard-aware layout
class ResponsiveScaffold extends StatelessWidget {
  final Widget child;
  final Widget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool useSafeArea;
  final EdgeInsets? padding;
  final bool enableScrolling;
  final ScrollController? scrollController;
  final Widget? drawer;
  
  const ResponsiveScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.useSafeArea = true,
    this.padding,
    this.enableScrolling = true,
    this.scrollController,
    this.drawer,
  });
  
  @override
  Widget build(BuildContext context) {
    M3DesignSystem.init(context);
    
    Widget content = child;
    
    // Apply padding if specified
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    
    // Wrap in scrollable if enabled
    if (enableScrolling) {
      content = SingleChildScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        child: content,
      );
    }
    
    // Apply safe area if enabled
    if (useSafeArea) {
      content = SafeArea(
        child: content,
      );
    }
    
    return Scaffold(
      appBar: appBar != null ? PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: appBar!,
      ) : null,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      drawer: drawer,
    );
  }
}

/// Responsive container that adapts to screen size
/// 
/// Constrains content width on larger screens (tablets)
/// while expanding to full width on phones
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;
  final Alignment alignment;
  
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.padding,
    this.alignment = Alignment.topCenter,
  });
  
  @override
  Widget build(BuildContext context) {
    M3DesignSystem.init(context);
    
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: Padding(
          padding: padding ?? M3DesignSystem.screenPadding,
          child: child,
        ),
      ),
    );
  }
}

/// Responsive sized box that uses M3 design system spacing
class M3SizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;
  
  const M3SizedBox({
    super.key,
    this.width,
    this.height,
    this.child,
  });
  
  /// Extra small spacing (4dp)
  const M3SizedBox.xs({super.key, this.child})
      : width = null,
        height = 4;
  
  /// Small spacing (8dp)
  const M3SizedBox.s({super.key, this.child})
      : width = null,
        height = 8;
  
  /// Medium spacing (16dp)
  const M3SizedBox.m({super.key, this.child})
      : width = null,
        height = 16;
  
  /// Large spacing (24dp)
  const M3SizedBox.l({super.key, this.child})
      : width = null,
        height = 24;
  
  /// Extra large spacing (32dp)
  const M3SizedBox.xl({super.key, this.child})
      : width = null,
        height = 32;
  
  /// XXL spacing (48dp)
  const M3SizedBox.xxl({super.key, this.child})
      : width = null,
        height = 48;
  
  /// Horizontal extra small spacing (4dp)
  const M3SizedBox.hXS({super.key, this.child})
      : width = 4,
        height = null;
  
  /// Horizontal small spacing (8dp)
  const M3SizedBox.hS({super.key, this.child})
      : width = 8,
        height = null;
  
  /// Horizontal medium spacing (16dp)
  const M3SizedBox.hM({super.key, this.child})
      : width = 16,
        height = null;
  
  /// Horizontal large spacing (24dp)
  const M3SizedBox.hL({super.key, this.child})
      : width = 24,
        height = null;
  
  @override
  Widget build(BuildContext context) {
    M3DesignSystem.init(context);
    
    return SizedBox(
      width: width != null ? M3DesignSystem.dp(width!) : null,
      height: height != null ? M3DesignSystem.dp(height!) : null,
      child: child,
    );
  }
}

/// M3 Button with proper dimensions
class M3Button extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final bool isFullWidth;
  final M3ButtonStyle style;
  final Color? backgroundColor;
  final Color? foregroundColor;
  
  const M3Button({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.isFullWidth = true,
    this.style = M3ButtonStyle.filled,
    this.backgroundColor,
    this.foregroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    M3DesignSystem.init(context);
    
    final buttonChild = isLoading
        ? SizedBox(
            width: M3DesignSystem.iconSize,
            height: M3DesignSystem.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                foregroundColor ?? Colors.white,
              ),
            ),
          )
        : child;
    
    Widget button;
    
    switch (style) {
      case M3ButtonStyle.filled:
        button = FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            minimumSize: Size(
              isFullWidth ? double.infinity : M3DesignSystem.minTouchTarget,
              M3DesignSystem.buttonHeight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(M3DesignSystem.buttonRadius),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: M3DesignSystem.buttonPaddingHorizontal,
            ),
          ),
          child: buttonChild,
        );
        break;
        
      case M3ButtonStyle.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? Theme.of(context).primaryColor,
            minimumSize: Size(
              isFullWidth ? double.infinity : M3DesignSystem.minTouchTarget,
              M3DesignSystem.buttonHeight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(M3DesignSystem.buttonRadius),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: M3DesignSystem.buttonPaddingHorizontal,
            ),
          ),
          child: buttonChild,
        );
        break;
        
      case M3ButtonStyle.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor,
            minimumSize: Size(
              isFullWidth ? double.infinity : M3DesignSystem.minTouchTarget,
              M3DesignSystem.buttonHeightSmall,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: M3DesignSystem.buttonPaddingHorizontal,
            ),
          ),
          child: buttonChild,
        );
        break;
        
      case M3ButtonStyle.tonal:
        button = FilledButton.tonal(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            minimumSize: Size(
              isFullWidth ? double.infinity : M3DesignSystem.minTouchTarget,
              M3DesignSystem.buttonHeight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(M3DesignSystem.buttonRadius),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: M3DesignSystem.buttonPaddingHorizontal,
            ),
          ),
          child: buttonChild,
        );
        break;
    }
    
    return isFullWidth
        ? SizedBox(
            width: double.infinity,
            height: M3DesignSystem.buttonHeight,
            child: button,
          )
        : button;
  }
}

enum M3ButtonStyle {
  filled,
  outlined,
  text,
  tonal,
}

/// Responsive text that scales properly
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final M3TextType type;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  
  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.type = M3TextType.bodyMedium,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    M3DesignSystem.init(context);
    
    final baseStyle = _getBaseStyle();
    
    return Text(
      text,
      style: baseStyle.merge(style).copyWith(color: color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
  
  TextStyle _getBaseStyle() {
    switch (type) {
      case M3TextType.displayLarge:
        return TextStyle(fontSize: M3DesignSystem.displayLarge, fontWeight: FontWeight.w400);
      case M3TextType.displayMedium:
        return TextStyle(fontSize: M3DesignSystem.displayMedium, fontWeight: FontWeight.w400);
      case M3TextType.displaySmall:
        return TextStyle(fontSize: M3DesignSystem.displaySmall, fontWeight: FontWeight.w400);
      case M3TextType.headlineLarge:
        return TextStyle(fontSize: M3DesignSystem.headlineLarge, fontWeight: FontWeight.w400);
      case M3TextType.headlineMedium:
        return TextStyle(fontSize: M3DesignSystem.headlineMedium, fontWeight: FontWeight.w400);
      case M3TextType.headlineSmall:
        return TextStyle(fontSize: M3DesignSystem.headlineSmall, fontWeight: FontWeight.w400);
      case M3TextType.titleLarge:
        return TextStyle(fontSize: M3DesignSystem.titleLarge, fontWeight: FontWeight.w500);
      case M3TextType.titleMedium:
        return TextStyle(fontSize: M3DesignSystem.titleMedium, fontWeight: FontWeight.w500);
      case M3TextType.titleSmall:
        return TextStyle(fontSize: M3DesignSystem.titleSmall, fontWeight: FontWeight.w500);
      case M3TextType.bodyLarge:
        return TextStyle(fontSize: M3DesignSystem.bodyLarge, fontWeight: FontWeight.w400);
      case M3TextType.bodyMedium:
        return TextStyle(fontSize: M3DesignSystem.bodyMedium, fontWeight: FontWeight.w400);
      case M3TextType.bodySmall:
        return TextStyle(fontSize: M3DesignSystem.bodySmall, fontWeight: FontWeight.w400);
      case M3TextType.labelLarge:
        return TextStyle(fontSize: M3DesignSystem.labelLarge, fontWeight: FontWeight.w500);
      case M3TextType.labelMedium:
        return TextStyle(fontSize: M3DesignSystem.labelMedium, fontWeight: FontWeight.w500);
      case M3TextType.labelSmall:
        return TextStyle(fontSize: M3DesignSystem.labelSmall, fontWeight: FontWeight.w500);
    }
  }
}

enum M3TextType {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}
