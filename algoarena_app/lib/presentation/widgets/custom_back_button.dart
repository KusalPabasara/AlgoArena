import 'package:flutter/material.dart';
import '../screens/main/main_screen.dart';
import '../../utils/responsive_utils.dart';

/// Custom back button that matches the password screen style
/// Automatically adapts color based on background:
/// - Black background → white button
/// - White/yellow background → black button
class CustomBackButton extends StatelessWidget {
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final double? iconSize;
  final double? borderWidth;
  final bool navigateToHome;

  const CustomBackButton({
    super.key,
    this.backgroundColor,
    this.onPressed,
    this.iconColor,
    this.iconSize,
    this.borderWidth,
    this.navigateToHome = false,
  });

  /// Determines button color based on background color
  Color _getButtonColor(Color? bgColor) {
    if (iconColor != null) return iconColor!;
    
    if (bgColor == null) return Colors.black;
    
    // Check if background is dark (black or very dark)
    final brightness = bgColor.computeLuminance();
    if (brightness < 0.3) {
      return Colors.white; // White button for dark backgrounds
    } else {
      return Colors.black; // Black button for light backgrounds
    }
  }

  void _handlePress(BuildContext context) {
    if (onPressed != null) {
      onPressed!();
      return;
    }
    
    if (navigateToHome) {
      // Use MainScreen's global key to switch to home tab (index 0)
      // This keeps the bottom navigation bar static by changing tab index
      final mainScreenState = MainScreen.globalKey.currentState;
      if (mainScreenState != null) {
        // Use dynamic invocation to call the public navigateToTab method
        // (needed because _MainScreenState is private but navigateToTab is public)
        try {
          (mainScreenState as dynamic).navigateToTab(0);
          return;
        } catch (e) {
          // If dynamic invocation fails, fall through to route navigation
        }
      }
      // Fallback: navigate to home route if global key is not available
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final buttonColor = _getButtonColor(backgroundColor);
    final borderColor = buttonColor;
    
    return Positioned(
      left: ResponsiveUtils.dp(10),
      top: ResponsiveUtils.bh(50),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: borderWidth ?? 2,
          ),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: buttonColor,
            size: iconSize ?? 24, // Consistent size: 24
          ),
          onPressed: () => _handlePress(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ),
    );
  }
}

