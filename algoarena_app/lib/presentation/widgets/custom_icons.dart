import 'package:flutter/material.dart';

/// Custom SVG icons from Figma design
class CustomIcons {
  // Calendar icon - exact from Figma
  static Widget calendar({double size = 24, Color color = Colors.black}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CalendarPainter(color: color),
      ),
    );
  }

  // Pages/Layers icon - exact from Figma
  static Widget pages({double size = 28, Color color = const Color(0xFF141B34)}) {
    return SizedBox(
      width: size,
      height: size * (23 / 28), // Maintain aspect ratio
      child: CustomPaint(
        painter: _PagesPainter(color: color),
      ),
    );
  }

  // Search/Magnifier icon - exact from Figma
  static Widget search({double size = 24, Color color = Colors.black}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SearchPainter(color: color),
      ),
    );
  }

  // User/Profile icon - exact from Figma
  static Widget profile({double size = 24, Color color = Colors.black}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ProfilePainter(color: color),
      ),
    );
  }

  // Minus/Line icon - exact from Figma
  static Widget minus({double size = 12, Color color = Colors.black}) {
    return SizedBox(
      width: size,
      height: size * (3 / 12), // Maintain aspect ratio
      child: CustomPaint(
        painter: _MinusPainter(color: color),
      ),
    );
  }
}

/// Calendar icon painter - exact SVG from Figma
class _CalendarPainter extends CustomPainter {
  final Color color;

  _CalendarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        size.width * 0.0833,
        size.width * 0.25,
        size.width * 0.9167,
        size.height * 0.9167,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(rect, paint);

    // Top line
    final topLine = Path()
      ..moveTo(size.width * 0.0833, size.height * 0.375)
      ..lineTo(size.width * 0.9167, size.height * 0.375);
    canvas.drawPath(topLine, paint);

    // Left hook
    final leftHook = Path()
      ..moveTo(size.width * 0.25, size.height * 0.0833)
      ..lineTo(size.width * 0.25, size.height * 0.3333);
    canvas.drawPath(leftHook, paint);

    // Right hook
    final rightHook = Path()
      ..moveTo(size.width * 0.75, size.height * 0.0833)
      ..lineTo(size.width * 0.75, size.height * 0.3333);
    canvas.drawPath(rightHook, paint);
  }

  @override
  bool shouldRepaint(_CalendarPainter oldDelegate) => oldDelegate.color != color;
}

/// Pages/Layers icon painter - exact SVG from Figma
class _PagesPainter extends CustomPainter {
  final Color color;

  _PagesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Back layer (right diamond shape - partial)
    final backLayerPath = Path()
      ..moveTo(size.width * 0.59, size.height * 0.0625)
      ..cubicTo(
        size.width * 0.62, size.height * 0.04,
        size.width * 0.64, size.height * 0.032,
        size.width * 0.67, size.height * 0.032,
      )
      ..cubicTo(
        size.width * 0.73, size.height * 0.032,
        size.width * 0.77, size.height * 0.099,
        size.width * 0.84, size.height * 0.234,
      );
    
    canvas.drawPath(backLayerPath, paint);

    // Front layer (complete diamond shape)
    final frontLayerPath = Path()
      ..moveTo(size.width * 0.286, size.height * 0.134)
      ..cubicTo(
        size.width * 0.36, size.height * 0.066,
        size.width * 0.4, size.height * 0.032,
        size.width * 0.464, size.height * 0.032,
      )
      ..cubicTo(
        size.width * 0.528, size.height * 0.032,
        size.width * 0.568, size.height * 0.066,
        size.width * 0.642, size.height * 0.134,
      )
      ..lineTo(size.width * 0.786, size.height * 0.3)
      ..cubicTo(
        size.width * 0.88, size.height * 0.39,
        size.width * 0.927, size.height * 0.434,
        size.width * 0.927, size.height * 0.489,
      )
      ..cubicTo(
        size.width * 0.927, size.height * 0.544,
        size.width * 0.88, size.height * 0.588,
        size.width * 0.786, size.height * 0.678,
      )
      ..lineTo(size.width * 0.642, size.height * 0.844)
      ..cubicTo(
        size.width * 0.568, size.height * 0.912,
        size.width * 0.528, size.height * 0.946,
        size.width * 0.464, size.height * 0.946,
      )
      ..cubicTo(
        size.width * 0.4, size.height * 0.946,
        size.width * 0.36, size.height * 0.912,
        size.width * 0.286, size.height * 0.844,
      )
      ..lineTo(size.width * 0.142, size.height * 0.678)
      ..cubicTo(
        size.width * 0.048, size.height * 0.588,
        size.width * 0, size.height * 0.544,
        size.width * 0, size.height * 0.489,
      )
      ..cubicTo(
        size.width * 0, size.height * 0.434,
        size.width * 0.048, size.height * 0.39,
        size.width * 0.142, size.height * 0.3,
      )
      ..close();

    canvas.drawPath(frontLayerPath, paint);
  }

  @override
  bool shouldRepaint(_PagesPainter oldDelegate) => oldDelegate.color != color;
}

/// Search/Magnifier icon painter - exact SVG from Figma
class _SearchPainter extends CustomPainter {
  final Color color;

  _SearchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Search handle line
    final handlePath = Path()
      ..moveTo(size.width * 0.77, size.height * 0.77)
      ..lineTo(size.width * 0.9167, size.height * 0.9167);
    canvas.drawPath(handlePath, paint);

    // Circle (incomplete on left side)
    final circlePath = Path()
      ..addArc(
        Rect.fromCircle(
          center: Offset(size.width * 0.479, size.height * 0.479),
          radius: size.width * 0.396,
        ),
        -0.5, // Start angle
        5.5, // Sweep angle (incomplete circle)
      );
    canvas.drawPath(circlePath, paint);
  }

  @override
  bool shouldRepaint(_SearchPainter oldDelegate) => oldDelegate.color != color;
}

/// Profile/User icon painter - exact SVG from Figma
class _ProfilePainter extends CustomPainter {
  final Color color;

  _ProfilePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Head circle
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.25),
      size.width * 0.1667,
      paint,
    );

    // Body arc (partial path)
    final bodyPath = Path()
      ..moveTo(size.width * 0.166, size.height * 0.75)
      ..cubicTo(
        size.width * 0.166, size.height * 0.625,
        size.width * 0.28, size.height * 0.542,
        size.width * 0.5, size.height * 0.542,
      )
      ..cubicTo(
        size.width * 0.72, size.height * 0.542,
        size.width * 0.834, size.height * 0.625,
        size.width * 0.834, size.height * 0.75,
      )
      ..cubicTo(
        size.width * 0.834, size.height * 0.875,
        size.width * 0.834, size.height * 0.9167,
        size.width * 0.5, size.height * 0.9167,
      );
    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(_ProfilePainter oldDelegate) => oldDelegate.color != color;
}

/// Minus/Line icon painter - exact SVG from Figma
class _MinusPainter extends CustomPainter {
  final Color color;

  _MinusPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final line = Path()
      ..moveTo(size.width * 0.125, size.height * 0.5)
      ..lineTo(size.width * 0.875, size.height * 0.5);
    
    canvas.drawPath(line, paint);
  }

  @override
  bool shouldRepaint(_MinusPainter oldDelegate) => oldDelegate.color != color;
}
