import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/event.dart';
import '../../core/constants/colors.dart';

/// Event Card Widget - Matches Figma design 352:1796
/// Card size: 225×160px with 18px radius
class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback onJoinToggle;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onJoinToggle,
  });

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                // Club Avatar (56×56 circle)
                Positioned(
                  left: 14,
                  top: 17,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: event.imageUrl.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: event.imageUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.group,
                                size: 32,
                                color: Colors.grey,
                              ),
                            )
                          : Image.asset(
                              event.imageUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.group,
                                size: 32,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                ),

                // Event Title (AlgoArena, Leo Line, etc.)
                Positioned(
                  left: 84,
                  top: 17,
                  right: 12,
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w800, // ExtraBold
                      fontSize: 20,
                      color: AppColors.black,
                      height: 1.55,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Event Name (Mobile App Development Competition, Blog Article Series, etc.)
                Positioned(
                  left: 84,
                  top: 48,
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

                // Organizer (Leo Club of University...)
                Positioned(
                  left: 14,
                  top: 81,
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

                // Join/Joined Button
                Positioned(
                  left: 84,
                  bottom: 16,
                  right: 12, // Add right constraint to fill available space
                  child: GestureDetector(
                    onTap: onJoinToggle,
                    child: Container(
                      width: 126, // Keep fixed width for button
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
              ],
            ),
          ),
        );
      },
    );
  }
}
