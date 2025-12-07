import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../core/constants/colors.dart';
import '../../../data/models/event.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/responsive_utils.dart';
import 'create_event_screen.dart';
import 'events_list_screen.dart';

/// Event Detail Screen - Matches Event_Page_hyperlink/EventsPage.tsx exactly
class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
  
  // Clear all event caches (call on app refresh or user change)
  static void clearAllEventCache() {
    _EventDetailScreenState.clearAllEventCache();
  }
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with TickerProviderStateMixin {
  final _eventRepository = EventRepository();
  final _pageRepository = PageRepository();
  final _apiService = ApiService();
  Event? _event;
  bool _isLoading = true;
  bool _isWebmaster = false;
  Map<String, dynamic>? _eventRawData; // Store raw event data for pageId
  int _participantsCount = 0; // Track participant count in real-time
  
  // Static cache for event data (shared across all instances)
  static final Map<String, _CachedEventData> _eventCache = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  
  late AnimationController _animController;
  Animation<double>? _fadeAnim;
  Animation<Offset>? _slideAnim;
  
  // Bubble animations - separate for top and bottom bubbles
  late AnimationController _topBubblesAnimationController;
  late Animation<Offset> _topBubblesSlideAnimation;
  late Animation<double> _topBubblesFadeAnimation;
  
  late AnimationController _bottomBubblesAnimationController;
  late Animation<Offset> _bottomBubblesSlideAnimation;
  late Animation<double> _bottomBubblesFadeAnimation;

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
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    
    // Top bubbles animation - coming from top
    _topBubblesAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _topBubblesSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5), // Coming from top
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _topBubblesAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _topBubblesFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _topBubblesAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    // Bottom yellow bubble animation - coming from right side
    _bottomBubblesAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _bottomBubblesSlideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0), // Coming from right side
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bottomBubblesAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _bottomBubblesFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bottomBubblesAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
  }
  
  @override
  void dispose() {
    _animController.dispose();
    _topBubblesAnimationController.dispose();
    _bottomBubblesAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadEvent() async {
    try {
      // Get current user ID to pass to repository
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.user?.id;
      final userLeoId = authProvider.user?.leoId;
      
      // Check cache first
      final cachedData = _eventCache[widget.eventId];
      final now = DateTime.now();
      
      if (cachedData != null && now.difference(cachedData.timestamp) < _cacheExpiry) {
        // Use cached data for instant loading
        // Always create a fresh copy to ensure currentUserId is included
        _eventRawData = Map<String, dynamic>.from(cachedData.rawData);
        
        // Parse event from cached data - ensure currentUserId is always set
        final eventData = Map<String, dynamic>.from(_eventRawData ?? {});
        // Always update with current user ID to ensure isJoined is correct
        if (currentUserId != null) {
          eventData['_currentUserId'] = currentUserId;
        }
        final event = Event.fromJson(eventData);
        
        if (mounted) {
          setState(() {
            _event = event;
            _isWebmaster = cachedData.isWebmaster;
            _isLoading = false;
            _participantsCount = _eventRawData?['participantsCount'] ?? 
                                (_eventRawData?['participants']?.length ?? 0);
          });
          // Start animations immediately for cached data
          _animController.forward();
          _topBubblesAnimationController.forward();
          _bottomBubblesAnimationController.forward();
        }
        
        // Refresh data in background (non-blocking)
        _refreshEventInBackground(currentUserId, userLeoId);
        return;
      }
      
      // No cache or cache expired - load from API
      final rawResponse = await _apiService.get('/events/${widget.eventId}', withAuth: true);
      _eventRawData = rawResponse['event'] ?? rawResponse;
      
      // Parse event from raw data
      final eventData = Map<String, dynamic>.from(_eventRawData ?? {});
      if (currentUserId != null) {
        eventData['_currentUserId'] = currentUserId;
      }
      final event = Event.fromJson(eventData);
      
      // Check webmaster status
      bool isWebmaster = false;
      if (userLeoId != null && _eventRawData?['pageId'] != null) {
        try {
          final pageId = _eventRawData!['pageId'];
          final page = await _pageRepository.getPageById(pageId);
          isWebmaster = page.webmasterIds.contains(userLeoId);
        } catch (e) {
          print('Error checking webmaster status: $e');
        }
      }
      
      // Update cache - always store fresh copy with current user context
      _eventCache[widget.eventId] = _CachedEventData(
        rawData: Map<String, dynamic>.from(_eventRawData!),
        isWebmaster: isWebmaster,
        timestamp: now,
      );
      
      if (mounted) {
        setState(() {
          _event = event;
          _isWebmaster = isWebmaster;
          _isLoading = false;
          _participantsCount = _eventRawData?['participantsCount'] ?? 
                              (_eventRawData?['participants']?.length ?? 0);
        });
        // Start content animation after data loads
        _animController.forward();
        _topBubblesAnimationController.forward();
        _bottomBubblesAnimationController.forward();
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
  
  // Refresh event data in background (non-blocking)
  Future<void> _refreshEventInBackground(String? currentUserId, String? userLeoId) async {
    try {
      final rawResponse = await _apiService.get('/events/${widget.eventId}', withAuth: true);
      final rawData = rawResponse['event'] ?? rawResponse;
      
      // Check webmaster status
      bool isWebmaster = false;
      if (userLeoId != null && rawData['pageId'] != null) {
        try {
          final pageId = rawData['pageId'];
          final page = await _pageRepository.getPageById(pageId);
          isWebmaster = page.webmasterIds.contains(userLeoId);
        } catch (e) {
          print('Error checking webmaster status in background: $e');
        }
      }
      
      // Update cache - always store fresh copy
      _eventCache[widget.eventId] = _CachedEventData(
        rawData: Map<String, dynamic>.from(rawData),
        isWebmaster: isWebmaster,
        timestamp: DateTime.now(),
      );
      
      // Update UI if still mounted and data changed
      if (mounted) {
        final eventData = Map<String, dynamic>.from(rawData);
        if (currentUserId != null) {
          eventData['_currentUserId'] = currentUserId;
        }
        final event = Event.fromJson(eventData);
        
        setState(() {
          _event = event;
          _eventRawData = rawData;
          _isWebmaster = isWebmaster;
          _participantsCount = rawData['participantsCount'] ?? 
                              (rawData['participants']?.length ?? 0);
        });
      }
    } catch (e) {
      print('Background refresh failed: $e');
      // Silently fail - cached data is still valid
    }
  }
  
  // Clear cache for this event (call when event is updated/deleted)
  static void clearEventCache(String eventId) {
    _eventCache.remove(eventId);
  }
  
  // Clear all event caches (call on app refresh or user change)
  static void clearAllEventCache() {
    _eventCache.clear();
  }
  
  Future<void> _editEvent() async {
    print('🟡 _editEvent called');
    if (_event == null || _eventRawData == null) {
      print('❌ Event or eventRawData is null');
      return;
    }
    print('🟡 Navigating to edit screen');
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(
          pageId: _eventRawData!['pageId'],
          pageName: _eventRawData!['pageName'] ?? _event!.organizer,
          pageLogo: _eventRawData!['pageLogo'],
          clubId: _eventRawData!['clubId'],
          districtId: _eventRawData!['districtId'],
        ),
      ),
    );
    
    if (result == true) {
      // Clear cache and refresh event
      clearEventCache(widget.eventId);
      _loadEvent();
      final eventsScreenState = EventsListScreen.globalKey.currentState;
      if (eventsScreenState != null) {
        eventsScreenState.refreshEvents();
      }
    }
  }
  
  Future<void> _deleteEvent() async {
    print('🔴 _deleteEvent called');
    if (_event == null) {
      print('❌ Event is null');
      return;
    }
    print('🔴 Showing delete confirmation dialog');
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${_event!.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      await _eventRepository.deleteEvent(widget.eventId);
      
      if (mounted) {
        // Refresh events list
        final eventsScreenState = EventsListScreen.globalKey.currentState;
        if (eventsScreenState != null) {
          eventsScreenState.refreshEvents();
        }
        
        // Navigate back
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete event: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleJoinEvent() async {
    if (_event == null) return;
    
    // Don't allow joining/leaving expired events
    if (_event!.isExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('This event has expired. You cannot join or leave.'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // If already joined, just leave
    if (_event!.isJoined) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUserId = authProvider.user?.id;
        
        final updatedEvent = await _eventRepository.toggleJoinEvent(
          _event!.id,
          false,
          currentUserId: currentUserId,
        );

        if (mounted) {
          setState(() {
            _event = updatedEvent;
            // Update participant count - decrement when leaving
            if (_participantsCount > 0) {
              _participantsCount--;
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Left ${_event!.title}'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to leave event: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
      return;
    }

    // If not joined, show join form
    _showJoinForm();
  }

  void _showJoinForm() {
    // Get user information to auto-fill
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    final nameController = TextEditingController(text: user?.fullName ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.event_available,
                        color: Color(0xFFFFD700),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Join Event',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Raleway',
                            ),
                          ),
                          Text(
                            _event?.title ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Name field
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'Enter your full name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
                    ),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                
                // Email field
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email *',
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
                    ),
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Email is required';
                    if (!v!.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Phone field
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Notes field
                TextFormField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Additional Notes',
                    hintText: 'Any special requirements or notes...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      
                      Navigator.pop(context); // Close dialog
                      
                      // Join the event
                      try {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        final currentUserId = authProvider.user?.id;
                        
                        final updatedEvent = await _eventRepository.toggleJoinEvent(
                          _event!.id,
                          true,
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          phone: phoneController.text.trim().isEmpty 
                              ? null 
                              : phoneController.text.trim(),
                          notes: notesController.text.trim().isEmpty 
                              ? null 
                              : notesController.text.trim(),
                          currentUserId: currentUserId,
                        );

                        if (mounted) {
                          setState(() {
                            _event = updatedEvent;
                            // Update participant count - increment when joining
                            _participantsCount++;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Successfully joined ${_event!.title}!'),
                              backgroundColor: AppColors.success,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to join event: ${e.toString()}'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Join Event',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Raleway',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: _buildModernLoadingScreen(),
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

    ResponsiveUtils.init(context);
    final screenHeight = ResponsiveUtils.screenHeight;
    final bubbleWidth = ResponsiveUtils.bs(900);
    final bubbleHeight = screenHeight + ResponsiveUtils.bs(350);
    
    // Top Yellow Bubble 02 - position and rotation (adjust these values)
    final topYellowBubbleLeft = ResponsiveUtils.bw(-241.13); // Change this to adjust horizontal position
    final topYellowBubbleTop = ResponsiveUtils.bh(-300); // Change this to adjust vertical position
    final topYellowBubbleRotation = 1.0; // Change this to rotate bubble (degrees, positive = clockwise)
    
    // Top Black Bubble 01 - position and rotation (adjust these values)
    final topBlackBubbleLeft = ResponsiveUtils.bw(-271.13); // Change this to adjust horizontal position
    final topBlackBubbleTop = ResponsiveUtils.bh(-280); // Change this to adjust vertical position
    final topBlackBubbleRotation = 10.0; // Change this to rotate bubble (degrees, positive = clockwise)
    
    // Bottom Yellow Bubble - position and rotation (adjust these values)
    final bubbleLeft = ResponsiveUtils.bw(-211.13); // Change this to adjust horizontal position
    final bubbleTop = ResponsiveUtils.bh(-280); // Change this to adjust vertical position
    final bubbleRotation = 0.0; // Change this to rotate bubbles (e.g., 15.0 for 15 degrees)
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. TOP YELLOW BUBBLE 02 - Animate from top
          Positioned(
            left: topYellowBubbleLeft,
            top: topYellowBubbleTop,
            child: Transform.rotate(
              angle: topYellowBubbleRotation * 3.14159 / 180, // Convert degrees to radians
              child: FadeTransition(
                opacity: _topBubblesFadeAnimation,
                child: SlideTransition(
                  position: _topBubblesSlideAnimation,
                  child: Hero(
                    tag: 'event_top_yellow_bubble',
                    child: SizedBox(
                      width: bubbleWidth,
                      height: bubbleHeight,
                      child: CustomPaint(
                        size: Size(bubbleWidth, bubbleHeight),
                        painter: _EventTopYellowBubblePainter(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // 2. TOP BLACK BUBBLE 01 - Animate from top
          Positioned(
            left: topBlackBubbleLeft,
            top: topBlackBubbleTop,
            child: Transform.rotate(
              angle: topBlackBubbleRotation * 2.14159 / 180, // Convert degrees to radians
              child: FadeTransition(
                opacity: _topBubblesFadeAnimation,
                child: SlideTransition(
                  position: _topBubblesSlideAnimation,
                  child: Hero(
                    tag: 'event_top_black_bubble',
                    child: SizedBox(
                      width: bubbleWidth,
                      height: bubbleHeight,
                      child: CustomPaint(
                        size: Size(bubbleWidth, bubbleHeight),
                        painter: _EventTopBlackBubblePainter(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // 3. BOTTOM YELLOW BUBBLE - Animate from right
          Positioned(
            left: bubbleLeft,
            top: bubbleTop,
            child: Transform.rotate(
              angle: bubbleRotation * 3.14159 / 180, // Convert degrees to radians
              child: FadeTransition(
                opacity: _bottomBubblesFadeAnimation,
                child: SlideTransition(
                  position: _bottomBubblesSlideAnimation,
                  child: Hero(
                    tag: 'event_bottom_bubbles_background',
                    child: SizedBox(
                      width: bubbleWidth,
                      height: bubbleHeight,
                      child: CustomPaint(
                        size: Size(bubbleWidth, bubbleHeight),
                        painter: _EventBottomBubblesPainter(),
                      ),
                    ),
                  ),
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

    );
  }
  
  Widget _buildContent() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: ResponsiveUtils.dp(20)),
        
            // Event Image - Centered, Circular
        Container(
          width: ResponsiveUtils.dp(100),
          height: ResponsiveUtils.dp(100),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFD700).withOpacity(0.5),
              width: ResponsiveUtils.dp(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: ResponsiveUtils.dp(8),
                offset: Offset(0, ResponsiveUtils.dp(2)),
              ),
            ],
          ),
          child: ClipOval(
            child: _buildEventImage(),
          ),
        ),
        
        SizedBox(height: ResponsiveUtils.dp(12)),
        
        // Event Title - Centered
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.dp(20)),
          child: Text(
            _event!.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w800,
              fontSize: ResponsiveUtils.sp(28),
              color: Colors.black,
              letterSpacing: -0.52,
            ),
          ),
        ),
        
        SizedBox(height: ResponsiveUtils.dp(4)),
        
        // Organized by label - Centered
        Text(
          'Organized by:',
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w700,
            fontSize: ResponsiveUtils.sp(10),
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
        
        const SizedBox(height: 8),
        
        // Participant count - Centered
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 16,
              color: Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(
              '$_participantsCount ${_participantsCount == 1 ? 'participant' : 'participants'} joined',
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Location - Centered
        if (_eventRawData?['location'] != null && (_eventRawData!['location'] as String).isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: Colors.black54,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _eventRawData!['location'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        
        // Category - Centered
        if (_eventRawData?['category'] != null && (_eventRawData!['category'] as String).isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 40, right: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.category_outlined,
                  size: 14,
                  color: Colors.black54,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _getCategoryLabel(_eventRawData!['category']),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        
        if ((_eventRawData?['location'] != null && (_eventRawData!['location'] as String).isNotEmpty) ||
            (_eventRawData?['category'] != null && (_eventRawData!['category'] as String).isNotEmpty))
          const SizedBox(height: 12),
        
        // Join/Joined Button - Centered, full width
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: GestureDetector(
            onTap: _event!.isExpired ? null : _toggleJoinEvent,
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: _event!.isExpired
                    ? Colors.grey[400]
                    : (_event!.isJoined
                        ? const Color(0xFFFFD700)
                        : Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                _event!.isExpired
                    ? 'Event Expired'
                    : (_event!.isJoined ? 'Joined' : 'Join'),
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: _event!.isExpired ? Colors.grey[700] : Colors.white,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Download Documents Button - Only show if documents exist
        if (_eventRawData != null && 
            _eventRawData!['documents'] != null && 
            (_eventRawData!['documents'] as List).isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: GestureDetector(
              onTap: () => _downloadDocuments(_eventRawData!['documents'] as List),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A4A4A),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.download,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Download Documents',
                      style: const TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Description Box - Fixed responsive width with flexible height
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive width: 90% of screen width, clamped between 300 and 400
            final screenWidth = ResponsiveUtils.screenWidth;
            final screenHeight = ResponsiveUtils.screenHeight;
            final containerWidth = (screenWidth * 0.9).clamp(ResponsiveUtils.dp(300), ResponsiveUtils.dp(400));
            
            // Calculate responsive height: increased for better visibility
            double heightPercentage;
            double minHeight;
            double maxHeight;
            
            if (screenHeight < 600) {
              heightPercentage = 0.35;
              minHeight = ResponsiveUtils.dp(200);
              maxHeight = ResponsiveUtils.dp(250);
            } else if (screenHeight <= 800) {
              heightPercentage = 0.42;
              minHeight = ResponsiveUtils.dp(280);
              maxHeight = ResponsiveUtils.dp(400);
            } else if (screenHeight <= 1000) {
              heightPercentage = 0.50;
              minHeight = ResponsiveUtils.dp(400);
              maxHeight = ResponsiveUtils.dp(600);
            } else {
              // Large screens (> 1000px)
              heightPercentage = 0.55;
              minHeight = ResponsiveUtils.dp(550);
              maxHeight = ResponsiveUtils.dp(700);
            }
            
            final containerHeight = (screenHeight * heightPercentage).clamp(minHeight, maxHeight);
            
            return Center(
              child: Container(
                width: containerWidth,
                constraints: BoxConstraints(
                  maxHeight: containerHeight,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.dp(21)),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(ResponsiveUtils.dp(16)),
                  child: Text(
                    (_eventRawData?['description'] as String?) ?? 
                    _event!.description ?? 
                    'No description available',
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
            );
          },
        ),
            ],
          ),
        ),
        // Back arrow - positioned higher than default
        Positioned(
          left: 10,
          top: 0, // Higher than default CustomBackButton position
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ),
        // Edit, Delete, and View Participants buttons (for webmasters) - positioned at top right
        // Placed last in Stack so they're on top and can receive taps
        if (_isWebmaster)
          Positioned(
            top: ResponsiveUtils.dp(20),
            right: ResponsiveUtils.dp(20),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Edit and Delete buttons in a row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            print('🟡 Edit button tapped');
                            _editEvent();
                          },
                          borderRadius: BorderRadius.circular(ResponsiveUtils.dp(12)),
                          child: Container(
                            padding: EdgeInsets.all(ResponsiveUtils.dp(10)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(ResponsiveUtils.dp(12)),
                              border: Border.all(color: const Color(0xFFFFD700), width: ResponsiveUtils.dp(2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: ResponsiveUtils.dp(8),
                                  offset: Offset(0, ResponsiveUtils.dp(2)),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              color: const Color(0xFFFFD700),
                              size: ResponsiveUtils.dp(20),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.dp(8)),
                      // Delete button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            print('🔴 Delete button tapped');
                            _deleteEvent();
                          },
                          borderRadius: BorderRadius.circular(ResponsiveUtils.dp(12)),
                          child: Container(
                            padding: EdgeInsets.all(ResponsiveUtils.dp(10)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(ResponsiveUtils.dp(12)),
                              border: Border.all(color: Colors.red, width: ResponsiveUtils.dp(2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: ResponsiveUtils.dp(8),
                                  offset: Offset(0, ResponsiveUtils.dp(2)),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red,
                              size: ResponsiveUtils.dp(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUtils.dp(16)),
                  // View Participants button (under delete button)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        print('🔵 Participants button tapped');
                        _viewParticipants();
                      },
                      borderRadius: BorderRadius.circular(ResponsiveUtils.dp(12)),
                      child: Container(
                        padding: EdgeInsets.all(ResponsiveUtils.dp(10)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(ResponsiveUtils.dp(12)),
                          border: Border.all(color: Colors.blue, width: ResponsiveUtils.dp(2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: ResponsiveUtils.dp(8),
                              offset: Offset(0, ResponsiveUtils.dp(2)),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.people_rounded,
                          color: Colors.blue,
                          size: ResponsiveUtils.dp(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEventImage() {
    // Use page logo (imageUrl) instead of banner image for the avatar
    final imageUrl = _event!.imageUrl;
    
    if (imageUrl.isEmpty || imageUrl == 'assets/images/Events/artist-2 1 (2).png') {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.event, size: 50, color: Colors.grey),
      );
    }

    // Check if it's a network URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.event, size: 50, color: Colors.grey),
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
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.event, size: 50, color: Colors.grey),
            ),
          );
        } else {
          // File doesn't exist, show placeholder
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.event, size: 50, color: Colors.grey),
          );
        }
      } catch (e) {
        // Error loading file, show placeholder
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.event, size: 50, color: Colors.grey),
        );
      }
    }
    
    // If it looks like an asset path (starts with 'assets/'), try Image.asset
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.event, size: 50, color: Colors.grey),
        ),
      );
    }
    
    // Fallback to placeholder for unknown formats
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.event, size: 50, color: Colors.grey),
    );
  }

  Future<void> _downloadDocuments(List<dynamic> documents) async {
    if (documents.isEmpty) return;

    try {
      for (var docUrl in documents) {
        if (docUrl is String && docUrl.isNotEmpty) {
          final uri = Uri.parse(docUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Could not open document: $docUrl'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download documents: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _viewParticipants() async {
    print('🔵 _viewParticipants called');
    if (_event == null) {
      print('❌ Event is null');
      return;
    }

    print('🔵 Event ID: ${_event!.id}');
    print('🔵 Is Webmaster: $_isWebmaster');

    try {
      // Show loading dialog
      if (!mounted) {
        print('❌ Widget not mounted');
        return;
      }
      
      print('🔵 Showing loading dialog');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      print('🔍 Fetching participants for event: ${_event!.id}');
      final participants = await _eventRepository.getEventParticipants(_event!.id);
      print('✅ Received ${participants.length} participants');
      
      // Check if still mounted before showing dialog
      if (!mounted) {
        print('❌ Widget not mounted after API call');
        try {
          Navigator.pop(context); // Close loading dialog
        } catch (e) {
          print('❌ Error closing loading dialog: $e');
        }
        return;
      }

      print('🔵 Closing loading dialog and showing participants dialog');
      Navigator.pop(context); // Close loading dialog

      // Show participants dialog
      if (!mounted) {
        print('❌ Widget not mounted before showing participants dialog');
        return;
      }
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.people_rounded,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Event Participants',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Raleway',
                              ),
                            ),
                            Text(
                              '${participants.length} ${participants.length == 1 ? 'participant' : 'participants'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Participants list
                  Expanded(
                    child: participants.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No participants yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontFamily: 'Nunito Sans',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Participants will appear here once they join',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontFamily: 'Nunito Sans',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: participants.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final participant = participants[index];
                              return InkWell(
                                onTap: () => _showParticipantDetails(participant),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  leading: participant['profilePhoto'] != null
                                      ? ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: participant['profilePhoto'],
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              width: 48,
                                              height: 48,
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              width: 48,
                                              height: 48,
                                              color: Colors.grey[300],
                                              child: Center(
                                                child: Text(
                                                  (participant['fullName'] ?? 'U')
                                                      .substring(0, 1)
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Colors.grey[300],
                                          child: Text(
                                            (participant['fullName'] ?? 'U')
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                  title: Text(
                                    participant['fullName'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (participant['email'] != null)
                                        Text(
                                          participant['email'],
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      if (participant['phoneNumber'] != null)
                                        Text(
                                          participant['phoneNumber'],
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Raleway',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error loading participants: $e');
      print('❌ Stack trace: $stackTrace');
      if (mounted) {
        // Close loading dialog if still open
        try {
          Navigator.pop(context);
        } catch (popError) {
          print('❌ Error closing dialog: $popError');
          // Dialog might already be closed
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load participants: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        print('❌ Widget not mounted, cannot show error');
      }
    }
  }

  void _showParticipantDetails(Map<String, dynamic> participant) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Participant Details',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Raleway',
                          ),
                        ),
                        Text(
                          participant['fullName'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Participant Info
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Photo
                      Center(
                        child: participant['profilePhoto'] != null
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: participant['profilePhoto'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Text(
                                        (participant['fullName'] ?? 'U')
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 32,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey[300],
                                child: Text(
                                  (participant['fullName'] ?? 'U')
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Full Name
                      _buildDetailRow(
                        icon: Icons.person_outline,
                        label: 'Full Name',
                        value: participant['fullName'] ?? 'Not provided',
                      ),
                      const SizedBox(height: 16),
                      
                      // Email
                      _buildDetailRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: participant['email'] ?? 'Not provided',
                      ),
                      const SizedBox(height: 16),
                      
                      // Phone Number
                      _buildDetailRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone Number',
                        value: participant['phoneNumber'] ?? 'Not provided',
                      ),
                      const SizedBox(height: 16),
                      
                      // Notes
                      if (participant['notes'] != null && participant['notes'].toString().isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.note_outlined,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Additional Notes',
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Text(
                                participant['notes'],
                                style: const TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      
                      // Joined Date
                      if (participant['joinedAt'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: _buildDetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Joined On',
                            value: _formatDate(participant['joinedAt']),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    try {
      DateTime dateTime;
      if (date is String) {
        dateTime = DateTime.parse(date);
      } else if (date is Map && date['_seconds'] != null) {
        // Firestore Timestamp format
        dateTime = DateTime.fromMillisecondsSinceEpoch(date['_seconds'] * 1000);
      } else {
        return 'Unknown date';
      }
      
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  String _getCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'general':
        return 'General';
      case 'community':
        return 'Community Service';
      case 'fundraiser':
        return 'Fundraiser';
      case 'meeting':
        return 'Meeting';
      case 'workshop':
        return 'Workshop';
      case 'social':
        return 'Social Event';
      case 'sports':
        return 'Sports';
      case 'environment':
        return 'Environment';
      case 'competition':
        return 'Competition';
      default:
        return category;
    }
  }

  Widget _buildModernLoadingScreen() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated logo placeholder with gradient
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFFD700).withOpacity(0.3),
                          const Color(0xFFFFD700).withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.5),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.event,
                        size: 50,
                        color: Color(0xFF8F7902),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Animated text
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - value)),
                  child: const Text(
                    'Loading event...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8F7902),
                      fontFamily: 'Poppins',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          
          // Modern progress indicator
          SizedBox(
            width: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                minHeight: 6,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFFFFD700),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Pulsing dots animation with repeating animation
          _PulsingDots(),
        ],
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value + delay) % 1.0;
            final opacity = value < 0.5 ? value * 2 : 2 - (value * 2);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

/// Custom painter for Event Detail Top Yellow Bubble 02
/// viewBox="0 0 885 1301"
class _EventTopYellowBubblePainter extends CustomPainter {
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for Event Detail Top Black Bubble 01
/// viewBox="0 0 885 1301"
class _EventTopBlackBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 885;
    final scaleY = size.height / 1301;

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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for Event Detail Bottom Yellow Bubble (Yellow bubble 04)
/// viewBox="0 0 885 1301"
class _EventBottomBubblesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 885;
    final scaleY = size.height / 1301;

    // Yellow bubble 04 - p17c37d00 path (bottom yellow bubble)
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

/// Cached event data structure
class _CachedEventData {
  final Map<String, dynamic> rawData;
  final bool isWebmaster;
  final DateTime timestamp;

  _CachedEventData({
    required this.rawData,
    required this.isWebmaster,
    required this.timestamp,
  });
}
