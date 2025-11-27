import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/event.dart';
import '../../../data/repositories/event_repository.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/custom_back_button.dart';

/// Event Detail Screen - Matches Event_Page_hyperlink/EventsPage.tsx exactly
class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  final _eventRepository = EventRepository();
  Event? _event;
  bool _isLoading = true;
  
  AnimationController? _animController;
  Animation<double>? _fadeAnim;
  Animation<Offset>? _slideAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadEvent();
  }
  
  void _initAnimations() {
    // Setup entrance animations for content
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController!,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController!,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }
  
  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  Future<void> _loadEvent() async {
    try {
      final event = await _eventRepository.getEventById(widget.eventId);
      if (mounted) {
        setState(() {
          _event = event;
          _isLoading = false;
        });
        // Start content animation after data loads
        _animController?.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load event: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleJoinEvent() async {
    if (_event == null) return;

    try {
      final updatedEvent = await _eventRepository.toggleJoinEvent(
        _event!.id,
        !_event!.isJoined,
      );

      if (mounted) {
        setState(() {
          _event = updatedEvent;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedEvent.isJoined
                  ? 'Successfully joined ${_event!.title}'
                  : 'Left ${_event!.title}',
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_event == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Event not found',
            style: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. BUBBLES BACKGROUND - With Hero animation from events list
          Positioned(
            left: -211.13,
            top: -280,
            child: Hero(
              tag: 'event_bubbles_background',
              child: SizedBox(
                width: 900,
                height: screenHeight + 350,
                child: CustomPaint(
                  size: Size(900, screenHeight + 350),
                  painter: _EventBubblesPainter(),
                ),
              ),
            ),
          ),

          // Main scrollable content with entrance animation
          SafeArea(
            child: _fadeAnim != null && _slideAnim != null
              ? FadeTransition(
                  opacity: _fadeAnim!,
                  child: SlideTransition(
                    position: _slideAnim!,
                    child: _buildContent(),
                  ),
                )
              : _buildContent(),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
  
  Widget _buildContent() {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 20),
        
            // Event Image - Centered
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFFFD700).withOpacity(0.5),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: _buildEventImage(),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Event Title - Centered
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            _event!.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w800,
              fontSize: 28,
              color: Colors.black,
              letterSpacing: -0.52,
            ),
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Organized by label - Centered
        const Text(
          'Organized by:',
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w700,
            fontSize: 10,
            color: Colors.black54,
          ),
        ),
        
        // Organizer name - Centered
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _event!.organizer.replaceAll('\n', ' '),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w500,
              fontSize: 9,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Joined Button - Centered, full width
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: GestureDetector(
            onTap: _toggleJoinEvent,
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: _event!.isJoined
                    ? const Color(0xFFFFD700)
                    : Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                _event!.isJoined ? 'Joined' : 'Join',
                style: const TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Delegate Booklet + Link Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Row(
            children: [
              // Link Icon
              GestureDetector(
                onTap: () {
                  if (_event!.description != null) {
                    final urlPattern = RegExp(
                      r'https?://[^\s]+',
                      caseSensitive: false,
                    );
                    final match = urlPattern.firstMatch(_event!.description!);
                    if (match != null) {
                      _launchUrl(match.group(0)!);
                    }
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(
                    Icons.link,
                    size: 18,
                    color: Colors.black54,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Delegate Booklet Button
              Expanded(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A4A4A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Delegate Booklet',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Description Box - Fills remaining space
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.18),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(21),
                topRight: Radius.circular(21),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                _event!.description ?? 'No description available',
                style: const TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.black,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
      ),
        // Back button - top left
        CustomBackButton(
          backgroundColor: Colors.black, // Dark area (bubbles background)
          iconSize: 24,
        ),
      ],
    );
  }

  Widget _buildEventImage() {
    if (_event!.bannerImageUrl == null) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.event, size: 50),
      );
    }

    if (_event!.bannerImageUrl!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: _event!.bannerImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.event, size: 50),
        ),
      );
    } else {
      return Image.asset(
        _event!.bannerImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.event, size: 50),
        ),
      );
    }
  }
}

