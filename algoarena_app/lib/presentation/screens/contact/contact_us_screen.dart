import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '../../widgets/custom_back_button.dart';
import '../../../utils/responsive_utils.dart';

/// Contact Us Screen - Exact Figma Implementation from Contact directory
/// Source: Contact/src/imports/ContactUs.tsx with svg-v4ed60z0uk.ts
/// Exact positions and styling from Figma design
class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _bubblesSlideAnimation;
  late Animation<Offset> _bottomYellowBubbleSlideAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _bubblesFadeAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Bubbles animation - coming from outside (top-left)
    _bubblesSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Bottom yellow bubble animation - coming from right outside
    _bottomYellowBubbleSlideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0), // Start from right outside
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _bubblesFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    // Content animation - coming from bottom
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    // Start animation immediately
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    try {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch URL')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _launchEmail(String email) async {
    try {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch email')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    try {
      // Remove spaces and special characters for tel: URI
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final uri = Uri.parse('tel:$cleanNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch phone')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
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
            // Top bubbles - animated to slide in from top-left
            FadeTransition(
              opacity: _bubblesFadeAnimation,
              child: SlideTransition(
                position: _bubblesSlideAnimation,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
            // Bubble 02 - Yellow top left, rotated 235.784°
            // Position: left-[-121px] top-[-254px]
            Positioned(
                      left: -31,
                      top: -204,
                    child: Transform.rotate(
                        angle: 220.784 * math.pi / 180,
                      child: SizedBox(
                        width: 373.531,
                        height: 442.65,
                        child: CustomPaint(
                          painter: _Bubble02Painter(),
                        ),
                      ),
              ),
            ),
            
            // Bubble 01 - Black top left, rotated 234.398°
            // Position: left-[-139px] top-[-304px]
            Positioned(
                      left: -59,
                      top: -234,
                    child: Transform.rotate(
                        angle: 224.398 * math.pi / 180,
                      child: SizedBox(
                        width: 402.871,
                        height: 442.65,
                        child: CustomPaint(
                          painter: _Bubble01Painter(),
                        ),
                      ),
                    ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bubble 04 - Yellow bottom right, rotated 90°
            // This bubble comes from right outside (separate from top bubbles)
            Positioned(
              left: screenWidth * 0.5 + 5.69,
              top: 560.44,
              child: FadeTransition(
                opacity: _bubblesFadeAnimation,
                child: SlideTransition(
                  position: _bottomYellowBubbleSlideAnimation,
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
                ),
              ),
            ),
            
            // Back button - using CustomBackButton from search tab
            CustomBackButton(
              backgroundColor: Colors.black, // Dark background, so button will be white
              iconSize: 24,
            ),
            
            // "Contact Us" title - outside the transparent box
            Positioned(
              left: screenWidth * 0.1667 + ResponsiveUtils.dp(2),
              top: ResponsiveUtils.bh(48),
              child: Text(
                'Contact Us',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: ResponsiveUtils.dp(50),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -ResponsiveUtils.dp(0.52),
                  height: 1.0,
                ),
              ),
            ),
            
            // Content - animated to slide up from bottom (inside transparent box)
            Positioned(
              left: 0,
              right: 0,
              top: ResponsiveUtils.bh(155),
              bottom: 0,
              child: FadeTransition(
                opacity: _contentFadeAnimation,
                child: SlideTransition(
                  position: _contentSlideAnimation,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: ResponsiveUtils.dp(20)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(ResponsiveUtils.r(35)),
                        child: Container(
                          width: ResponsiveUtils.dp(375),
                          constraints: BoxConstraints(
                            maxHeight: screenHeight - ResponsiveUtils.bh(155) - MediaQuery.of(context).padding.bottom - ResponsiveUtils.dp(40),
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1), // Transparent background
                            borderRadius: BorderRadius.circular(ResponsiveUtils.r(35)),
                          ),
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUtils.spacingM + ResponsiveUtils.dp(4),
                                vertical: ResponsiveUtils.spacingM - ResponsiveUtils.dp(6),
                              ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                  SizedBox(height: ResponsiveUtils.dp(20)),
                                  
                                  // Phone Section
                                  Row(
                children: [
                                      Icon(
                                        Icons.phone_rounded,
                                        size: 24,
                                        color: Colors.black87,
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
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () => _launchPhone('+94 112 682 733'),
                                    borderRadius: BorderRadius.circular(15),
              child: Container(
                                      width: double.infinity,
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
                                  const SizedBox(height: 20),
                                  
                                  // Email Section
                                  Row(
                children: [
                                      Icon(
                                        Icons.email_rounded,
                                        size: 24,
                                        color: Colors.black87,
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
                                  const SizedBox(height: 8),
                                  InkWell(
                onTap: () => _launchEmail('leodistrict306@gmail.com'),
                                    borderRadius: BorderRadius.circular(15),
                child: Container(
                                      width: double.infinity,
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
                    ),
                  ),
                ),
              ),
                                  const SizedBox(height: 20),
            
                                  // Address Section
                                  Row(
                children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: 24,
                                        color: Colors.black87,
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
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
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
                                  const SizedBox(height: 20),
            
                                  // Website Section
                                  Row(
                children: [
                                      Icon(
                                        Icons.language_rounded,
                                        size: 24,
                                        color: Colors.black87,
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
                                  const SizedBox(height: 8),
                                  InkWell(
                onTap: () => _launchUrl('https://www.leodistrict306.org'),
                                    borderRadius: BorderRadius.circular(15),
                child: Container(
                                      width: double.infinity,
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
                    ),
                  ),
                ),
              ),
                                  const SizedBox(height: 20),
            
                                  // "Follow us on" text
                                  const Text(
                'Follow us on',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
                                  const SizedBox(height: 12),
            
                                  // Social Media Buttons
                                  Row(
                                    children: [
                                      GestureDetector(
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
                                              Icon(
                                                Icons.facebook,
                                                size: 24,
                                                color: Colors.white,
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
                                      const SizedBox(width: 12),
                                      GestureDetector(
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
                                              Icon(
                                                Icons.business_center_rounded,
                                                size: 24,
                                                color: Colors.white,
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
                                    ],
                                  ),
                                  SizedBox(height: ResponsiveUtils.dp(20)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
                    ),
                  ),
                ),
                ),
              ),
            ),
          ],
        ),
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
