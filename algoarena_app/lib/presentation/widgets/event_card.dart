import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/event.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/image_cache_manager.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 225,
        height: 160,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            // Club Avatar (56×56 circle)
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: event.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    cacheManager: ImageCacheManager.getCacheManager(),
                    memCacheWidth: 112, // 2x for retina (56 * 2)
                    memCacheHeight: 112,
                    maxWidthDiskCache: 224,
                    maxHeightDiskCache: 224,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.group,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),

            // Event Title
            Positioned(
              left: 76,
              top: 18,
              right: 46,
              child: Text(
                event.title,
                style: const TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w800, // ExtraBold
                  fontSize: 20,
                  color: AppColors.black,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Event Name (2 lines max)
            Positioned(
              left: 12,
              top: 46,
              right: 12,
              child: Text(
                event.eventName,
                style: const TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w600, // SemiBold
                  fontSize: 10,
                  color: AppColors.black,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Organizer
            Positioned(
              left: 12,
              bottom: 40,
              right: 12,
              child: Text(
                event.organizer,
                style: const TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w400, // Regular
                  fontSize: 10,
                  color: AppColors.black,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Date Badge (33×33 circle)
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 33,
                height: 33,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.black,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      event.date,
                      style: const TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontWeight: FontWeight.w800, // ExtraBold
                        fontSize: 8,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      event.month,
                      style: const TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontWeight: FontWeight.w800, // ExtraBold
                        fontSize: 8,
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
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: onJoinToggle,
                child: Container(
                  width: 126,
                  height: 30,
                  decoration: BoxDecoration(
                    color: event.isJoined ? AppColors.goldDark : AppColors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    event.isJoined ? 'Joined' : 'Join',
                    style: const TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w700, // Bold
                      fontSize: 10,
                      color: Color(0xFFF3F3F3),
                      height: 3.1,
                    ),
                  ),
                ),
              ),
            ),

            // Timeline Arrow (36×26 rotated 270°)
            Positioned(
              left: 12,
              bottom: 12,
              child: Transform.rotate(
                angle: -math.pi / 2, // 270° clockwise
                child: CustomPaint(
                  size: const Size(36, 26),
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
