import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/event.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/event_card.dart';
import '../../widgets/custom_back_button.dart';
import 'event_detail_screen.dart';

/// Events List Screen - Matches Figma design exactly from Provide Frontend Code
class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});
  
  static final GlobalKey<_EventsListScreenState> globalKey = GlobalKey<_EventsListScreenState>();

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _eventRepository = EventRepository();
  List<Event> _events = [];
  bool _isLoading = true;
  bool _hasLoadedWithUser = false; // Track if we've successfully loaded with a user ID
  late AnimationController _animationController;
  late Animation<Offset> _bubblesSlideAnimation;
  late Animation<Offset> _bottomYellowBubbleSlideAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _bubblesFadeAnimation;
  late Animation<double> _contentFadeAnimation;
  DateTime? _lastAnimationTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Wait for next frame to ensure auth provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
      // Also check periodically if user becomes available
      _checkAndReloadIfUserAvailable();
    });
    
    // Initialize animation controller first
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Bubbles animation - coming from outside (top-left)
    _bubblesSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, -0.5), // Start from top-left outside
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Bottom yellow bubble animation - coming from right outside
    _bottomYellowBubbleSlideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0), // Start from right outside
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
    
    // Content animation - coming from bottom
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3), // Start from below
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    // Don't start animation immediately - wait for restartAnimation() call
    // This ensures bubbles are hidden initially and only animate when tab is visited
  }
  
  // Removed _startVisibilityCheck - animation is now controlled by MainScreen
  
  // Public method to restart animation (called from MainScreen)
  void restartAnimation() {
    if (!mounted) return;
    
    final now = DateTime.now();
    // Only restart if last animation was more than 200ms ago (debounce)
    // This ensures animation restarts every time tab becomes visible
    if (_lastAnimationTime == null || 
        now.difference(_lastAnimationTime!).inMilliseconds > 200) {
      _lastAnimationTime = now;
      
      // Stop any ongoing animation
      if (_animationController.isAnimating) {
        _animationController.stop();
      }
      
      // Reset to beginning (value 0.0) and forward to ensure animation plays
      _animationController.reset();
      
      // Start animation immediately - no delay needed
      _animationController.forward();
    }
  }
  
  // Public method to refresh events (called after creating/editing/deleting events)
  void refreshEvents() {
    if (mounted) {
      _loadEvents();
    }
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      restartAnimation();
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Animation is controlled by MainScreen via restartAnimation() call
    // Reload events if auth provider is now ready and we haven't loaded with user ID yet
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id;
    if (currentUserId != null && !_hasLoadedWithUser && !_isLoading) {
      print('🔄 Reloading events now that auth provider is ready (userId: $currentUserId)');
      _loadEvents();
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }
  
  // Check if user is now available and reload events if needed
  void _checkAndReloadIfUserAvailable() {
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id;
    
    if (currentUserId != null && !_hasLoadedWithUser && !_isLoading) {
      print('🔄 User is now available, reloading events (userId: $currentUserId)');
      _loadEvents();
    } else if (currentUserId == null && !_hasLoadedWithUser) {
      // User still not available, check again in 500ms
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _checkAndReloadIfUserAvailable();
      });
    }
  }

  Future<void> _loadEvents() async {
    try {
      // Get current user ID from auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      var currentUserId = authProvider.user?.id;
      final isSuperAdmin = authProvider.isSuperAdmin;
      
      // If user is not ready yet, wait a bit and retry multiple times (auth provider might still be initializing)
      if (currentUserId == null && !isSuperAdmin) {
        print('⏳ Waiting for auth provider to be ready...');
        // Try up to 3 times with increasing delays
        for (int attempt = 1; attempt <= 3; attempt++) {
          await Future.delayed(Duration(milliseconds: 200 * attempt));
          final retryAuthProvider = Provider.of<AuthProvider>(context, listen: false);
          final retryUserId = retryAuthProvider.user?.id;
          if (retryUserId != null) {
            currentUserId = retryUserId;
            print('✅ Auth provider ready on attempt $attempt: $currentUserId');
            break;
          } else if (attempt < 3) {
            print('⏳ Attempt $attempt failed, retrying...');
          } else {
            print('⚠️ Warning: currentUserId is still null after 3 attempts - will load events without user context');
          }
        }
      }
      
      // Clear event detail cache on refresh to ensure fresh data with correct user context
      EventDetailScreen.clearAllEventCache();
      
      // Debug: Log current user ID to verify it's being passed
      if (currentUserId != null) {
        print('📋 Loading events for user: $currentUserId');
      } else {
        print('⚠️ Warning: currentUserId is null when loading events');
      }
      
      // For super admin without token, show empty list gracefully
      if (isSuperAdmin) {
        try {
          final events = await _eventRepository.getAllEvents(currentUserId: currentUserId);
          if (mounted) {
            setState(() {
              // Filter out events that expired more than 2 days ago
              _events = events.where((event) => !event.shouldBeRemoved).toList();
              _isLoading = false;
            });
          }
        } catch (e) {
          // Super admin might not have backend access - show empty list
          if (mounted) {
            setState(() {
              _events = [];
              _isLoading = false;
            });
          }
        }
      } else {
        final events = await _eventRepository.getAllEvents(currentUserId: currentUserId);
        if (mounted) {
          setState(() {
            // Filter out events that expired more than 2 days ago
            _events = events.where((event) => !event.shouldBeRemoved).toList();
            _isLoading = false;
            // Mark that we've loaded with a user ID if we have one
            if (currentUserId != null) {
              _hasLoadedWithUser = true;
            }
          });
          
          // Debug: Log join status for each event
          if (currentUserId != null) {
            print('📊 Events loaded: ${_events.length} total (with userId: $currentUserId)');
            for (var event in _events) {
              if (event.isJoined) {
                print('   ✅ ${event.title}: JOINED');
              }
            }
          } else {
            print('⚠️ Events loaded without userId - join status cannot be determined');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Only show error if not super admin (super admin might not have backend access)
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isSuperAdmin) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load events: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        } else {
          // Super admin - just show empty list
          setState(() {
            _events = [];
          });
        }
      }
    }
  }

  Future<void> _toggleJoinEvent(Event event) async {
    if (event.isExpired) return;
    
    // If already joined, just leave
    if (event.isJoined) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUserId = authProvider.user?.id;
        
        final updatedEvent = await _eventRepository.toggleJoinEvent(
          event.id,
          false,
          currentUserId: currentUserId,
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
              content: Text('Left ${event.title}'),
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
    _showJoinForm(event);
  }

  void _showJoinForm(Event event) {
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
                            event.title,
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
                        final currentUserId = authProvider.user?.id;
                        
                        final updatedEvent = await _eventRepository.toggleJoinEvent(
                          event.id,
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
                            final index = _events.indexWhere((e) => e.id == event.id);
                            if (index != -1) {
                              _events[index] = updatedEvent;
                            }
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Successfully joined ${event.title}!'),
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
    // Animation is controlled by MainScreen via restartAnimation() call
    // No automatic animation start here - bubbles should be hidden initially
    
    ResponsiveUtils.init(context);
    final screenHeight = ResponsiveUtils.screenHeight;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.hardEdge, // Prevent overflow
        children: [
          // 1. BACKGROUND LAYER - Top bubbles (black and yellow top) - from top-left
          Positioned(
            left: ResponsiveUtils.bw(-218.41),
            top: ResponsiveUtils.bh(-280),
            child: FadeTransition(
              opacity: _bubblesFadeAnimation,
              child: SlideTransition(
                position: _bubblesSlideAnimation,
                child: Hero(
                  tag: 'event_bubbles_background',
                  child: SizedBox(
                    width: ResponsiveUtils.bs(900),
                    height: screenHeight + ResponsiveUtils.bs(350),
                    child: CustomPaint(
                      size: Size(ResponsiveUtils.bs(900), screenHeight + ResponsiveUtils.bs(350)),
                      painter: _TopBubblesPainter(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // 2. Bottom yellow bubble - from right
          Positioned(
            left: ResponsiveUtils.bw(-218.41),
            top: ResponsiveUtils.bh(-280),
            child: FadeTransition(
              opacity: _bubblesFadeAnimation,
              child: SlideTransition(
                position: _bottomYellowBubbleSlideAnimation,
                child: SizedBox(
                  width: ResponsiveUtils.bs(900),
                  height: screenHeight + ResponsiveUtils.bs(350),
                  child: CustomPaint(
                    size: Size(ResponsiveUtils.bs(900), screenHeight + ResponsiveUtils.bs(350)),
                    painter: _BottomYellowBubblePainter(),
                  ),
                ),
              ),
            ),
          ),

          // 2. TIMELINE LINE - Positioned to align with center of date circles
          // Circle is at left: 10dp within SizedBox of width 53dp, circle is 33dp wide
          // Circle center is at: 10 + 33/2 = 26.5dp from left of SizedBox
          // SizedBox is at: ResponsiveUtils.spacingM + ResponsiveUtils.dp(4) from screen left
          // So line should be at: ResponsiveUtils.spacingM + ResponsiveUtils.dp(4) + ResponsiveUtils.dp(26.5)
          // But we need to account for the line width (2dp), so center it: subtract 1dp
          Positioned(
            left: ResponsiveUtils.spacingM + ResponsiveUtils.dp(23) + ResponsiveUtils.dp(26.5) - ResponsiveUtils.dp(1),
            top: ResponsiveUtils.bh(200), // Start below the black bubble header
            bottom: 0,
            child: Container(
              width: ResponsiveUtils.dp(2),
              color: Colors.black,
            ),
          ),

          // Back button - top left
          CustomBackButton(
            backgroundColor: Colors.black, // Dark area (image/shape background)
            iconSize: 24,
            navigateToHome: true,
          ),

          // "Events" title - Figma: left: calc(16.67% + 2px), top: 48px
          Positioned(
            left: ResponsiveUtils.screenWidth * 0.1667 + ResponsiveUtils.dp(2),
            top: ResponsiveUtils.bh(48),
            child: Text(
              'Events',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: ResponsiveUtils.dp(50),
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -ResponsiveUtils.dp(0.52),
                height: 1.0,
              ),
            ),
          ),

          // 5. SCROLLABLE CONTENT LAYER - starts below header area, properly aligned
          // Animated to slide up from bottom
          Positioned(
            left: 0,
            right: 0,
            top: ResponsiveUtils.bh(175),
            bottom: 0,
            child: FadeTransition(
              opacity: _contentFadeAnimation,
              child: SlideTransition(
                position: _contentSlideAnimation,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: ResponsiveUtils.dp(20)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(35)),
                      child: Container(
                        width: ResponsiveUtils.dp(375),
                        constraints: BoxConstraints(
                          maxHeight: ResponsiveUtils.screenHeight - ResponsiveUtils.bh(175) - MediaQuery.of(context).padding.bottom - ResponsiveUtils.dp(40),
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(ResponsiveUtils.r(35)),
                        ),
                        child: _isLoading
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.all(ResponsiveUtils.dp(20)),
                                  child: const CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : _events.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(ResponsiveUtils.dp(20)),
                                      child: Text(
                                        'No events available',
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: ResponsiveUtils.bodyMedium,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ResponsiveUtils.spacingM + ResponsiveUtils.dp(4),
                                      vertical: ResponsiveUtils.spacingM - ResponsiveUtils.dp(6),
                                    ),
                                    child: Column(
                                      children: _events.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final event = entry.value;
                                        final eventColor = _getEventColor(event);
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: index < _events.length - 1 ? ResponsiveUtils.dp(26) : ResponsiveUtils.dp(16),
                                          ),
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              // Calculate responsive height based on screen size
                                              ResponsiveUtils.init(context);
    final screenHeight = ResponsiveUtils.screenHeight;
                                              final cardHeight = screenHeight * 0.2; // 20% of screen height
                                              final responsiveHeight = cardHeight.clamp(ResponsiveUtils.dp(140), ResponsiveUtils.dp(180)); // Min 140, Max 180
                                              
                                              return SizedBox(
                                                height: responsiveHeight,
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                // Date Badge and Triangle Column - aligned with timeline
                                                SizedBox(
                                                  width: ResponsiveUtils.dp(53),
                                                  child: Stack(
                                                    clipBehavior: Clip.none,
                                                    children: [
                                                      // Date Badge (33×33 black circle) - centered on timeline
                                                      Positioned(
                                                        left: ResponsiveUtils.dp(10),
                                                        top: ResponsiveUtils.dp(64),
                                                        child: Container(
                                                          width: ResponsiveUtils.dp(33),
                                                          height: ResponsiveUtils.dp(33),
                                                          decoration: const BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: Colors.black,
                                                          ),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                event.date,
                                                                style: TextStyle(
                                                                  fontFamily: 'Nunito Sans',
                                                                  fontWeight: FontWeight.w800,
                                                                  fontSize: ResponsiveUtils.dp(8),
                                                                  color: Colors.white,
                                                                  height: 1.0,
                                                                ),
                                                              ),
                                                              Text(
                                                                event.month,
                                                                style: TextStyle(
                                                                  fontFamily: 'Nunito Sans',
                                                                  fontWeight: FontWeight.w800,
                                                                  fontSize: ResponsiveUtils.dp(8),
                                                                  color: Colors.white,
                                                                  height: 1.0,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // Triangle Arrow Indicator
                                                      Positioned(
                                                        left: ResponsiveUtils.dp(36),
                                                        top: ResponsiveUtils.dp(62),
                                                        child: Transform.rotate(
                                                          angle: -1.5708,
                                                          child: CustomPaint(
                                                            size: Size(ResponsiveUtils.dp(36), ResponsiveUtils.dp(26)),
                                                            painter: _TrianglePainter(color: eventColor.withOpacity(0.2)),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: ResponsiveUtils.dp(8)),
                                                // Event Card
                                                Expanded(
                                                  child: EventCard(
                                                    event: event,
                                                    onTap: () => _openEventDetail(event),
                                                    onJoinToggle: event.isExpired ? null : () => _toggleJoinEvent(event),
                                                  ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    }).toList(),
                                    ),
                                  ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
    );
  }
}

/// Custom painter for top bubbles (black and yellow top) - exact SVG paths from React Events.tsx
class _TopBubblesPainter extends CustomPainter {
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for bottom yellow bubble - exact SVG path from React Events.tsx
class _BottomYellowBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Scale factors to match viewBox="0 0 845 1222"
    final scaleX = size.width / 845;
    final scaleY = size.height / 1222;

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
