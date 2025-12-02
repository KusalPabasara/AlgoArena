import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../widgets/custom_back_button.dart';
import '../../../utils/responsive_utils.dart';

/// Notifications Screen - Exact Figma Implementation
/// Source: notification/src/imports/Notifications.tsx
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _bubblesSlideAnimation;
  late Animation<double> _bubblesFadeAnimation;

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
    
    _bubblesFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    // Start animation immediately
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            // Bubbles - animated to slide in from outside
            FadeTransition(
              opacity: _bubblesFadeAnimation,
              child: SlideTransition(
                position: _bubblesSlideAnimation,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Yellow Bubble (Bubbles) - left-[-179.79px] top-[-276.58px]
                    // viewBox="0 0 551 513" - pf4ece00
                    Positioned(
                      left: ResponsiveUtils.bw(-179.79),
                      top: ResponsiveUtils.bh(-276.58),
                      child: SizedBox(
                        width: ResponsiveUtils.bs(550.345),
                        height: ResponsiveUtils.bs(512.152),
                        child: CustomPaint(
                          painter: _YellowBubblePainter(),
                        ),
                      ),
                    ),

                    // Black Bubble 01 - left-[-97.03px] top-[-298.88px], rotated 232.009°
                    // viewBox="0 0 403 443" - p36b3a180
                    Positioned(
                      left: ResponsiveUtils.bw(-97.03),
                      top: ResponsiveUtils.bh(-298.88),
                      child: SizedBox(
                        width: ResponsiveUtils.bs(596.838),
                        height: ResponsiveUtils.bs(589.973),
                        child: Center(
                          child: Transform.rotate(
                            angle: 232.009 * math.pi / 180,
                            child: SizedBox(
                              width: ResponsiveUtils.bs(402.871),
                              height: ResponsiveUtils.bs(442.65),
                              child: CustomPaint(
                                painter: _BlackBubblePainter(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Back button - left-[10px] top-[50px]
            // Back button - top left
            CustomBackButton(
              backgroundColor: Colors.black, // Dark area (image/shape background)
              iconSize: ResponsiveUtils.iconSize,
            ),

            // "Notifications" title - left-[calc(16.67%+2px)] top-[48px]
            Positioned(
              left: screenWidth * 0.1667 + ResponsiveUtils.dp(2),
              top: ResponsiveUtils.bh(48),
              child: Text(
                'Notifications',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: ResponsiveUtils.sp(50),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -ResponsiveUtils.dp(0.52),
                  height: 1.0,
                ),
              ),
            ),

            // Scrollable content - centered and aligned from both sides
            Positioned(
              left: 0,
              right: 0,
              top: ResponsiveUtils.bh(168),
              bottom: 0,
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 375),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.adaptiveHorizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Announcement Section Header
                          Text(
                            'Announcement :',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: ResponsiveUtils.sp(26),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.0,
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.spacingM),
                          
                          // Announcement Frame
                          Column(
                            children: [
                              _buildNotificationCard(
                                'Monthly meeting schedule for November is now available.',
                                'assets/images/notifications/4cab12f568771ad0b3afa40dc378bc7ed480eb86.png',
                              ),
                              SizedBox(height: ResponsiveUtils.dp(11)),
                              _buildNotificationCard(
                                'Attendance policy updated — please read the new guidelines.',
                                'assets/images/notifications/31d07557884264b1b070f971cc49466a561b5a39.png',
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUtils.spacingM),
                          
                          // See more button for Announcement
                          _buildSeeMoreButton(),
                          SizedBox(height: ResponsiveUtils.spacingXL),
                          
                          // News Section Header
                          Text(
                            'News :',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: ResponsiveUtils.sp(26),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.0,
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.spacingM),
                          
                          // News Frame
                          _buildNotificationCardRich(
                            'Leo Club of Colombo',
                            ' recognized as Best Community Service Club 2025!',
                            'assets/images/notifications/c6d5f9dff52b37a28977be041de113bc88dfa388.png',
                          ),
                          SizedBox(height: ResponsiveUtils.spacingM),
                          
                          // See more button for News
                          _buildSeeMoreButton(),
                          SizedBox(height: ResponsiveUtils.spacingXL),
                          
                          // Notifications Section Header
                          Text(
                            'Notifications :',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: ResponsiveUtils.sp(26),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.0,
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.spacingM),
                          
                          // Notifications Frame
                          Column(
                            children: [
                              _buildNotificationCard(
                                "Membership renewal due soon. Don't forget to renew before Nov 15",
                                'assets/images/notifications/4816b29d2caebc6a6bd478c7c78d68fe9b858b82.png',
                              ),
                              SizedBox(height: ResponsiveUtils.dp(11)),
                              _buildNotificationCard(
                                'New message from Club President.',
                                'assets/images/notifications/6cd6f189d2f86fcc32f0d234e0416b42a8dcf4dd.png',
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUtils.spacingM),
                          
                          // See more button for Notifications
                          _buildSeeMoreButton(),
                          SizedBox(height: ResponsiveUtils.spacingXXL),
                        ],
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

  Widget _buildNotificationCard(String text, String avatarImage) {
    return Container(
      width: double.infinity,
      height: ResponsiveUtils.dp(66),
      decoration: BoxDecoration(
        color: const Color(0x1A000000), // rgba(0,0,0,0.1)
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(20)),
      ),
      child: Row(
        children: [
          SizedBox(width: ResponsiveUtils.dp(9)),
          // Avatar with drop shadow and image - 46x46
          Container(
            width: ResponsiveUtils.dp(46),
            height: ResponsiveUtils.dp(46),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: ResponsiveUtils.dp(5),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Ellipse background - #8F7902
                Container(
                  width: ResponsiveUtils.dp(46),
                  height: ResponsiveUtils.dp(46),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF8F7902),
                  ),
                ),
                // Avatar image
                ClipOval(
                  child: Image.asset(
                    avatarImage,
                    width: ResponsiveUtils.dp(46),
                    height: ResponsiveUtils.dp(46),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: ResponsiveUtils.dp(46),
                      height: ResponsiveUtils.dp(46),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF8F7902),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: ResponsiveUtils.iconSize + 4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacingS - 2),
          // Text - ml-[61px] mt-[21px] w-[255px]
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: ResponsiveUtils.spacingM - 6,
                top: ResponsiveUtils.dp(9),
                bottom: ResponsiveUtils.dp(9),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: ResponsiveUtils.bodySmall,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCardRich(String boldText, String normalText, String avatarImage) {
    return Container(
      width: double.infinity,
      height: ResponsiveUtils.dp(66),
      decoration: BoxDecoration(
        color: const Color(0x1A000000), // rgba(0,0,0,0.1)
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(20)),
      ),
      child: Row(
        children: [
          SizedBox(width: ResponsiveUtils.dp(9)),
          // Avatar with drop shadow and image
          Container(
            width: ResponsiveUtils.dp(46),
            height: ResponsiveUtils.dp(46),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: ResponsiveUtils.dp(5),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                Container(
                  width: ResponsiveUtils.dp(46),
                  height: ResponsiveUtils.dp(46),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF8F7902),
                  ),
                ),
                ClipOval(
                  child: Image.asset(
                    avatarImage,
                    width: ResponsiveUtils.dp(46),
                    height: ResponsiveUtils.dp(46),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: ResponsiveUtils.dp(46),
                      height: ResponsiveUtils.dp(46),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF8F7902),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: ResponsiveUtils.iconSize + 4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacingS - 2),
          // Text with rich formatting
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: ResponsiveUtils.spacingM - 6,
                top: ResponsiveUtils.dp(9),
                bottom: ResponsiveUtils.dp(9),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: boldText,
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: ResponsiveUtils.bodySmall,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        height: 1.0,
                      ),
                    ),
                    TextSpan(
                      text: normalText,
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: ResponsiveUtils.bodySmall,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeeMoreButton() {
    return Container(
      width: double.infinity,
      height: ResponsiveUtils.dp(39),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E6E6),
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(14)),
      ),
      child: Center(
        child: Text(
          'See more...',
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: ResponsiveUtils.sp(15),
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: ResponsiveUtils.dp(31) / ResponsiveUtils.dp(15),
          ),
        ),
      ),
    );
  }
}

/// Yellow Bubble Painter - Exact Figma SVG path pf4ece00
/// viewBox="0 0 551 513"
class _YellowBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final path = Path();
    final scaleX = size.width / 551;
    final scaleY = size.height / 513;

    // M448.995 310.483C533.605 447.601 289.917 463.466 186.768 421.792C83.619 380.117 33.7843 262.714 75.4592 159.564C117.134 56.4154 225.428 43.8604 322.495 74.3444C419.562 104.828 364.385 173.365 448.995 310.483Z
    path.moveTo(448.995 * scaleX, 310.483 * scaleY);
    path.cubicTo(
      533.605 * scaleX, 447.601 * scaleY,
      289.917 * scaleX, 463.466 * scaleY,
      186.768 * scaleX, 421.792 * scaleY,
    );
    path.cubicTo(
      83.619 * scaleX, 380.117 * scaleY,
      33.7843 * scaleX, 262.714 * scaleY,
      75.4592 * scaleX, 159.564 * scaleY,
    );
    path.cubicTo(
      117.134 * scaleX, 56.4154 * scaleY,
      225.428 * scaleX, 43.8604 * scaleY,
      322.495 * scaleX, 74.3444 * scaleY,
    );
    path.cubicTo(
      419.562 * scaleX, 104.828 * scaleY,
      364.385 * scaleX, 173.365 * scaleY,
      448.995 * scaleX, 310.483 * scaleY,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Black Bubble 01 Painter - Exact Figma SVG path p36b3a180
/// viewBox="0 0 403 443"
class _BlackBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final path = Path();
    final scaleX = size.width / 403;
    final scaleY = size.height / 443;

    // M201.436 39.7783C296.874 -90.0363 402.871 129.964 402.871 241.214C402.871 352.464 312.686 442.65 201.436 442.65C90.1858 442.65 0 352.464 0 241.214C0 129.964 105.998 169.593 201.436 39.7783Z
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
