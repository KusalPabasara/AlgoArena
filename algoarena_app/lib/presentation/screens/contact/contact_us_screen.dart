import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

/// Contact Us Screen - Exact Figma Implementation from Contact directory
/// Source: Contact/src/imports/ContactUs.tsx with svg-v4ed60z0uk.ts
/// Exact positions and styling from Figma design
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

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
            // Bubble 04 - Yellow bottom right, rotated 90°
            // Position: left-[calc(50%+5.69px)] top-[560.44px]
            Positioned(
              left: screenWidth * 0.5 + 5.69,
              top: 560.44,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.rotate(
                      angle: 90 * math.pi / 180,
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
            // Position: left-[-121px] top-[-254px]
            Positioned(
              left: -121,
              top: -254,
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
            
            // Bubble 01 - Black top left, rotated 234.398°
            // Position: left-[-139px] top-[-304px]
            Positioned(
              left: -139,
              top: -304,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.rotate(
                      angle: 234.398 * math.pi / 180,
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
            
            // "Contact Us" title - Figma: left-[calc(16.67%+2px)] top-[48px], WHITE
            Positioned(
              left: screenWidth * 0.1667 + 2,
              top: 48,
              child: const Text(
                'Contact Us',
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
            
            // Phone Section - top-[187px]
            // Label: left-[calc(8.33%+16px)] top-[187px]
            Positioned(
              left: screenWidth * 0.0833 + 16,
              top: 187,
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CustomPaint(painter: _PhoneIconPainter()),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Phone',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Phone input box - left-[calc(8.33%+16px)] top-[214px] 302×46px
            Positioned(
              left: screenWidth * 0.0833 + 16,
              top: 214,
              child: Container(
                width: 302,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0x1A000000),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 14),
                child: const Text(
                  '+94 112 682 733',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF626262),
                  ),
                ),
              ),
            ),
            
            // Email Section - top-[267px]
            // Label: left-[calc(8.33%+16px)] top-[267px]
            Positioned(
              left: screenWidth * 0.0833 + 16,
              top: 267,
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CustomPaint(painter: _EmailIconPainter()),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Email input box - left-[calc(8.33%+16px)] top-[294px] 302×46px
            Positioned(
              left: screenWidth * 0.0833 + 16,
              top: 294,
              child: GestureDetector(
                onTap: () => _launchEmail('leodistrict306@gmail.com'),
                child: Container(
                  width: 302,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0x1A000000),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 14),
                  child: const Text(
                    'leodistrict306@gmail.com',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF626262),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
            
            // Address Section - top-[347px]
            // Label: left-[calc(8.33%+16px)] top-[347px]
            Positioned(
              left: screenWidth * 0.0833 + 16,
              top: 347,
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CustomPaint(painter: _AddressIconPainter()),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Address',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Address input box - left-[calc(8.33%+16px)] top-[371px] 302×73px (taller for multiline)
            Positioned(
              left: screenWidth * 0.0833 + 16,
              top: 371,
              child: Container(
                width: 302,
                height: 73,
                decoration: BoxDecoration(
                  color: const Color(0x1A000000),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: const Text(
                  'Lions Headquarters\nNo. 114, Wijerama Road\nColombo 07, Sri Lanka',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF626262),
                    height: 1.5,
                  ),
                ),
              ),
            ),
            
            // Website Section - top-[451px]
            // Label: left-[calc(8.33%+16px)] top-[451px]
            Positioned(
              left: screenWidth * 0.0833 + 16,
              top: 451,
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CustomPaint(painter: _WebsiteIconPainter()),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Website',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Website input box - left-[calc(8.33%+16px)] top-[478px] 302×46px
            Positioned(
              left: screenWidth * 0.0833 + 16,
              top: 478,
              child: GestureDetector(
                onTap: () => _launchUrl('https://www.leodistrict306.org'),
                child: Container(
                  width: 302,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0x1A000000),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 14),
                  child: const Text(
                    'www.leodistrict306.org',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF626262),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
            
            // "Follow us on" text - top-[527px]
            // Position: left-[calc(8.33%+16px)] top-[527px]
            Positioned(
              left: screenWidth * 0.0833 + 16,
              top: 527,
              child: const Text(
                'Follow us on',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            
            // Facebook Button - top-[561px]
            // Position: left-[calc(8.33%+16px)] top-[561px] 143×41px bg-[#3747d6]
            Positioned(
              left: screenWidth * 0.0833 + 16,
              top: 561,
              child: GestureDetector(
                onTap: () => _launchUrl('https://www.facebook.com/leodistrict306'),
                child: Container(
                  width: 143,
                  height: 41,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3747D6),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 35,
                        height: 35,
                        child: CustomPaint(painter: _FacebookIconPainter()),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Facebook',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // LinkedIn Button - top-[561px]
            // Position: left-[calc(8.33%+175px)] top-[561px] 143×41px bg-[#85a8fb]
            Positioned(
              left: screenWidth * 0.0833 + 175,
              top: 561,
              child: GestureDetector(
                onTap: () => _launchUrl('https://www.linkedin.com/company/leo-district-306'),
                child: Container(
                  width: 143,
                  height: 41,
                  decoration: BoxDecoration(
                    color: const Color(0xFF85A8FB),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 29,
                        height: 30,
                        child: CustomPaint(painter: _LinkedInIconPainter()),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'LinkedIn',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // App Version Box - top-[879px] (bottom area)
            // Position: left-[calc(8.33%+8px)] top-[879px] 332×48px with dashed border
            Positioned(
              left: screenWidth * 0.0833 + 8,
              top: screenHeight - 53,
              child: Container(
                width: 332,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: CustomPaint(
                  painter: _DashedBorderPainter(),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'AlgoArena',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Bottom bar - left-[calc(33.33%-3px)] top-[863px]
            Positioned(
              left: screenWidth * 0.3333 - 3,
              top: screenHeight - 69,
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
}

/// Dashed Border Painter for App Version Box
class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dashed border visual already achieved with border in container
    // This painter is kept for potential custom dashed drawing
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

/// Phone Icon Painter - Exact Figma SVG path pfe13400
class _PhoneIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final scale = size.width / 24;
    
    path.moveTo(16.5562 * scale, 12.9062 * scale);
    path.lineTo(16.1007 * scale, 13.359 * scale);
    path.cubicTo(16.1007 * scale, 13.359 * scale, 15.0181 * scale, 14.4355 * scale, 12.0631 * scale, 11.4972 * scale);
    path.cubicTo(9.10812 * scale, 8.55901 * scale, 10.1907 * scale, 7.48257 * scale, 10.1907 * scale, 7.48257 * scale);
    path.lineTo(10.4775 * scale, 7.19738 * scale);
    path.cubicTo(11.1841 * scale, 6.49484 * scale, 11.2507 * scale, 5.36691 * scale, 10.6342 * scale, 4.54348 * scale);
    path.lineTo(9.37326 * scale, 2.85908 * scale);
    path.cubicTo(8.61028 * scale, 1.83992 * scale, 7.13596 * scale, 1.70529 * scale, 6.26145 * scale, 2.57483 * scale);
    path.lineTo(4.69185 * scale, 4.13552 * scale);
    path.cubicTo(4.25823 * scale, 4.56668 * scale, 3.96765 * scale, 5.12559 * scale, 4.00289 * scale, 5.74561 * scale);
    path.cubicTo(4.09304 * scale, 7.33182 * scale, 4.81071 * scale, 10.7447 * scale, 8.81536 * scale, 14.7266 * scale);
    path.cubicTo(13.0621 * scale, 18.9492 * scale, 17.0468 * scale, 19.117 * scale, 18.6763 * scale, 18.9651 * scale);
    path.cubicTo(19.1917 * scale, 18.9171 * scale, 19.6399 * scale, 18.6546 * scale, 20.0011 * scale, 18.2954 * scale);
    path.lineTo(21.4217 * scale, 16.883 * scale);
    path.cubicTo(22.3806 * scale, 15.9295 * scale, 22.1102 * scale, 14.2949 * scale, 20.8833 * scale, 13.628 * scale);
    path.lineTo(18.9728 * scale, 12.5894 * scale);
    path.cubicTo(18.1672 * scale, 12.1515 * scale, 17.1858 * scale, 12.2801 * scale, 16.5562 * scale, 12.9062 * scale);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Email Icon Painter - Exact Figma SVG path pb81ae00
class _EmailIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1D1B20)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final scale = size.width / 24;
    
    path.moveTo(19 * scale, 8 * scale);
    path.cubicTo(18.1667 * scale, 8 * scale, 17.4583 * scale, 7.70833 * scale, 16.875 * scale, 7.125 * scale);
    path.cubicTo(16.2917 * scale, 6.54167 * scale, 16 * scale, 5.83333 * scale, 16 * scale, 5 * scale);
    path.cubicTo(16 * scale, 4.16667 * scale, 16.2917 * scale, 3.45833 * scale, 16.875 * scale, 2.875 * scale);
    path.cubicTo(17.4583 * scale, 2.29167 * scale, 18.1667 * scale, 2 * scale, 19 * scale, 2 * scale);
    path.cubicTo(19.8333 * scale, 2 * scale, 20.5417 * scale, 2.29167 * scale, 21.125 * scale, 2.875 * scale);
    path.cubicTo(21.7083 * scale, 3.45833 * scale, 22 * scale, 4.16667 * scale, 22 * scale, 5 * scale);
    path.cubicTo(22 * scale, 5.83333 * scale, 21.7083 * scale, 6.54167 * scale, 21.125 * scale, 7.125 * scale);
    path.cubicTo(20.5417 * scale, 7.70833 * scale, 19.8333 * scale, 8 * scale, 19 * scale, 8 * scale);
    path.close();
    
    path.moveTo(4 * scale, 20 * scale);
    path.cubicTo(3.45 * scale, 20 * scale, 2.97917 * scale, 19.8042 * scale, 2.5875 * scale, 19.4125 * scale);
    path.cubicTo(2.19583 * scale, 19.0208 * scale, 2 * scale, 18.55 * scale, 2 * scale, 18 * scale);
    path.lineTo(2 * scale, 6 * scale);
    path.cubicTo(2 * scale, 5.45 * scale, 2.19583 * scale, 4.97917 * scale, 2.5875 * scale, 4.5875 * scale);
    path.cubicTo(2.97917 * scale, 4.19583 * scale, 3.45 * scale, 4 * scale, 4 * scale, 4 * scale);
    path.lineTo(14.1 * scale, 4 * scale);
    path.cubicTo(14.0333 * scale, 4.33333 * scale, 14 * scale, 4.66667 * scale, 14 * scale, 5 * scale);
    path.cubicTo(14 * scale, 5.33333 * scale, 14.0333 * scale, 5.66667 * scale, 14.1 * scale, 6 * scale);
    path.cubicTo(14.2167 * scale, 6.53333 * scale, 14.4083 * scale, 7.02917 * scale, 14.675 * scale, 7.4875 * scale);
    path.cubicTo(14.9417 * scale, 7.94583 * scale, 15.2667 * scale, 8.35 * scale, 15.65 * scale, 8.7 * scale);
    path.lineTo(12 * scale, 11 * scale);
    path.lineTo(4 * scale, 6 * scale);
    path.lineTo(4 * scale, 8 * scale);
    path.lineTo(12 * scale, 13 * scale);
    path.lineTo(17.275 * scale, 9.7 * scale);
    path.cubicTo(17.5583 * scale, 9.8 * scale, 17.8417 * scale, 9.875 * scale, 18.125 * scale, 9.925 * scale);
    path.cubicTo(18.4083 * scale, 9.975 * scale, 18.7 * scale, 10 * scale, 19 * scale, 10 * scale);
    path.cubicTo(19.5333 * scale, 10 * scale, 20.0583 * scale, 9.91667 * scale, 20.575 * scale, 9.75 * scale);
    path.cubicTo(21.0917 * scale, 9.58333 * scale, 21.5667 * scale, 9.33333 * scale, 22 * scale, 9 * scale);
    path.lineTo(22 * scale, 18 * scale);
    path.cubicTo(22 * scale, 18.55 * scale, 21.8042 * scale, 19.0208 * scale, 21.4125 * scale, 19.4125 * scale);
    path.cubicTo(21.0208 * scale, 19.8042 * scale, 20.55 * scale, 20 * scale, 20 * scale, 20 * scale);
    path.lineTo(4 * scale, 20 * scale);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Address Icon Painter - Exact Figma SVG path p3fada380
class _AddressIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final scaleX = size.width / 24;
    final scaleY = size.height / 24;
    
    final path = Path();
    path.moveTo(3 * scaleX, 0 * scaleY);
    path.cubicTo(2.44772 * scaleX, 0 * scaleY, 2 * scaleX, 0.447715 * scaleY, 2 * scaleX, 1 * scaleY);
    path.lineTo(2 * scaleX, 21 * scaleY);
    path.cubicTo(2 * scaleX, 21.5523 * scaleY, 2.44772 * scaleX, 22 * scaleY, 3 * scaleX, 22 * scaleY);
    path.lineTo(19 * scaleX, 22 * scaleY);
    path.cubicTo(19.5523 * scaleX, 22 * scaleY, 20 * scaleX, 21.5523 * scaleY, 20 * scaleX, 21 * scaleY);
    path.lineTo(20 * scaleX, 1 * scaleY);
    path.cubicTo(20 * scaleX, 0.447715 * scaleY, 19.5523 * scaleX, 0 * scaleY, 19 * scaleX, 0 * scaleY);
    path.lineTo(3 * scaleX, 0 * scaleY);
    path.close();
    
    // Head circle (cutout)
    path.moveTo(11 * scaleX, 3.5 * scaleY);
    path.cubicTo(9.067 * scaleX, 3.5 * scaleY, 7.5 * scaleX, 5.067 * scaleY, 7.5 * scaleX, 7 * scaleY);
    path.cubicTo(7.5 * scaleX, 8.933 * scaleY, 9.067 * scaleX, 10.5 * scaleY, 11 * scaleX, 10.5 * scaleY);
    path.cubicTo(12.933 * scaleX, 10.5 * scaleY, 14.5 * scaleX, 8.933 * scaleY, 14.5 * scaleX, 7 * scaleY);
    path.cubicTo(14.5 * scaleX, 5.067 * scaleY, 12.933 * scaleX, 3.5 * scaleY, 11 * scaleX, 3.5 * scaleY);
    path.close();
    
    // Body (cutout)
    path.moveTo(5 * scaleX, 17.5 * scaleY);
    path.cubicTo(5 * scaleX, 14.1863 * scaleY, 7.68629 * scaleX, 11.5 * scaleY, 11 * scaleX, 11.5 * scaleY);
    path.cubicTo(14.3137 * scaleX, 11.5 * scaleY, 17 * scaleX, 14.1863 * scaleY, 17 * scaleX, 17.5 * scaleY);
    path.cubicTo(17 * scaleX, 18.0523 * scaleY, 16.5523 * scaleX, 18.5 * scaleY, 16 * scaleX, 18.5 * scaleY);
    path.lineTo(6 * scaleX, 18.5 * scaleY);
    path.cubicTo(5.44772 * scaleX, 18.5 * scaleY, 5 * scaleX, 18.0523 * scaleY, 5 * scaleX, 17.5 * scaleY);
    path.close();
    
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Website Icon Painter - Exact Figma SVG path p36b49900
class _WebsiteIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF070707)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final scale = size.width / 24;
    
    path.moveTo(3.46447 * scale, 3.46447 * scale);
    path.cubicTo(2 * scale, 4.92893 * scale, 2 * scale, 7.28595 * scale, 2 * scale, 12 * scale);
    path.cubicTo(2 * scale, 16.714 * scale, 2 * scale, 19.0711 * scale, 3.46447 * scale, 20.5355 * scale);
    path.cubicTo(4.92893 * scale, 22 * scale, 7.28595 * scale, 22 * scale, 12 * scale, 22 * scale);
    path.cubicTo(16.714 * scale, 22 * scale, 19.0711 * scale, 22 * scale, 20.5355 * scale, 20.5355 * scale);
    path.cubicTo(22 * scale, 19.0711 * scale, 22 * scale, 16.714 * scale, 22 * scale, 12 * scale);
    path.cubicTo(22 * scale, 7.28595 * scale, 22 * scale, 4.92893 * scale, 20.5355 * scale, 3.46447 * scale);
    path.cubicTo(19.0711 * scale, 2 * scale, 16.714 * scale, 2 * scale, 12 * scale, 2 * scale);
    path.cubicTo(7.28595 * scale, 2 * scale, 4.92893 * scale, 2 * scale, 3.46447 * scale, 3.46447 * scale);
    path.close();
    
    path.moveTo(12.3975 * scale, 14.0385 * scale);
    path.lineTo(14.859 * scale, 16.4999 * scale);
    path.cubicTo(15.1138 * scale, 16.7548 * scale, 15.2413 * scale, 16.8822 * scale, 15.3834 * scale, 16.9411 * scale);
    path.cubicTo(15.573 * scale, 17.0196 * scale, 15.7859 * scale, 17.0196 * scale, 15.9755 * scale, 16.9411 * scale);
    path.cubicTo(16.1176 * scale, 16.8822 * scale, 16.2451 * scale, 16.7548 * scale, 16.4999 * scale, 16.4999 * scale);
    path.cubicTo(16.7548 * scale, 16.2451 * scale, 16.8822 * scale, 16.1176 * scale, 16.9411 * scale, 15.9755 * scale);
    path.cubicTo(17.0196 * scale, 15.7859 * scale, 17.0196 * scale, 15.573 * scale, 16.9411 * scale, 15.3834 * scale);
    path.cubicTo(16.8822 * scale, 15.2413 * scale, 16.7548 * scale, 15.1138 * scale, 16.4999 * scale, 14.859 * scale);
    path.lineTo(14.0385 * scale, 12.3975 * scale);
    path.lineTo(14.7902 * scale, 11.6459 * scale);
    path.cubicTo(15.5597 * scale, 10.8764 * scale, 15.9444 * scale, 10.4916 * scale, 15.8536 * scale, 10.0781 * scale);
    path.cubicTo(15.7628 * scale, 9.66451 * scale, 15.2522 * scale, 9.47641 * scale, 14.231 * scale, 9.10019 * scale);
    path.lineTo(10.8253 * scale, 7.84544 * scale);
    path.cubicTo(8.78816 * scale, 7.09492 * scale, 7.7696 * scale, 6.71966 * scale, 7.24463 * scale, 7.24463 * scale);
    path.cubicTo(6.71966 * scale, 7.7696 * scale, 7.09492 * scale, 8.78816 * scale, 7.84544 * scale, 10.8253 * scale);
    path.lineTo(9.10019 * scale, 14.231 * scale);
    path.cubicTo(9.47641 * scale, 15.2522 * scale, 9.66452 * scale, 15.7628 * scale, 10.0781 * scale, 15.8536 * scale);
    path.cubicTo(10.4916 * scale, 15.9444 * scale, 10.8764 * scale, 15.5597 * scale, 11.6459 * scale, 14.7902 * scale);
    path.lineTo(12.3975 * scale, 14.0385 * scale);
    path.close();
    
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Facebook Icon Painter - Exact Figma SVG path p3de92f00
class _FacebookIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final scale = size.width / 35;
    
    path.moveTo(25.8824 * scale, 2.87582 * scale);
    path.lineTo(21.5686 * scale, 2.87582 * scale);
    path.cubicTo(19.6618 * scale, 2.87582 * scale, 17.8332 * scale, 3.63328 * scale, 16.4849 * scale, 4.98159 * scale);
    path.cubicTo(15.1366 * scale, 6.32989 * scale, 14.3791 * scale, 8.15857 * scale, 14.3791 * scale, 10.0654 * scale);
    path.lineTo(14.3791 * scale, 14.3791 * scale);
    path.lineTo(10.0654 * scale, 14.3791 * scale);
    path.lineTo(10.0654 * scale, 20.1307 * scale);
    path.lineTo(14.3791 * scale, 20.1307 * scale);
    path.lineTo(14.3791 * scale, 31.634 * scale);
    path.lineTo(20.1307 * scale, 31.634 * scale);
    path.lineTo(20.1307 * scale, 20.1307 * scale);
    path.lineTo(24.4444 * scale, 20.1307 * scale);
    path.lineTo(25.8824 * scale, 14.3791 * scale);
    path.lineTo(20.1307 * scale, 14.3791 * scale);
    path.lineTo(20.1307 * scale, 10.0654 * scale);
    path.cubicTo(20.1307 * scale, 9.684 * scale, 20.2822 * scale, 9.31827 * scale, 20.5519 * scale, 9.04861 * scale);
    path.cubicTo(20.8215 * scale, 8.77894 * scale, 21.1873 * scale, 8.62745 * scale, 21.5686 * scale, 8.62745 * scale);
    path.lineTo(25.8824 * scale, 8.62745 * scale);
    path.lineTo(25.8824 * scale, 2.87582 * scale);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// LinkedIn Icon Painter - Exact Figma SVG paths p1a178100, p3749c200, p1ab13900
class _LinkedInIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final scaleX = size.width / 29;
    final scaleY = size.height / 30;
    
    // Path 1: Main body
    final path1 = Path();
    path1.moveTo(19.3333 * scaleX, 10 * scaleY);
    path1.cubicTo(21.2562 * scaleX, 10 * scaleY, 23.1002 * scaleX, 10.7902 * scaleY, 24.4599 * scaleX, 12.1967 * scaleY);
    path1.cubicTo(25.8195 * scaleX, 13.6032 * scaleY, 26.5833 * scaleX, 15.5109 * scaleY, 26.5833 * scaleX, 17.5 * scaleY);
    path1.lineTo(26.5833 * scaleX, 26.25 * scaleY);
    path1.lineTo(21.75 * scaleX, 26.25 * scaleY);
    path1.lineTo(21.75 * scaleX, 17.5 * scaleY);
    path1.cubicTo(21.75 * scaleX, 16.837 * scaleY, 21.4954 * scaleX, 16.2011 * scaleY, 21.0422 * scaleX, 15.7322 * scaleY);
    path1.cubicTo(20.589 * scaleX, 15.2634 * scaleY, 19.9743 * scaleX, 15 * scaleY, 19.3333 * scaleX, 15 * scaleY);
    path1.cubicTo(18.6924 * scaleX, 15 * scaleY, 18.0777 * scaleX, 15.2634 * scaleY, 17.6245 * scaleX, 15.7322 * scaleY);
    path1.cubicTo(17.1713 * scaleX, 16.2011 * scaleY, 16.9167 * scaleX, 16.837 * scaleY, 16.9167 * scaleX, 17.5 * scaleY);
    path1.lineTo(16.9167 * scaleX, 26.25 * scaleY);
    path1.lineTo(12.0833 * scaleX, 26.25 * scaleY);
    path1.lineTo(12.0833 * scaleX, 17.5 * scaleY);
    path1.cubicTo(12.0833 * scaleX, 15.5109 * scaleY, 12.8472 * scaleX, 13.6032 * scaleY, 14.2068 * scaleX, 12.1967 * scaleY);
    path1.cubicTo(15.5664 * scaleX, 10.7902 * scaleY, 17.4105 * scaleX, 10 * scaleY, 19.3333 * scaleX, 10 * scaleY);
    path1.close();
    canvas.drawPath(path1, paint);
    
    // Path 2: Left bar
    final path2 = Path();
    path2.moveTo(7.25 * scaleX, 11.25 * scaleY);
    path2.lineTo(2.41667 * scaleX, 11.25 * scaleY);
    path2.lineTo(2.41667 * scaleX, 26.25 * scaleY);
    path2.lineTo(7.25 * scaleX, 26.25 * scaleY);
    path2.lineTo(7.25 * scaleX, 11.25 * scaleY);
    path2.close();
    canvas.drawPath(path2, paint);
    
    // Path 3: Circle avatar
    final path3 = Path();
    path3.addOval(Rect.fromCircle(
      center: Offset(4.83333 * scaleX, 5 * scaleY),
      radius: 2.5 * ((scaleX + scaleY) / 2),
    ));
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
