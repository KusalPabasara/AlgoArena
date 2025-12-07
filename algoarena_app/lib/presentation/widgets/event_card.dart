import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../data/models/event.dart';
import '../../core/constants/colors.dart';

/// Modern Event Card Widget - Redesigned
/// Card size: 225×160px with 18px radius
class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback? onJoinToggle;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onJoinToggle,
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
    final isExpired = event.isExpired;
    // Calculate responsive height based on screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.2; // 20% of screen height, with min/max constraints
    final responsiveHeight = cardHeight.clamp(140.0, 180.0); // Min 140, Max 180
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: responsiveHeight,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
              children: [
                // Expired overlay (semi-transparent)
                if (isExpired)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                
                // Club Avatar (56×56 circle with golden border)
                Positioned(
                  left: 14,
                  top: 17,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _buildEventImage(event.imageUrl),
                    ),
                  ),
                ),

                // Expired Badge (top right)
                if (isExpired)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'EXPIRED',
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                // Event Title (AlgoArena, Leo Line, etc.)
                Positioned(
                  left: 84,
                  top: 17,
                  right: isExpired ? 70 : 12,
                  child: Text(
                    event.title,
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: isExpired ? Colors.white70 : AppColors.black,
                      height: 1.55,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Event Name/Description
                Positioned(
                  left: 84,
                  top: 48,
                  right: 12,
                  child: Text(
                    event.eventName,
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: isExpired ? Colors.white70 : AppColors.black,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Organized by (under description) - moved lower
                Positioned(
                  left: 84,
                  top: 82,
                  right: 12,
                  child: Text(
                    'Organized by ${event.organizer}',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 9,
                      color: isExpired ? Colors.white60 : Colors.grey[600],
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Date badge at bottom left
                Positioned(
                  left: 14,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isExpired ? 0.3 : 0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isExpired ? Colors.white70 : const Color(0xFFFFD700),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.date,
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: isExpired ? Colors.white : AppColors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.month,
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            color: isExpired ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Join/Joined Button (only show if not expired and callback provided)
                if (!isExpired && onJoinToggle != null)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: GestureDetector(
                      onTap: onJoinToggle,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: event.isJoined ? const Color(0xFFFFD700) : Colors.black,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          event.isJoined ? 'Joined' : 'Join',
                          style: const TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: Colors.white,
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
  
  Widget _buildEventImage(String imageUrl) {
    // Check if it's a network URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.group,
            size: 32,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    // Check if it's a file path (starts with / or contains /cache/ or /data/)
    final isFilePath = imageUrl.startsWith('/') || 
                       imageUrl.startsWith('file://') || 
                       imageUrl.contains('/cache/') || 
                       imageUrl.contains('/data/') ||
                       imageUrl.contains('com.example.') ||
                       imageUrl.contains('user/0/') ||
                       imageUrl.contains('user/');
    
    if (isFilePath) {
      try {
        final filePath = imageUrl.startsWith('file://') 
            ? imageUrl.substring(7) 
            : imageUrl;
        final file = File(filePath);
        
        if (file.existsSync()) {
          return Image.file(
            file,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.group,
                size: 32,
                color: Colors.grey,
              ),
            ),
          );
        } else {
          // File doesn't exist, show placeholder
          return Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.group,
              size: 32,
              color: Colors.grey,
            ),
          );
        }
      } catch (e) {
        // Error loading file, show placeholder
        return Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.group,
            size: 32,
            color: Colors.grey,
          ),
        );
      }
    }
    
    // If it looks like an asset path (starts with 'assets/'), try Image.asset
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.group,
            size: 32,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    // Fallback to placeholder for unknown formats
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.group,
        size: 32,
        color: Colors.grey,
      ),
    );
  }
}
