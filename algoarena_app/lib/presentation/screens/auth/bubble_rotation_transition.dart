import 'package:flutter/material.dart';

/// Custom page route with bubble rotation animation
class BubbleRotationPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  BubbleRotationPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 800),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Smooth curve for rotation
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
              reverseCurve: Curves.easeInOut,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
          // Remove white background flash
          opaque: false,
          barrierColor: Colors.transparent,
        );
}

/// Widget wrapper that provides rotation animation during transition
class AnimatedBubbleWrapper extends StatelessWidget {
  final Widget child;
  final double fromAngle;
  final double toAngle;
  final Animation<double>? animation;

  const AnimatedBubbleWrapper({
    super.key,
    required this.child,
    required this.fromAngle,
    required this.toAngle,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    if (animation == null) {
      return Transform.rotate(
        angle: toAngle * 3.14159 / 180,
        child: child,
      );
    }

    return AnimatedBuilder(
      animation: animation!,
      builder: (context, _) {
        final currentAngle = fromAngle + (toAngle - fromAngle) * animation!.value;
        return Transform.rotate(
          angle: currentAngle * 3.14159 / 180,
          child: child,
        );
      },
    );
  }
}

