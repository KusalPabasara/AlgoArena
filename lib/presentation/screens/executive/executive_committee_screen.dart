import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Executive Committee Screen - Exact Figma Implementation from Executive directory
/// Source: Executive/src/imports/ExecutiveCommittee.tsx with svg-k2kanhb3fa.ts
/// Exact positions and styling from Figma design
class ExecutiveCommitteeScreen extends StatelessWidget {
  const ExecutiveCommitteeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Bubble 04 - Yellow bottom right, rotated 110°
            // Position: left-[calc(41.67%-7.92px)] top-[495.4px]
            Positioned(
              left: screenWidth * 0.4167 - 7.92,
              top: 495.4,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.rotate(
                      angle: 110 * math.pi / 180,
                      child: SizedBox(
                        width: 353.53,
                        height: 442.65,
                        child: CustomPaint(
                          painter: _Bubble04Painter(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Bubble 02 - Yellow top left, rotated 235.784°
            // Position: left-[-63px] top-[-230px]
            Positioned(
              left: -63,
              top: -230,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.rotate(
                      angle: 235.784 * math.pi / 180,
                      child: SizedBox(
                        width: 373.531,
                        height: 442.65,
                        child: CustomPaint(
                          painter: _Bubble02Painter(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Bubble 01 - Black top left, rotated 220°
            // Position: left-[-125.35px] top-[-264.4px]
            Positioned(
              left: -125.35,
              top: -264.4,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.rotate(
                      angle: 220 * math.pi / 180,
                      child: SizedBox(
                        width: 402.871,
                        height: 442.65,
                        child: CustomPaint(
                          painter: _Bubble01Painter(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Back button - left-[10px] top-[50px]
            Positioned(
              left: 10,
              top: 50,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 50,
                  height: 53,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
            
            // "Executive Committee" title - Figma: left-[calc(16.67%+2px)] top-[48px], WHITE
            Positioned(
              left: screenWidth * 0.1667 + 2,
              top: 48,
              child: const Text(
                'Executive \nCommittee',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.52,
                  height: 1.0,
                ),
              ),
            ),
            
            // Scrollable content frame - Figma: left-[calc(8.33%-10.5px)] top-[175px] 355×659px
            Positioned(
              left: screenWidth * 0.0833 - 10.5,
              top: 175,
              child: SizedBox(
                width: 355,
                height: 659,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Group - Introduction box at top-[28px] relative
                      const SizedBox(height: 28),
                      Container(
                        margin: const EdgeInsets.only(left: 2),
                        width: 353,
                        height: 219,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0x1A000000),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          'The Executive Committee of LEO District 306 is the primary leadership body entrusted with overseeing district operations, ensuring organizational discipline, and guiding the strategic direction of all Leo clubs. Each member of the committee plays a vital role in upholding the district\'s standards and driving initiatives that contribute to youth development and community service.\n\n      Aligned with the district theme "Strive to Thrive," the Executive Committee is committed to fostering excellence, strengthening inter-club collaboration, and supporting the personal and professional growth of every Leo within the district.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            height: 1.33,
                          ),
                        ),
                      ),
                      
                      // Group1 - Positions title at top-[263px] relative
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.only(left: 9),
                        child: Text(
                          'Executive Committee Positions',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            height: 1.33,
                          ),
                        ),
                      ),
                      
                      // Positions box at top-[286px] relative
                      const SizedBox(height: 7),
                      Container(
                        width: 353,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0x1A000000),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildSectionTitle('District Leadership'),
                            _buildBulletItem('District President'),
                            _buildBulletItem('District Vice President'),
                            _buildBulletItem('Immediate Past District President'),
                            const SizedBox(height: 8),
                            _buildSectionTitle('Administrative Officers'),
                            _buildBulletItem('District Secretary'),
                            _buildBulletItem('Assistant District Secretary'),
                            _buildBulletItem('District Treasurer'),
                            _buildBulletItem('Assistant District Treasurer'),
                            const SizedBox(height: 8),
                            _buildSectionTitle('Program & Operations'),
                            _buildBulletItem('District Chairperson – Membership'),
                            _buildBulletItem('District Chairperson – Leadership Development'),
                            _buildBulletItem('District Chairperson – Service Activities'),
                            _buildBulletItem('District Coordinator – IT & Digital Media'),
                            _buildBulletItem('District Coordinator – Public Relations'),
                            _buildBulletItem('District Coordinator – Special Projects'),
                            const SizedBox(height: 8),
                            _buildSectionTitle('Regional & Zone Leadership'),
                            _buildBulletItem('Regional Chairpersons (All Regions)'),
                            _buildBulletItem('Zone Chairpersons (All Zones)'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50), // Extra space for scroll
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom bar - left-[calc(33.33%-3px)] top-[863px]
            Positioned(
              left: screenWidth * 0.3333 - 3,
              top: 863,
              child: Container(
                width: 145.848,
                height: 5.442,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(34),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Raleway',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          height: 1.33,
        ),
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.33,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.33,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Black Bubble 01 Painter - Exact Figma SVG path p36b3a180
/// viewBox="0 0 403 443"
class _Bubble01Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final scaleX = size.width / 403;
    final scaleY = size.height / 443;
    
    path.moveTo(201.436 * scaleX, 39.7783 * scaleY);
    path.cubicTo(
      296.874 * scaleX, -90.0363 * scaleY,
      402.871 * scaleX, 129.964 * scaleY,
      402.871 * scaleX, 241.214 * scaleY,
    );
    path.cubicTo(
      402.871 * scaleX, 352.464 * scaleY,
      312.686 * scaleX, 442.65 * scaleY,
      201.436 * scaleX, 442.65 * scaleY,
    );
    path.cubicTo(
      90.1858 * scaleX, 442.65 * scaleY,
      0 * scaleX, 352.464 * scaleY,
      0 * scaleX, 241.214 * scaleY,
    );
    path.cubicTo(
      0 * scaleX, 129.964 * scaleY,
      105.998 * scaleX, 169.593 * scaleY,
      201.436 * scaleX, 39.7783 * scaleY,
    );
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Yellow Bubble 02 Painter - Exact Figma SVG path p2c5a2d80
/// viewBox="0 0 374 443"
class _Bubble02Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final scaleX = size.width / 374;
    final scaleY = size.height / 443;
    
    path.moveTo(172.096 * scaleX, 39.7783 * scaleY);
    path.cubicTo(
      267.534 * scaleX, -90.0363 * scaleY,
      373.531 * scaleX, 129.964 * scaleY,
      373.531 * scaleX, 241.214 * scaleY,
    );
    path.cubicTo(
      373.531 * scaleX, 352.464 * scaleY,
      283.346 * scaleX, 442.65 * scaleY,
      172.096 * scaleX, 442.65 * scaleY,
    );
    path.cubicTo(
      60.8459 * scaleX, 442.65 * scaleY,
      8.63746 * scaleX, 346.944 * scaleY,
      0.53979 * scaleX, 245.526 * scaleY,
    );
    path.cubicTo(
      -7.55788 * scaleX, 144.107 * scaleY,
      76.6577 * scaleX, 169.593 * scaleY,
      172.096 * scaleX, 39.7783 * scaleY,
    );
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Yellow Bubble 04 Painter - Exact Figma SVG path p2ec28100
/// viewBox="0 0 354 443"
class _Bubble04Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final scaleX = size.width / 354;
    final scaleY = size.height / 443;
    
    path.moveTo(162.881 * scaleX, 39.7783 * scaleY);
    path.cubicTo(
      253.208 * scaleX, -90.0363 * scaleY,
      353.53 * scaleX, 129.964 * scaleY,
      353.53 * scaleX, 241.214 * scaleY,
    );
    path.cubicTo(
      353.53 * scaleX, 352.464 * scaleY,
      268.173 * scaleX, 442.65 * scaleY,
      162.881 * scaleX, 442.65 * scaleY,
    );
    path.cubicTo(
      57.5878 * scaleX, 442.65 * scaleY,
      8.17495 * scaleX, 346.944 * scaleY,
      0.510886 * scaleX, 245.526 * scaleY,
    );
    path.cubicTo(
      -7.15317 * scaleX, 144.107 * scaleY,
      72.5529 * scaleX, 169.593 * scaleY,
      162.881 * scaleX, 39.7783 * scaleY,
    );
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
