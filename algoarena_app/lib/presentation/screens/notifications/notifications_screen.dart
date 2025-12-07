import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/custom_back_button.dart';
import '../../../utils/responsive_utils.dart';
import '../../../data/models/notification.dart' as models;
import '../../../data/repositories/notification_repository.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../core/constants/colors.dart';

/// Notifications Screen - Shows real notifications from backend with real-time updates
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _bubblesSlideAnimation;
  late Animation<double> _bubblesFadeAnimation;
  
  final _notificationRepository = NotificationRepository();
  final _pageRepository = PageRepository();
  List<models.Notification> _notifications = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  String? _lastNotificationId; // Track the most recent notification ID
  
  // Cache for page and event icons
  final Map<String, String?> _pageIconCache = {}; // pageId -> logo URL
  final Map<String, String?> _eventIconCache = {}; // eventId -> image URL

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
    
    // Load notifications
    _loadNotifications();
    
    // Start real-time updates - check every 10 seconds
    _startRealTimeUpdates();
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
  
  void _startRealTimeUpdates() {
    // Check for new notifications every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _checkForNewNotifications();
      } else {
        timer.cancel();
      }
    });
  }
  
  Future<void> _checkForNewNotifications() async {
    try {
      final notifications = await _notificationRepository.getAllNotifications();
      if (!mounted) return;
      
      // Check if there are new notifications
      if (notifications.isNotEmpty) {
        final latestNotificationId = notifications.first.id;
        
        // If we have a new notification (different from last known)
        if (_lastNotificationId != null && latestNotificationId != _lastNotificationId) {
          // New notification detected - update the list
          setState(() {
            _notifications = notifications;
            _lastNotificationId = latestNotificationId;
          });
          
          // Show a subtle indicator that new notifications arrived
          // (optional - you can remove this if you don't want any visual feedback)
        } else if (_lastNotificationId == null) {
          // First load - just set the last known ID
          setState(() {
            _notifications = notifications;
            _lastNotificationId = latestNotificationId;
          });
        } else {
          // Same notifications, but update the list in case read status changed
          setState(() {
            _notifications = notifications;
          });
        }
      } else {
        // No notifications
        setState(() {
          _notifications = notifications;
          _lastNotificationId = null;
        });
      }
    } catch (e) {
      // Silently fail for background updates - don't show error to user
      print('Background notification check failed: $e');
    }
  }
  
  Future<void> _loadNotifications() async {
    try {
      final notifications = await _notificationRepository.getAllNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
          // Set the last known notification ID
          if (notifications.isNotEmpty) {
            _lastNotificationId = notifications.first.id;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notifications: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
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
            // Bubbles - animated to slide in from outside
            FadeTransition(
              opacity: _bubblesFadeAnimation,
              child: SlideTransition(
                position: _bubblesSlideAnimation,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Yellow Bubble (Bubbles) - left-[-179.79px] top-[-276.58px]
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

            // Back button - top left
            CustomBackButton(
              backgroundColor: Colors.black,
              iconSize: ResponsiveUtils.iconSize,
            ),

            // "Notifications" title
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

            // Scrollable content with transparent box
            Positioned(
              left: 0,
              right: 0,
              top: ResponsiveUtils.bh(168),
              bottom: ResponsiveUtils.bh(40), // Add bottom margin
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(ResponsiveUtils.r(35)),
                        child: Container(
                          width: ResponsiveUtils.dp(375),
                          height: screenHeight - ResponsiveUtils.bh(168) - ResponsiveUtils.bh(20),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1), // Transparent black background
                            borderRadius: BorderRadius.circular(ResponsiveUtils.r(35)),
                          ),
                          child: _notifications.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(ResponsiveUtils.spacingXL),
                                    child: Text(
                                      'No notifications yet',
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: ResponsiveUtils.bodyMedium,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ResponsiveUtils.spacingM + 4,
                                      vertical: ResponsiveUtils.spacingM - 6,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Notification cards
                                        ..._notifications.map((notification) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom: ResponsiveUtils.dp(11),
                                            ),
                                            child: _buildNotificationCardFromModel(notification),
                                          );
                                        }).toList(),
                                        SizedBox(height: ResponsiveUtils.spacingXXL),
                                      ],
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

  Widget _buildNotificationCardFromModel(models.Notification notification) {
    return GestureDetector(
      onTap: () async {
        // Mark as read when tapped
        if (!notification.isRead) {
          try {
            await _notificationRepository.markAsRead(notification.id);
            setState(() {
              final index = _notifications.indexWhere((n) => n.id == notification.id);
              if (index != -1) {
                _notifications[index] = models.Notification(
                  id: notification.id,
                  type: notification.type,
                  title: notification.title,
                  message: notification.message,
                  iconUrl: notification.iconUrl,
                  pageId: notification.pageId,
                  eventId: notification.eventId,
                  createdAt: notification.createdAt,
                  isRead: true,
                );
              }
            });
          } catch (e) {
            // Silently fail - notification is still shown
          }
        }
        
        // Navigate to related page/event if applicable
        if (notification.pageId != null) {
          // TODO: Navigate to page detail
        } else if (notification.eventId != null) {
          // TODO: Navigate to event detail
        }
      },
      child: Container(
        width: double.infinity,
        height: ResponsiveUtils.dp(66), // Fixed height as requested
        decoration: BoxDecoration(
          color: Colors.white, // White background like page cards
          borderRadius: BorderRadius.circular(ResponsiveUtils.dp(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: ResponsiveUtils.dp(66), // Fixed height to provide bounded constraints
          child: Stack(
            children: [
            // Circular icon with gold border - matching page card style but circular
            Positioned(
              left: ResponsiveUtils.dp(9),
              top: ResponsiveUtils.dp(9),
              child: Stack(
                children: [
                  // Gold border background - circular (46x46dp)
                  Container(
                    width: ResponsiveUtils.dp(46),
                    height: ResponsiveUtils.dp(46),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF8F7902),
                    ),
                  ),
                  // Image - circular, fits inside gold border
                  Positioned(
                    left: ResponsiveUtils.dp(2),
                    top: ResponsiveUtils.dp(2),
                    child: SizedBox(
                      width: ResponsiveUtils.dp(42),
                      height: ResponsiveUtils.dp(42),
                      child: ClipOval(
                        child: _buildNotificationIcon(notification),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Notification message - left:61, top:21
            Positioned(
              left: ResponsiveUtils.dp(61),
              top: ResponsiveUtils.dp(21),
              right: ResponsiveUtils.dp(15), // Add right padding
              child: Text(
                notification.message,
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: ResponsiveUtils.bodySmall,
                  fontWeight: FontWeight.w400, // Not bold
                  color: Colors.black,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Read indicator - small dot in top right
            if (!notification.isRead)
              Positioned(
                right: ResponsiveUtils.dp(15),
                top: ResponsiveUtils.dp(15),
                child: Container(
                  width: ResponsiveUtils.dp(8),
                  height: ResponsiveUtils.dp(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF8F7902),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNotificationIcon(models.Notification notification) {
    // Priority: pageId/eventId icon > iconUrl > default icon
    
    // First, try to get page logo or event image
    if (notification.pageId != null) {
      return _buildPageIcon(notification.pageId!);
    } else if (notification.eventId != null) {
      return _buildEventIcon(notification.eventId!);
    }
    
    // Fallback to iconUrl if provided and valid
    final iconUrl = notification.iconUrl;
    if (iconUrl != null && iconUrl.isNotEmpty && iconUrl.trim().isNotEmpty) {
      // Check if it's a valid network URL
      if (iconUrl.startsWith('http://') || iconUrl.startsWith('https://')) {
        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: iconUrl,
            width: ResponsiveUtils.dp(42),
            height: ResponsiveUtils.dp(42),
            fit: BoxFit.cover,
            placeholder: (context, url) {
              // Show default icon while loading
              return _buildDefaultIcon(notification.type);
            },
            errorWidget: (context, url, error) {
              // Show default icon if image fails to load
              return _buildDefaultIcon(notification.type);
            },
          ),
        );
      }
    }
    
    // Final fallback to default icon
    return _buildDefaultIcon(notification.type);
  }
  
  Widget _buildPageIcon(String pageId) {
    // Check cache first
    if (_pageIconCache.containsKey(pageId)) {
      final logoUrl = _pageIconCache[pageId];
      if (logoUrl != null && logoUrl.isNotEmpty && 
          (logoUrl.startsWith('http://') || logoUrl.startsWith('https://'))) {
        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: logoUrl,
            width: ResponsiveUtils.dp(42),
            height: ResponsiveUtils.dp(42),
            fit: BoxFit.cover,
            errorWidget: (context, url, error) {
              // If image fails to load, show default icon
              return _buildDefaultIcon('page_created');
            },
            placeholder: (context, url) {
              // Show default icon while loading
              return _buildDefaultIcon('page_created');
            },
          ),
        );
      } else {
        // Cached but invalid/null - show default icon
        return _buildDefaultIcon('page_created');
      }
    }
    
    // Fetch page data asynchronously
    return FutureBuilder<String?>(
      future: _fetchPageIcon(pageId),
      builder: (context, snapshot) {
        // Show default icon while loading or on error
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildDefaultIcon('page_created');
        }
        
        // If we got a valid URL, show it
        if (snapshot.hasData && 
            snapshot.data != null && 
            snapshot.data!.isNotEmpty &&
            (snapshot.data!.startsWith('http://') || snapshot.data!.startsWith('https://'))) {
          final logoUrl = snapshot.data!;
          return ClipOval(
            child: CachedNetworkImage(
              imageUrl: logoUrl,
              width: ResponsiveUtils.dp(42),
              height: ResponsiveUtils.dp(42),
              fit: BoxFit.cover,
              errorWidget: (context, url, error) {
                // If image fails to load, show default icon
                return _buildDefaultIcon('page_created');
              },
              placeholder: (context, url) {
                // Show default icon while loading
                return _buildDefaultIcon('page_created');
              },
            ),
          );
        }
        
        // No valid image available - show default icon
        return _buildDefaultIcon('page_created');
      },
    );
  }
  
  Widget _buildEventIcon(String eventId) {
    // Determine notification type for default icon by finding the notification
    String defaultType = 'event_created';
    try {
      final notification = _notifications.firstWhere(
        (n) => n.eventId == eventId,
      );
      defaultType = notification.type;
    } catch (e) {
      // Notification not found, use default
      defaultType = 'event_created';
    }
    
    // Check cache first
    if (_eventIconCache.containsKey(eventId)) {
      final imageUrl = _eventIconCache[eventId];
      if (imageUrl != null && imageUrl.isNotEmpty && 
          (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: ResponsiveUtils.dp(42),
            height: ResponsiveUtils.dp(42),
            fit: BoxFit.cover,
            errorWidget: (context, url, error) {
              // If image fails to load, show default icon
              return _buildDefaultIcon(defaultType);
            },
            placeholder: (context, url) {
              // Show default icon while loading
              return _buildDefaultIcon(defaultType);
            },
          ),
        );
      } else {
        // Cached but invalid/null - show default icon
        return _buildDefaultIcon(defaultType);
      }
    }
    
    // Fetch event data asynchronously
    return FutureBuilder<String?>(
      future: _fetchEventIcon(eventId),
      builder: (context, snapshot) {
        // Show default icon while loading or on error
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildDefaultIcon(defaultType);
        }
        
        // If we got a valid URL, show it
        if (snapshot.hasData && 
            snapshot.data != null && 
            snapshot.data!.isNotEmpty &&
            (snapshot.data!.startsWith('http://') || snapshot.data!.startsWith('https://'))) {
          final imageUrl = snapshot.data!;
          return ClipOval(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: ResponsiveUtils.dp(42),
              height: ResponsiveUtils.dp(42),
              fit: BoxFit.cover,
              errorWidget: (context, url, error) {
                // If image fails to load, show default icon
                return _buildDefaultIcon(defaultType);
              },
              placeholder: (context, url) {
                // Show default icon while loading
                return _buildDefaultIcon(defaultType);
              },
            ),
          );
        }
        
        // No valid image available - show default icon
        return _buildDefaultIcon(defaultType);
      },
    );
  }
  
  Future<String?> _fetchPageIcon(String pageId) async {
    try {
      final page = await _pageRepository.getPageById(pageId);
      final logoUrl = page.logo;
      
      // Check if it's a valid network URL (not a file path)
      if (logoUrl != null && 
          logoUrl.isNotEmpty && 
          (logoUrl.startsWith('http://') || logoUrl.startsWith('https://'))) {
        _pageIconCache[pageId] = logoUrl;
        return logoUrl;
      }
      
      // If it's a file path or invalid, return null to use default icon
      _pageIconCache[pageId] = null;
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching page icon for $pageId: $e');
      _pageIconCache[pageId] = null;
      return null;
    }
  }
  
  Future<String?> _fetchEventIcon(String eventId) async {
    try {
      // Use ApiService directly to get raw event data
      final apiService = ApiService();
      final response = await apiService.get('/events/$eventId', withAuth: true);
      final eventData = response['event'] ?? response;
      
      // Get page logo first (preferred), then banner image
      final pageLogo = eventData['pageLogo'] as String?;
      final bannerImage = eventData['bannerImage'] as String? ?? eventData['bannerImageUrl'] as String?;
      final imageUrl = pageLogo ?? bannerImage;
      
      // Check if it's a valid network URL (not a file path)
      if (imageUrl != null && 
          imageUrl.isNotEmpty && 
          (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
        _eventIconCache[eventId] = imageUrl;
        return imageUrl;
      }
      
      // If it's a file path or invalid, return null to use default icon
      _eventIconCache[eventId] = null;
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching event icon for $eventId: $e');
      _eventIconCache[eventId] = null;
      return null;
    }
  }
  
  Widget _buildDefaultIcon(String type) {
    debugPrint('🎨 Building default icon for type: $type');
    final iconData = _getIconForType(type);
    debugPrint('🎨 Icon data selected: $iconData');
    
    return Container(
      width: ResponsiveUtils.dp(42),
      height: ResponsiveUtils.dp(42),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF8F7902),
      ),
      child: Icon(
        iconData,
        color: Colors.white,
        size: ResponsiveUtils.dp(24),
      ),
    );
  }
  
  IconData _getIconForType(String type) {
    // Normalize type to lowercase for comparison
    final normalizedType = type.toLowerCase().trim();
    
    debugPrint('🔍 Getting icon for type: "$normalizedType" (original: "$type")');
    
    switch (normalizedType) {
      case 'page_created':
        return Icons.pages_outlined;
      case 'event_created':
        return Icons.event_available;
      case 'event_closing':
      case 'event_closing_soon':
        return Icons.schedule;
      case 'event_expired':
        return Icons.event_busy;
      default:
        debugPrint('⚠️ Unknown notification type: "$normalizedType", using default icon');
        return Icons.notifications_outlined;
    }
  }
}

/// Yellow Bubble Painter
class _YellowBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final path = Path();
    final scaleX = size.width / 551;
    final scaleY = size.height / 513;

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

/// Black Bubble 01 Painter
class _BlackBubblePainter extends CustomPainter {
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


