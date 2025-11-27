import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';

/// Custom painter for the black bubble shape (bubble 01)
class BlackBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Scale the path to fit the size
    final scaleX = size.width / 420;
    final scaleY = size.height / 468;
    
    path.moveTo(209.512 * scaleX, 42.0553 * scaleY);
    path.cubicTo(
      308.777 * scaleX, -95.1903 * scaleY,
      419.025 * scaleX, 137.404 * scaleY,
      419.025 * scaleX, 255.022 * scaleY
    );
    path.cubicTo(
      419.025 * scaleX, 372.64 * scaleY,
      325.223 * scaleX, 467.988 * scaleY,
      209.512 * scaleX, 467.988 * scaleY
    );
    path.cubicTo(
      93.8019 * scaleX, 467.988 * scaleY,
      0, 372.64 * scaleY,
      0, 255.022 * scaleY
    );
    path.cubicTo(
      0, 137.404 * scaleY,
      110.248 * scaleX, 179.301 * scaleY,
      209.512 * scaleX, 42.0553 * scaleY
    );
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the yellow bubble shape (bubble 02)
class YellowBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)  // Golden yellow
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Scale the path to fit the size
    final scaleX = size.width / 390;
    final scaleY = size.height / 468;
    
    path.moveTo(179.341 * scaleX, 41.9767 * scaleY);
    path.cubicTo(
      278.797 * scaleX, -95.0124 * scaleY,
      389.257 * scaleX, 137.147 * scaleY,
      389.257 * scaleX, 254.545 * scaleY
    );
    path.cubicTo(
      389.257 * scaleX, 371.944 * scaleY,
      295.274 * scaleX, 467.114 * scaleY,
      179.341 * scaleX, 467.114 * scaleY
    );
    path.cubicTo(
      63.4075 * scaleX, 467.114 * scaleY,
      9.00109 * scaleX, 366.119 * scaleY,
      0.562515 * scaleX, 259.095 * scaleY
    );
    path.cubicTo(
      -7.87606 * scaleX, 152.072 * scaleY,
      79.8849 * scaleX, 178.966 * scaleY,
      179.341 * scaleX, 41.9767 * scaleY
    );
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget that displays both bubbles positioned at the top left of the screen
/// like in the Figma design
class ForgotPasswordBubbles extends StatelessWidget {
  const ForgotPasswordBubbles({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize responsive utilities
    ResponsiveUtils.init(context);
    
    return Stack(
      children: [
        // Yellow bubble - larger, positioned more to the right
        Positioned(
          left: ResponsiveUtils.bw(-50),
          top: ResponsiveUtils.bh(-180),
          child: Transform.rotate(
            angle: -0.5, // Slight rotation like in Figma
            child: CustomPaint(
              size: Size(ResponsiveUtils.bs(500), ResponsiveUtils.bs(550)),
              painter: YellowBubblePainter(),
            ),
          ),
        ),
        
        // Black bubble - smaller, positioned at top left
        Positioned(
          left: ResponsiveUtils.bw(-80),
          top: ResponsiveUtils.bh(-120),
          child: Transform.rotate(
            angle: 0.3, // Slight rotation like in Figma
            child: CustomPaint(
              size: Size(ResponsiveUtils.bs(380), ResponsiveUtils.bs(420)),
              painter: BlackBubblePainter(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Back button widget with custom styling
class ForgotPasswordBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  
  const ForgotPasswordBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Initialize responsive utilities
    ResponsiveUtils.init(context);
    
    final buttonSize = ResponsiveUtils.dp(40);
    
    return GestureDetector(
      onTap: onPressed ?? () => Navigator.pop(context),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back_ios_new,
            size: ResponsiveUtils.iconSizeSmall - 2,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

/// Avatar widget with golden border
class ForgotPasswordAvatar extends StatelessWidget {
  final double? size;
  
  const ForgotPasswordAvatar({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    // Initialize responsive utilities
    ResponsiveUtils.init(context);
    
    final avatarSize = size ?? ResponsiveUtils.dp(120);
    
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFB8860B), // Golden color
          width: ResponsiveUtils.dp(3),
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/avatar.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Icon(
                Icons.person,
                size: ResponsiveUtils.dp(60),
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }
}
