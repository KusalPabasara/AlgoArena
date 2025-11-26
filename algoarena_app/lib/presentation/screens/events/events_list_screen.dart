import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/event.dart';
import '../../../data/repositories/event_repository.dart';
import '../../widgets/event_card.dart';
import '../../widgets/app_bottom_nav.dart';
import 'event_detail_screen.dart';

/// Events List Screen - Matches Figma design exactly from Provide Frontend Code
class EventsListScreen extends StatefulWidget {
  const EventsListScreen({Key? key}) : super(key: key);

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final _eventRepository = EventRepository();
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _eventRepository.getAllEvents();
      if (mounted) {
        setState(() {
          _events = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load events: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleJoinEvent(Event event) async {
    try {
      final updatedEvent = await _eventRepository.toggleJoinEvent(
        event.id,
        !event.isJoined,
      );

      if (mounted) {
        setState(() {
          final index = _events.indexWhere((e) => e.id == event.id);
          if (index != -1) {
            _events[index] = updatedEvent;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedEvent.isJoined
                  ? 'Successfully joined ${event.title}'
                  : 'Left ${event.title}',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update event: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _openEventDetail(Event event) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return EventDetailScreen(eventId: event.id);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Curved animation for smooth easing
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          
          // Slide from right
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.3, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation);
          
          // Fade in
          final fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(curvedAnimation);
          
          // Slight scale up
          final scaleAnimation = Tween<double>(
            begin: 0.95,
            end: 1.0,
          ).animate(curvedAnimation);
          
          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  Color _getEventColor(Event event) {
    switch (event.colorTheme) {
      case EventColor.purple:
        return const Color(0xFF7D4E94);
      case EventColor.black:
        return Colors.black;
      case EventColor.cyan:
        return const Color(0xFF00B1FF);
      case EventColor.red:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. BACKGROUND LAYER - Bubbles with Hero animation for smooth transition
          Positioned(
            left: -218.41,
            top: -280,
            child: Hero(
              tag: 'event_bubbles_background',
              child: SizedBox(
                width: 900,
                height: screenHeight + 350,
                child: CustomPaint(
                  size: Size(900, screenHeight + 350),
                  painter: _BubblesPainter(),
                ),
              ),
            ),
          ),

          // 2. BACK BUTTON - Position: left: 10, top: 50
          Positioned(
            left: 10,
            top: 50,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 50,
                height: 53,
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),

          // 3. "EVENTS" TITLE - Position: left: 69, top: 48, white text on black bubble
          const Positioned(
            left: 69,
            top: 48,
            child: Text(
              'Events',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w700,
                fontSize: 50,
                color: Colors.white,
                height: 1.0,
                letterSpacing: -0.52,
              ),
            ),
          ),

          // 4. TIMELINE LINE - Position: left: 69, starts below header area
          Positioned(
            left: 69,
            top: 200, // Start below the black bubble header
            bottom: 0,
            child: Container(
              width: 2,
              color: Colors.black,
            ),
          ),

          // 5. SCROLLABLE CONTENT LAYER - starts below header area
          Positioned(
            left: 52,
            top: 200, // Start below the black bubble header to avoid clash
            right: 0,
            bottom: 0,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : _events.isEmpty
                    ? const Center(
                        child: Text(
                          'No events available',
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(
                          top: 0,
                          bottom: 16,
                        ),
                        itemCount: _events.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 26),
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          final eventColor = _getEventColor(event);
                          return SizedBox(
                            height: 160, // Fixed height matching card height
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date Badge and Triangle Column
                                SizedBox(
                                  width: 55,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Date Badge (33×33 black circle) - positioned at top
                                      Positioned(
                                        left: 0,
                                        top: 64, // Vertically centered (160/2 - 33/2)
                                        child: Container(
                                          width: 33,
                                          height: 33,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                event.date,
                                                style: const TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 8,
                                                  color: Colors.white,
                                                  height: 1.0,
                                                ),
                                              ),
                                              Text(
                                                event.month,
                                                style: const TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 8,
                                                  color: Colors.white,
                                                  height: 1.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Triangle Arrow Indicator - positioned to point at card
                                      // Figma: ml-[34px] mt-[63px] from the group, rotated 270deg
                                      Positioned(
                                        left: 34,
                                        top: 62, // Vertically centered (160/2 - 36/2)
                                        child: Transform.rotate(
                                          angle: -1.5708, // 270 degrees (pointing right)
                                          child: CustomPaint(
                                            size: const Size(36, 26),
                                            painter: _TrianglePainter(
                                              color: eventColor.withOpacity(0.2),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Event Card
                                Expanded(
                                  child: EventCard(
                                    event: event,
                                    onTap: () => _openEventDetail(event),
                                    onJoinToggle: () => _toggleJoinEvent(event),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

/// Custom painter for the Bubbles background - exact SVG paths from React Events.tsx
class _BubblesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Scale factors to match viewBox="0 0 845 1222"
    final scaleX = size.width / 845;
    final scaleY = size.height / 1222;

    // Yellow bubble 02 (top-left yellow) - pecbd00 path from svg-9qg6fl4iht.ts
    final bubble02Paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final bubble02Path = Path();
    bubble02Path.moveTo(359.78 * scaleX, 448.521 * scaleY);
    bubble02Path.cubicTo(
      288.334 * scaleX, 592.936 * scaleY,
      145.744 * scaleX, 394.684 * scaleY,
      126.425 * scaleX, 285.125 * scaleY,
    );
    bubble02Path.cubicTo(
      107.107 * scaleX, 175.565 * scaleY,
      180.262 * scaleX, 71.0886 * scaleY,
      289.822 * scaleX, 51.7703 * scaleY,
    );
    bubble02Path.cubicTo(
      399.381 * scaleX, 32.452 * scaleY,
      467.416 * scaleX, 117.638 * scaleY,
      493.002 * scaleX, 216.109 * scaleY,
    );
    bubble02Path.cubicTo(
      518.587 * scaleX, 314.58 * scaleY,
      431.226 * scaleX, 304.106 * scaleY,
      359.78 * scaleX, 448.521 * scaleY,
    );
    bubble02Path.close();
    canvas.drawPath(bubble02Path, bubble02Paint);

    // Black bubble 01 - p38579800 path from svg-9qg6fl4iht.ts
    final bubble01Paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final bubble01Path = Path();
    bubble01Path.moveTo(135.167 * scaleX, 375.884 * scaleY);
    bubble01Path.cubicTo(
      -24.975 * scaleX, 358.14 * scaleY,
      112.552 * scaleX, 156.343 * scaleY,
      208.897 * scaleX, 100.718 * scaleY,
    );
    bubble01Path.cubicTo(
      305.243 * scaleX, 45.093 * scaleY,
      428.439 * scaleX, 78.1032 * scaleY,
      484.064 * scaleX, 174.448 * scaleY,
    );
    bubble01Path.cubicTo(
      539.689 * scaleX, 270.794 * scaleY,
      506.678 * scaleX, 393.99 * scaleY,
      410.333 * scaleX, 449.615 * scaleY,
    );
    bubble01Path.cubicTo(
      313.988 * scaleX, 505.24 * scaleY,
      295.309 * scaleX, 393.629 * scaleY,
      135.167 * scaleX, 375.884 * scaleY,
    );
    bubble01Path.close();
    canvas.drawPath(bubble01Path, bubble01Paint);

    // Yellow bubble 04 (bottom-right) - p145eec00 path from svg-9qg6fl4iht.ts
    final bubble04Paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final bubble04Path = Path();
    bubble04Path.moveTo(804.574 * scaleX, 1031.32 * scaleY);
    bubble04Path.cubicTo(
      934.388 * scaleX, 1121.65 * scaleY,
      714.388 * scaleX, 1221.97 * scaleY,
      603.138 * scaleX, 1221.97 * scaleY,
    );
    bubble04Path.cubicTo(
      491.888 * scaleX, 1221.97 * scaleY,
      401.702 * scaleX, 1136.61 * scaleY,
      401.702 * scaleX, 1031.32 * scaleY,
    );
    bubble04Path.cubicTo(
      401.702 * scaleX, 926.026 * scaleY,
      497.408 * scaleX, 876.614 * scaleY,
      598.826 * scaleX, 868.949 * scaleY,
    );
    bubble04Path.cubicTo(
      700.244 * scaleX, 861.285 * scaleY,
      674.759 * scaleX, 940.991 * scaleY,
      804.574 * scaleX, 1031.32 * scaleY,
    );
    bubble04Path.close();
    canvas.drawPath(bubble04Path, bubble04Paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for triangle arrow indicator - exact Figma path
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Exact Figma SVG path: "M15.5885 0L31.1769 19.5H0L15.5885 0Z"
    // viewBox="0 0 32 20", scaled to size
    final scaleX = size.width / 32;
    final scaleY = size.height / 20;
    
    final path = Path();
    path.moveTo(15.5885 * scaleX, 0);
    path.lineTo(31.1769 * scaleX, 19.5 * scaleY);
    path.lineTo(0, 19.5 * scaleY);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
