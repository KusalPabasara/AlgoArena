import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/event.dart';
import '../../../data/repositories/event_repository.dart';
import '../../widgets/app_bottom_nav.dart';

/// Event Detail Screen - Matches Figma design 349:1590, 352:2071
class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  final _eventRepository = EventRepository();
  final ScrollController _scrollController = ScrollController();
  Event? _event;
  bool _isLoading = true;
  double _scrollOffset = 0.0;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    _loadEvent();
  }
  
  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
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
        _fadeController.forward();
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
          SnackBar(
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
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_event == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated Decorative Bubbles Background with parallax
          Positioned(
            left: -211.13,
            top: -331.84 + (_scrollOffset * 0.3),
            child: Opacity(
              opacity: 0.15,
              child: Container(
                width: 884.181,
                height: 1300.062,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Content with parallax scroll
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Animated Event Banner with border and scale effect (121×121)
                  if (_event!.bannerImageUrl != null)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Center(
                        child: Transform.scale(
                          scale: 1.0 - (_scrollOffset * 0.0005).clamp(0.0, 0.2),
                          child: Container(
                            width: 121,
                            height: 121,
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.5),
                                width: 5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                imageUrl: _event!.bannerImageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.event, size: 50),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Animated Event Title with fade
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 33.5),
                      child: Text(
                        _event!.title,
                        style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w800, // ExtraBold
                          fontSize: 30,
                          color: AppColors.black,
                          letterSpacing: -0.52,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Organizer Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 33.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Organized by:',
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.w800, // ExtraBold
                            fontSize: 9,
                            color: AppColors.black,
                            height: 1.33,
                          ),
                        ),
                        Text(
                          _event!.organizer.replaceAll('\n', ' '),
                          style: const TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.w600, // SemiBold
                            fontSize: 8,
                            color: AppColors.black,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 33.5),
                    child: Row(
                      children: [
                        // Joined Button
                        GestureDetector(
                          onTap: _toggleJoinEvent,
                          child: Container(
                            width: 190,
                            height: 30,
                            decoration: BoxDecoration(
                              color: _event!.isJoined
                                  ? AppColors.goldDark
                                  : AppColors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _event!.isJoined ? 'Joined' : 'Join',
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

                        const SizedBox(width: 8),

                        // Delegate Booklet Button (placeholder)
                        Container(
                          width: 156,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF696969), // dimgrey
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Delegate Booklet',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontWeight: FontWeight.w700, // Bold
                              fontSize: 10,
                              color: Color(0xFFF3F3F3),
                              height: 3.1,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Link Icon
                        GestureDetector(
                          onTap: () {
                            // Extract first URL from description
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
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFBABABA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.link,
                              size: 17,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Animated Description Box with gold tint background
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.goldTint,
                        borderRadius: BorderRadius.circular(21),
                      ),
                      child: _event!.description != null
                          ? SingleChildScrollView(
                              child: Text(
                                _event!.description!,
                                style: const TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontWeight: FontWeight.w400, // Regular
                                  fontSize: 15,
                                  color: AppColors.black,
                                  height: 1.0,
                                ),
                              ),
                            )
                          : const Text(
                              'No description available',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: const AppBottomNav(currentIndex: 2), // Calendar tab
    );
  }
}
