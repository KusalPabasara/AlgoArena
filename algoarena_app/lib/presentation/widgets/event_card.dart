import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/event.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/responsive.dart';

/// Event Card Widget - Matches Figma design 352:2301
/// Card size: 225×160px with 18px radius
class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback onJoinToggle;

  const EventCard({
    Key? key,
    required this.event,
    required this.onTap,
    required this.onJoinToggle,
  }) : super(key: key);

  Color _getBackgroundColor() {
    switch (event.colorTheme) {
      case EventColor.purple:
        return AppColors.eventPurple;
      case EventColor.black:
        return AppColors.eventBlack;
      case EventColor.cyan:
        return AppColors.eventCyan;
      case EventColor.red:
        return AppColors.eventRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = ResponsiveHelper.getResponsiveWidth(context, 225);
    final cardHeight = ResponsiveHelper.getResponsiveHeight(context, 160);
    final avatarSize = ResponsiveHelper.getResponsiveSquareSize(context, 56);
    final dateBadgeSize = ResponsiveHelper.getResponsiveSquareSize(context, 33);
    final spacing = ResponsiveHelper.getResponsiveSpacing(context, 12);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveRadius(context, 18),
          ),
        ),
        child: Stack(
          children: [
            // Club Avatar (56×56 circle)
            Positioned(
              left: spacing,
              top: spacing,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: event.imageUrl,
                    width: avatarSize,
                    height: avatarSize,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.group,
                      size: ResponsiveHelper.getResponsiveIconSize(context, 32),
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),

            // Event Title
            Positioned(
              left: ResponsiveHelper.getResponsiveWidth(context, 76),
              top: ResponsiveHelper.getResponsiveHeight(context, 18),
              right: ResponsiveHelper.getResponsiveWidth(context, 46),
              child: Text(
                event.title,
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w800, // ExtraBold
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                  color: AppColors.black,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Event Name (2 lines max)
            Positioned(
              left: spacing,
              top: ResponsiveHelper.getResponsiveHeight(context, 46),
              right: spacing,
              child: Text(
                event.eventName,
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w600, // SemiBold
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10),
                  color: AppColors.black,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Organizer
            Positioned(
              left: spacing,
              bottom: ResponsiveHelper.getResponsiveHeight(context, 40),
              right: spacing,
              child: Text(
                event.organizer,
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w400, // Regular
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10),
                  color: AppColors.black,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Date Badge (33×33 circle)
            Positioned(
              right: spacing,
              top: spacing,
              child: Container(
                width: dateBadgeSize,
                height: dateBadgeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.black,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      event.date,
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontWeight: FontWeight.w800, // ExtraBold
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 8),
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      event.month,
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontWeight: FontWeight.w800, // ExtraBold
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 8),
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Join/Joined Button (126×30)
            Positioned(
              bottom: spacing,
              right: spacing,
              child: GestureDetector(
                onTap: onJoinToggle,
                child: Container(
                  width: ResponsiveHelper.getResponsiveWidth(context, 126),
                  height: ResponsiveHelper.getResponsiveHeight(context, 30),
                  decoration: BoxDecoration(
                    color: event.isJoined ? AppColors.goldDark : AppColors.black,
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveRadius(context, 10),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    event.isJoined ? 'Joined' : 'Join',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w700, // Bold
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10),
                      color: const Color(0xFFF3F3F3),
                      height: 3.1,
                    ),
                  ),
                ),
              ),
            ),

            // Timeline Arrow (36×26 rotated 270°)
            Positioned(
              left: spacing,
              bottom: spacing,
              child: Transform.rotate(
                angle: -math.pi / 2, // 270° clockwise
                child: CustomPaint(
                  size: Size(
                    ResponsiveHelper.getResponsiveWidth(context, 36),
                    ResponsiveHelper.getResponsiveHeight(context, 26),
                  ),
                  painter: TimelineArrowPainter(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for timeline arrow
class TimelineArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.black
      ..style = PaintingStyle.fill;

    // Draw arrow shape (simplified polygon)
    final path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width * 0.7, 0);
    path.lineTo(size.width * 0.7, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