/// Custom painter for Event Detail Bubbles - exact SVG paths from EventsPage.tsx
/// viewBox="0 0 885 1301"
class _EventBubblesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 885;
    final scaleY = size.height / 1301;

    // Yellow bubble 02 - p26f27480 path
    final bubble02Paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final bubble02Path = Path();
    bubble02Path.moveTo(441.49 * scaleX, 390.794 * scaleY);
    bubble02Path.cubicTo(
      479.588 * scaleX, 547.347 * scaleY,
      242.924 * scaleX, 487.132 * scaleY,
      157.701 * scaleX, 415.622 * scaleY,
    );
    bubble02Path.cubicTo(
      72.479 * scaleX, 344.112 * scaleY,
      61.363 * scaleX, 217.055 * scaleY,
      132.873 * scaleX, 131.833 * scaleY,
    );
    bubble02Path.cubicTo(
      204.383 * scaleX, 46.6107 * scaleY,
      311.257 * scaleX, 68.135 * scaleY,
      394.153 * scaleX, 127.122 * scaleY,
    );
    bubble02Path.cubicTo(
      477.049 * scaleX, 186.11 * scaleY,
      403.393 * scaleX, 234.241 * scaleY,
      441.49 * scaleX, 390.794 * scaleY,
    );
    bubble02Path.close();
    canvas.drawPath(bubble02Path, bubble02Paint);

    // Black bubble 01 - p188d8480 path
    final bubble01Paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final bubble01Path = Path();
    bubble01Path.moveTo(194.337 * scaleX, 455.39 * scaleY);
    bubble01Path.cubicTo(
      46.7783 * scaleX, 520.094 * scaleY,
      64.982 * scaleX, 276.569 * scaleY,
      120.607 * scaleX, 180.224 * scaleY,
    );
    bubble01Path.cubicTo(
      176.232 * scaleX, 83.8789 * scaleY,
      299.428 * scaleX, 50.8686 * scaleY,
      395.773 * scaleX, 106.494 * scaleY,
    );
    bubble01Path.cubicTo(
      492.118 * scaleX, 162.118 * scaleY,
      525.129 * scaleX, 285.315 * scaleY,
      469.504 * scaleX, 381.66 * scaleY,
    );
    bubble01Path.cubicTo(
      413.879 * scaleX, 478.005 * scaleY,
      341.897 * scaleX, 390.687 * scaleY,
      194.337 * scaleX, 455.39 * scaleY,
    );
    bubble01Path.close();
    canvas.drawPath(bubble01Path, bubble01Paint);

    // Yellow bubble 04 - p17c37d00 path
    final bubble04Paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final bubble04Path = Path();
    bubble04Path.moveTo(781.596 * scaleX, 983.12 * scaleY);
    bubble04Path.cubicTo(
      934.476 * scaleX, 1023.6 * scaleY,
      762.055 * scaleX, 1193.12 * scaleY,
      657.514 * scaleX, 1231.17 * scaleY,
    );
    bubble04Path.cubicTo(
      552.974 * scaleX, 1269.22 * scaleY,
      439.033 * scaleX, 1219.85 * scaleY,
      403.021 * scaleX, 1120.91 * scaleY,
    );
    bubble04Path.cubicTo(
      367.009 * scaleX, 1021.97 * scaleY,
      440.042 * scaleX, 942.801 * scaleY,
      532.723 * scaleX, 900.912 * scaleY,
    );
    bubble04Path.cubicTo(
      625.404 * scaleX, 859.023 * scaleY,
      628.716 * scaleX, 942.639 * scaleY,
      781.596 * scaleX, 983.12 * scaleY,
    );
    bubble04Path.close();
    canvas.drawPath(bubble04Path, bubble04Paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
