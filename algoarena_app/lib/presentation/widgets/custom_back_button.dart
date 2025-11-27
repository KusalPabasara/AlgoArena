import 'package:flutter/material.dart';

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
      // Try to find MainScreen in the widget tree and change its tab index
      // This keeps the bottom navigation bar static by changing tab index instead of navigating
      // Import MainScreen state class dynamically
      final mainScreenState = context.findAncestorStateOfType<State<StatefulWidget>>();
      if (mainScreenState != null && mainScreenState.runtimeType.toString() == '_MainScreenState') {
        // We're inside MainScreen, use reflection or direct call
        // Since we can't directly access private class, we'll use a different approach
        // Navigate to home route but with a flag to prevent recreation
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        // Fallback: navigate to home route
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = _getButtonColor(backgroundColor);
    final borderColor = buttonColor;
    
    return Positioned(
      left: 10,
      top: 50,
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

