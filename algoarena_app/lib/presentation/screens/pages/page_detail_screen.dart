import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../core/constants/colors.dart';
import '../../../data/models/page.dart' as models;
import '../../../data/models/post.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/page_follow_provider.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/comment_dialog.dart';
import '../home/home_screen.dart';
import '../home/edit_post_screen.dart';
import '../events/create_event_screen.dart';
import '../events/events_list_screen.dart';
import 'edit_page_screen.dart';
import 'create_page_post_screen.dart';

/// Page Detail Screen - Shows page info, stats, and posts
/// Similar to ClubProfileScreen but uses real data from backend
class PageDetailScreen extends StatefulWidget {
  final models.Page page;

  const PageDetailScreen({
    super.key,
    required this.page,
  });

  @override
  State<PageDetailScreen> createState() => _PageDetailScreenState();
}

class _PageDetailScreenState extends State<PageDetailScreen>
    with TickerProviderStateMixin {
  final _pageRepository = PageRepository();
  final _postRepository = PostRepository();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Bubble animations (like search screen)
  late Animation<Offset> _bubblesSlideAnimation;
  late Animation<double> _bubblesFadeAnimation;
  
  bool _isLoading = true;
  bool _isLoadingPosts = true;
  
  int _postsCount = 0;
  int _eventsCount = 0;
  
  List<Post> _posts = [];
  models.Page? _pageData;
  User? _currentUser;
  
  // Local state for likes and comments (frontend only)
  final Map<String, bool> _likedPosts = {}; // postId -> isLiked
  final Map<String, int> _postLikesCount = {}; // postId -> likesCount
  final Map<String, List<Map<String, dynamic>>> _postComments = {}; // postId -> comments list
  final Map<String, int> _postCommentsCount = {}; // postId -> commentsCount (for real-time updates)
  
  // Double-tap like animation controllers
  final Map<String, AnimationController> _likeAnimationControllers = {};
  final Map<String, Animation<double>> _likeAnimations = {};
  
  // Button animation controllers
  late AnimationController _createPostButtonController;
  late AnimationController _createEventButtonController;
  late AnimationController _followButtonController;
  late Animation<double> _createPostButtonScale;
  late Animation<double> _createEventButtonScale;
  late Animation<double> _followButtonScale;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    // Bubbles animation - coming from outside (top-left) like search screen
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
    
    // Initialize button animation controllers
    _createPostButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _createEventButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _followButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _createPostButtonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _createPostButtonController, curve: Curves.easeInOut),
    );
    _createEventButtonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _createEventButtonController, curve: Curves.easeInOut),
    );
    _followButtonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _followButtonController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
    _loadPageData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _createPostButtonController.dispose();
    _createEventButtonController.dispose();
    _followButtonController.dispose();
    // Dispose all like animation controllers
    for (var controller in _likeAnimationControllers.values) {
      controller.dispose();
    }
    _likeAnimationControllers.clear();
    _likeAnimations.clear();
    super.dispose();
  }

  Future<void> _loadPageData() async {
    setState(() {
      _isLoading = true;
      _isLoadingPosts = true;
    });
    
    try {
      final followProvider = Provider.of<PageFollowProvider>(context, listen: false);
      
      // Use widget.page data immediately to show header faster
      models.Page? pageResult = widget.page;
      
      // Load all data in parallel for faster loading
      final results = await Future.wait([
        // Load page details (with fallback to widget.page)
        _pageRepository.getPageById(widget.page.id).catchError((e) {
          print('Warning: Failed to load page details: $e');
          return widget.page;
        }),
        // Load follow status
        followProvider.loadFollowStatus(widget.page.id).then((_) => null).catchError((e) {
          print('Warning: Failed to load follow status: $e');
          return null;
        }),
        // Load follower count
        followProvider.loadFollowerCount(widget.page.id).then((_) => null).catchError((e) {
          print('Warning: Failed to load follower count: $e');
          return null;
        }),
        // Load stats
        _pageRepository.getPageStats(widget.page.id).catchError((e) {
          print('Warning: Failed to load stats: $e');
          return <String, dynamic>{
            'followersCount': widget.page.followersCount,
            'postsCount': 0,
            'eventsCount': 0,
          };
        }),
        // Load posts
        _postRepository.getPostsByPage(widget.page.id).catchError((e) {
          print('Warning: Failed to load posts: $e');
          return <Post>[];
        }),
      ], eagerError: false);
      
      // Extract results
      pageResult = results[0] as models.Page;
      final statsResult = results[3] as Map<String, dynamic>;
      final posts = results[4] as List<Post>;
      
      // Update follower count in provider
      followProvider.setFollowStatus(
        widget.page.id,
        followProvider.isFollowing(widget.page.id),
        followersCount: statsResult['followersCount'] ?? widget.page.followersCount,
      );

      if (mounted) {
        setState(() {
          _pageData = pageResult;
          _postsCount = statsResult['postsCount'] ?? 0;
          _eventsCount = statsResult['eventsCount'] ?? 0;
          _posts = posts;
          _isLoading = false;
          _isLoadingPosts = false;
          
          // Initialize local like state and comment state from backend data
          if (_currentUser != null) {
            for (var post in posts) {
              if (post.id.isNotEmpty && _currentUser!.id.isNotEmpty) {
                if (post.isLikedBy(_currentUser!.id)) {
                  _likedPosts[post.id] = true;
                }
                _postLikesCount[post.id] = post.likesCount;
                
                // Initialize comment state from backend
                if (post.comments.isNotEmpty) {
                  _postComments[post.id] = post.comments.map((comment) {
                    final stableId = '${comment.userId}_${comment.createdAt.millisecondsSinceEpoch}';
                    return {
                      'id': stableId,
                      'text': comment.text,
                      'authorName': comment.userName,
                      'authorId': comment.userId,
                      'timestamp': comment.createdAt,
                    };
                  }).toList();
                  _postCommentsCount[post.id] = post.comments.length;
                } else if (!_postComments.containsKey(post.id)) {
                  _postComments[post.id] = [];
                  _postCommentsCount[post.id] = 0;
                } else {
                  _postCommentsCount[post.id] = _postComments[post.id]!.length;
                }
              }
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingPosts = false;
        });
        
        // Extract the actual error message
        String errorMessage = e.toString();
        if (errorMessage.contains('FormatException')) {
          errorMessage = 'Server returned invalid response. Please check if the backend is running correctly.';
        } else if (errorMessage.contains('Network error')) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else {
          errorMessage = errorMessage.replaceAll('Exception: ', '');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load page: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _toggleFollow() async {
    final followProvider = Provider.of<PageFollowProvider>(context, listen: false);
    
    if (followProvider.isToggling(widget.page.id)) return;
    
    try {
      final isFollowing = await followProvider.toggleFollow(widget.page.id);
      await followProvider.loadFollowerCount(widget.page.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFollowing ? 'Following ${_pageData?.name ?? widget.page.name}' : 'Unfollowed ${_pageData?.name ?? widget.page.name}'),
            backgroundColor: isFollowing ? AppColors.primary : Colors.grey,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final currentStatus = followProvider.isFollowing(widget.page.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${currentStatus ? 'unfollow' : 'follow'}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pageData ?? widget.page;
    final logoUrl = page.logo;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bubbles background (like search screen)
          FadeTransition(
            opacity: _bubblesFadeAnimation,
            child: SlideTransition(
              position: _bubblesSlideAnimation,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Bubble 02 - Yellow top left, rotated 158°
                  Positioned(
                    left: -131.97,
                    top: -205.67,
                    child: Transform.rotate(
                      angle: 158 * math.pi / 180,
                      child: SizedBox(
                        width: 311.014,
                        height: 367.298,
                        child: CustomPaint(
                          painter: _Bubble02Painter(),
                        ),
                      ),
                    ),
                  ),

                  // Bubble 01 - Black bottom right
                  Positioned(
                    left: 283.73,
                    top: 41,
                    child: SizedBox(
                      width: 243.628,
                      height: 266.77,
                      child: CustomPaint(
                        painter: _Bubble01Painter(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // Fixed header section (not scrollable)
                    Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          const SizedBox(height: 60), // Space for back arrow
                          
                          if (_isLoading)
                            _buildModernLoadingScreen()
                          else ...[
                            // Page profile header (different layout for district pages)
                            if (page.type == 'district')
                              _buildDistrictProfileHeader(page, logoUrl)
                            else
                              _buildProfileHeader(page, logoUrl),
                            const SizedBox(height: 24),
                            
                            // Action buttons (Create new post + Follow) for both club and district pages
                            _buildActionButtons(page),
                            const SizedBox(height: 16),
                            
                            // Divider to separate header from posts
                            Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              color: Colors.grey[200],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Scrollable posts section
                    Expanded(
                      child: _isLoading
                          ? const SizedBox.shrink()
                          : _isLoadingPosts
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              const Color(0xFFFFD700),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Loading posts...',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : _posts.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(40.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.article_outlined,
                                              size: 64,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No posts yet',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[600],
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Be the first to create a post!',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[500],
                                                fontFamily: 'Arimo',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      itemCount: _posts.length,
                                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: _buildPostCard(_posts[index]),
                                        );
                                      },
                                    ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Back arrow (CustomBackButton already has Positioned internally)
          CustomBackButton(
            onPressed: () => Navigator.pop(context),
          ),
          
          // Edit and Delete buttons for super admin/webmaster (top right) - Modern Design
          Builder(
            builder: (context) {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final isSuperAdmin = authProvider.isSuperAdmin;
              final userLeoId = authProvider.user?.leoId;
              final isWebmaster = userLeoId != null && (page.webmasterIds.contains(userLeoId));
              final canEdit = isWebmaster || isSuperAdmin;
              
              if (!canEdit) return const SizedBox.shrink();
              
              return Positioned(
                right: 8,
                top: 48,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit button - Modern rounded container with shadow
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPageScreen(page: page),
                            ),
                          );
                          if (result == true) {
                            _loadPageData(); // Reload page data after edit
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8F7902).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFFFFD700).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Color(0xFF8F7902),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete button (only for super admin) - Modern rounded container with shadow
                    if (isSuperAdmin)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showDeleteDialog(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
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
                        Icons.group,
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
                    'Loading page...',
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

  Widget _buildProfileHeader(models.Page page, String? logoUrl) {
    return Column(
      children: [
        // Page avatar with golden ring
        Container(
          width: 125,
          height: 125,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8F7902).withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF8F7902),
                width: 4,
              ),
            ),
            child: ClipOval(
              child: logoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: logoUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.primary,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.primary,
                        child: Center(
                          child: Text(
                            page.name.substring(0, 2).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.primary,
                      child: Center(
                        child: Text(
                          page.name.substring(0, 2).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Page name
        Text(
          page.name,
          style: const TextStyle(
            fontFamily: 'Arimo',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 4),
        
        // Description or type info
        Text(
          page.description ?? '${page.type == 'club' ? 'Club' : 'District'} Page',
          style: const TextStyle(
            fontFamily: 'Arimo',
            fontSize: 14,
            color: Color(0xFF6A7282),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        
        // Stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                    Consumer<PageFollowProvider>(
                      builder: (context, followProvider, child) {
                        final followersCount = followProvider.getFollowerCount(widget.page.id);
                        return _buildStatItem(_formatNumber(followersCount > 0 ? followersCount : widget.page.followersCount), 'Followers');
                      },
                    ),
            Container(
              width: 1,
              height: 30,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(horizontal: 24),
            ),
            _buildStatItem(_postsCount.toString(), 'Posts'),
            Container(
              width: 1,
              height: 30,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(horizontal: 24),
            ),
            _buildStatItem(_eventsCount.toString(), 'Events'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Arimo',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101828),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Arimo',
            fontSize: 12,
            color: Color(0xFF6A7282),
          ),
        ),
      ],
    );
  }


  // District page profile header - matches club page style with circular logo and map image in top right
  Widget _buildDistrictProfileHeader(models.Page page, String? logoUrl) {
    return Stack(
      children: [
        // Main content - same as club page
        Column(
          children: [
            // Page avatar with golden ring (circular like club page)
            Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8F7902).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF8F7902),
                    width: 4,
                  ),
                ),
                child: ClipOval(
                  child: logoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: logoUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.primary,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.primary,
                            child: Center(
                              child: Text(
                                page.name.substring(0, 2).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.primary,
                          child: Center(
                            child: Text(
                              page.name.substring(0, 2).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 40,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Page name
            Text(
              page.name,
              style: const TextStyle(
                fontFamily: 'Arimo',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 4),
            
            // Description or type info
            Text(
              page.description ?? 'District Page',
              style: const TextStyle(
                fontFamily: 'Arimo',
                fontSize: 14,
                color: Color(0xFF6A7282),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Consumer<PageFollowProvider>(
                  builder: (context, followProvider, child) {
                    final followersCount = followProvider.getFollowerCount(widget.page.id);
                    return _buildStatItem(_formatNumber(followersCount > 0 ? followersCount : widget.page.followersCount), 'Followers');
                  },
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                ),
                _buildStatItem(_postsCount.toString(), 'Posts'),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                ),
                _buildStatItem(_eventsCount.toString(), 'Events'),
              ],
            ),
          ],
        ),
        
        // District map image in top right corner (portrait rectangle) - Responsive
        if (page.mapImage != null)
          Positioned(
            top: MediaQuery.of(context).size.width * 0.02, // Responsive margin from top (2% of screen width)
            right: MediaQuery.of(context).size.width * 0.05, // Responsive margin from right (5% of screen width)
            child: Container(
              width: MediaQuery.of(context).size.width * 0.25, // Responsive width (25% of screen width)
              height: MediaQuery.of(context).size.width * 0.35, // Responsive height (35% of screen width, portrait ratio)
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03), // Responsive border radius (3% of screen width)
                border: Border.all(
                  color: const Color(0xFF8F7902).withOpacity(0.3),
                  width: MediaQuery.of(context).size.width * 0.005, // Responsive border width (0.5% of screen width)
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: MediaQuery.of(context).size.width * 0.02, // Responsive blur (2% of screen width)
                    offset: Offset(0, MediaQuery.of(context).size.width * 0.005), // Responsive offset
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.025), // Slightly smaller to account for border
                child: CachedNetworkImage(
                  imageUrl: page.mapImage!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.map,
                        size: MediaQuery.of(context).size.width * 0.1, // Responsive icon size (10% of screen width)
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Action buttons for both club and district pages - Create new post (webmaster only) + Follow
  Widget _buildActionButtons(models.Page page) {
    ResponsiveUtils.init(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userLeoId = authProvider.user?.leoId;
    final isWebmaster = userLeoId != null && page.webmasterIds.contains(userLeoId);
    
    // Responsive values
    final horizontalPadding = ResponsiveUtils.dp(15);
    final buttonHeight = ResponsiveUtils.dp(39);
    final buttonPadding = ResponsiveUtils.dp(10);
    final buttonSpacing = ResponsiveUtils.dp(8);
    final borderRadius = ResponsiveUtils.dp(14);
    final iconSize = ResponsiveUtils.dp(16);
    final fontSize = ResponsiveUtils.sp(12);
    final borderWidth = ResponsiveUtils.dp(1.5);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          // First row: Create post and Create event buttons (only for webmasters)
          if (isWebmaster) ...[
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _AnimatedActionButton(
                    animationController: _createPostButtonController,
                    scaleAnimation: _createPostButtonScale,
                    onTap: () async {
                      _createPostButtonController.forward().then((_) {
                        _createPostButtonController.reverse();
                      });
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreatePagePostScreen(
                            pageId: page.id,
                            pageName: page.name,
                            pageLogo: page.logo,
                          ),
                        ),
                      );
                      if (result == true) {
                        _loadPageData(); // Reload posts after creating
                        // Also refresh home feed
                        final homeScreenState = HomeScreen.globalKey.currentState;
                        if (homeScreenState != null) {
                          homeScreenState.refreshFeed();
                        }
                      }
                    },
                    backgroundColor: Colors.white,
                    borderColor: Colors.black,
                    icon: Icons.add,
                    iconColor: Colors.black,
                    text: 'Create post',
                    textColor: Colors.black,
                    height: buttonHeight,
                    padding: buttonPadding,
                    borderRadius: borderRadius,
                    borderWidth: borderWidth,
                    iconSize: iconSize,
                    fontSize: fontSize,
                  ),
                ),
                SizedBox(width: buttonSpacing),
                Expanded(
                  flex: 1,
                  child: _AnimatedActionButton(
                    animationController: _createEventButtonController,
                    scaleAnimation: _createEventButtonScale,
                    onTap: () async {
                      _createEventButtonController.forward().then((_) {
                        _createEventButtonController.reverse();
                      });
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateEventScreen(
                            pageId: page.id,
                            pageName: page.name,
                            clubId: page.clubId,
                            districtId: page.districtId,
                            clubName: page.type == 'club' ? page.name : null,
                            districtName: page.type == 'district' ? page.name : null,
                          ),
                        ),
                      );
                      if (result == true) {
                        // Refresh events list
                        final eventsScreenState = EventsListScreen.globalKey.currentState;
                        if (eventsScreenState != null) {
                          eventsScreenState.refreshEvents();
                        }
                        // Also refresh page data
                        _loadPageData();
                      }
                    },
                    backgroundColor: const Color(0xFFFFD700),
                    borderColor: Colors.black,
                    icon: Icons.event,
                    iconColor: Colors.black,
                    text: 'Create event',
                    textColor: Colors.black,
                    height: buttonHeight,
                    padding: buttonPadding,
                    borderRadius: borderRadius,
                    borderWidth: borderWidth,
                    iconSize: iconSize,
                    fontSize: fontSize,
                    hasGradient: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: buttonSpacing),
          ],
          // Second row: Follow button (full width)
          Consumer<PageFollowProvider>(
            builder: (context, followProvider, child) {
              final isFollowing = followProvider.isFollowing(widget.page.id);
              final isToggling = followProvider.isToggling(widget.page.id);
              
              return _AnimatedActionButton(
                animationController: _followButtonController,
                scaleAnimation: _followButtonScale,
                onTap: isToggling ? null : () {
                  _followButtonController.forward().then((_) {
                    _followButtonController.reverse();
                  });
                  _toggleFollow();
                },
                backgroundColor: isFollowing ? Colors.white : Colors.black,
                borderColor: isFollowing ? Colors.black : null,
                icon: null,
                iconColor: null,
                text: isFollowing ? 'Following' : 'Follow',
                textColor: isFollowing ? Colors.black : const Color(0xFFF3F3F3),
                height: buttonHeight,
                padding: buttonPadding,
                borderRadius: borderRadius,
                borderWidth: isFollowing ? borderWidth * 1.33 : 0,
                iconSize: iconSize,
                fontSize: ResponsiveUtils.sp(13),
                isLoading: isToggling,
                width: double.infinity,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 0.667),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                  ),
                  child: ClipOval(
                    child: post.pageLogo != null
                        ? CachedNetworkImage(
                            imageUrl: post.pageLogo!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.primary,
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.primary,
                              child: Center(
                                child: Text(
                                  (post.pageName ?? post.authorName).substring(0, 2).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.primary,
                            child: Center(
                              child: Text(
                                (post.pageName ?? post.authorName).substring(0, 2).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Author name and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.pageName ?? post.authorName,
                        style: const TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF101828),
                        ),
                      ),
                      Text(
                        _getTimeAgo(post.createdAt),
                        style: const TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6A7282),
                        ),
                      ),
                    ],
                  ),
                ),
                // Options button (3 dots)
                GestureDetector(
                  onTap: () => _showPostOptions(post),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDot(),
                          const SizedBox(height: 3),
                          _buildDot(),
                          const SizedBox(height: 3),
                          _buildDot(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Post image with double-tap like
          if (post.images.isNotEmpty)
            GestureDetector(
              onDoubleTap: () => _handleDoubleTapLike(post),
              child: ClipRRect(
                child: CachedNetworkImage(
                  imageUrl: post.images.first,
                  width: double.infinity,
                  height: 425,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 425,
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 425,
                    color: Colors.grey[100],
                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            ),
          // Post content (if no image) with double-tap like
          if (post.images.isEmpty && post.content.isNotEmpty)
            GestureDetector(
              onDoubleTap: () => _handleDoubleTapLike(post),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  post.content,
                  style: const TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          // Post actions - Like, Comment
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Like with animation
                GestureDetector(
                  onTap: () {
                    _handleLike(post);
                    _initLikeAnimation(post.id);
                    final controller = _likeAnimationControllers[post.id];
                    if (controller != null) {
                      controller.forward().then((_) {
                        controller.reverse();
                      });
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: _likeAnimations.containsKey(post.id)
                      ? AnimatedBuilder(
                          animation: _likeAnimations[post.id]!,
                          builder: (context, child) {
                            final animationValue = _likeAnimations[post.id]!.value;
                            final scale = 1.0 + (animationValue * 0.25);
                            return Transform.scale(
                              scale: scale,
                              child: Icon(
                                _isPostLiked(post) 
                                    ? Icons.favorite 
                                    : Icons.favorite_border,
                                size: 24,
                                color: _isPostLiked(post) 
                                    ? const Color(0xFFFFD700)
                                    : Colors.black,
                              ),
                            );
                          },
                        )
                      : Icon(
                          _isPostLiked(post) 
                              ? Icons.favorite 
                              : Icons.favorite_border,
                          size: 24,
                          color: _isPostLiked(post) 
                              ? const Color(0xFFFFD700)
                              : Colors.black,
                        ),
                ),
                const SizedBox(width: 16),
                // Comment - SVG icon
                GestureDetector(
                  onTap: () => _showCommentDialog(post),
                  behavior: HitTestBehavior.opaque,
                  child: SvgPicture.asset(
                    'assets/images/icons/comment.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
          ),
          // Likes count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${_getPostLikesCount(post)} likes',
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          // Caption (show content when there are images)
          if (post.images.isNotEmpty && post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '${(post.pageName ?? post.authorName).replaceAll(' ', '_').toLowerCase()} ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: post.content,
                      style: const TextStyle(color: Color(0xFF374151)),
                    ),
                  ],
                ),
              ),
            ),
          // Comments link
          if (_getPostCommentsCount(post) > 0)
            GestureDetector(
              onTap: () => _showCommentDialog(post),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'View all ${_getPostCommentsCount(post)} comments',
                  style: const TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(
        color: Color(0xFF364153),
        shape: BoxShape.circle,
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Check if post is liked (frontend state takes priority)
  bool _isPostLiked(Post post) {
    if (post.id.isEmpty || _currentUser == null) return false;
    if (_likedPosts.containsKey(post.id)) {
      return _likedPosts[post.id] ?? false;
    }
    return post.isLikedBy(_currentUser!.id);
  }

  // Get likes count (frontend state takes priority)
  int _getPostLikesCount(Post post) {
    if (_postLikesCount.containsKey(post.id)) {
      return _postLikesCount[post.id] ?? post.likesCount;
    }
    return post.likesCount;
  }

  // Get comments count (frontend state takes priority)
  int _getPostCommentsCount(Post post) {
    if (_postCommentsCount.containsKey(post.id)) {
      return _postCommentsCount[post.id]!;
    }
    if (_postComments.containsKey(post.id)) {
      return _postComments[post.id]?.length ?? post.commentsCount;
    }
    return post.commentsCount;
  }

  // Initialize like animation for a post
  void _initLikeAnimation(String postId) {
    if (!_likeAnimationControllers.containsKey(postId)) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
      _likeAnimationControllers[postId] = controller;
      _likeAnimations[postId] = animation;
    }
  }

  // Handle double-tap like
  void _handleDoubleTapLike(Post post) {
    _handleLike(post);
    _initLikeAnimation(post.id);
    final controller = _likeAnimationControllers[post.id];
    if (controller != null) {
      controller.forward().then((_) {
        controller.reverse();
      });
    }
  }

  // Frontend-only like handler
  void _handleLike(Post post) async {
    if (post.id.isEmpty) return;
    
    // Optimistically update UI
    final wasLiked = _isPostLiked(post);
    setState(() {
      _likedPosts[post.id] = !wasLiked;
      final currentLikesCount = _postLikesCount[post.id] ?? post.likesCount;
      _postLikesCount[post.id] = wasLiked 
          ? (currentLikesCount > 0 ? currentLikesCount - 1 : 0)
          : currentLikesCount + 1;
    });
    
    // Call backend API to persist like
    try {
      final result = await _postRepository.toggleLike(post.id);
      if (result != null && result['likesCount'] != null) {
        setState(() {
          _postLikesCount[post.id] = result['likesCount'] as int;
        });
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _likedPosts[post.id] = wasLiked;
        _postLikesCount[post.id] = post.likesCount;
      });
    }
  }

  // Show comment dialog
  void _showCommentDialog(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentDialogWidget(
        post: post,
        currentUser: _currentUser,
        onCommentAdded: (comment) {
          setState(() {
            if (!_postComments.containsKey(post.id)) {
              _postComments[post.id] = [];
            }
            if (!_postCommentsCount.containsKey(post.id)) {
              _postCommentsCount[post.id] = post.commentsCount;
            }
            
            if (comment['_remove'] == true) {
              final currentCount = _postCommentsCount[post.id] ?? 0;
              _postCommentsCount[post.id] = (currentCount > 0 ? currentCount - 1 : 0);
              return;
            }
            
            final commentId = comment['id'] ?? '${comment['authorId']}_${(comment['timestamp'] as DateTime).millisecondsSinceEpoch}';
            final existingIndex = _postComments[post.id]!.indexWhere((c) {
              final cId = c['id'] ?? '${c['authorId']}_${(c['timestamp'] as DateTime).millisecondsSinceEpoch}';
              return cId == commentId;
            });
            
            if (existingIndex == -1) {
              _postComments[post.id]!.insert(0, comment);
              _postCommentsCount[post.id] = (_postCommentsCount[post.id] ?? 0) + 1;
            } else {
              _postComments[post.id]![existingIndex] = comment;
            }
            
            _postComments[post.id]!.sort((a, b) {
              final timeA = (a['timestamp'] as DateTime).millisecondsSinceEpoch;
              final timeB = (b['timestamp'] as DateTime).millisecondsSinceEpoch;
              return timeB.compareTo(timeA);
            });
          });
        },
      ),
    );
  }

  // Show post options (edit/delete)
  void _showPostOptions(Post post) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;
    final isSuperAdmin = authProvider.isSuperAdmin;
    final isAuthor = post.authorId == currentUser?.id;
    
    bool isWebmasterOfPage = false;
    final pageId = post.pageId;
    final userLeoId = currentUser?.leoId;
    if (pageId != null && pageId.isNotEmpty && userLeoId != null && userLeoId.isNotEmpty) {
      try {
        final page = await _pageRepository.getPageById(pageId);
        if (page.webmasterIds.contains(userLeoId)) {
          isWebmasterOfPage = true;
        }
      } catch (e) {
        print('Error checking webmaster status: $e');
      }
    }

    final canEdit = isAuthor || isSuperAdmin || isWebmasterOfPage;
    final canDelete = isAuthor || isSuperAdmin || isWebmasterOfPage;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canEdit)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _editPost(post);
                },
              ),
            if (canDelete)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deletePost(post);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _editPost(Post post) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostScreen(post: post),
      ),
    );

    if (result == true && mounted) {
      // Refresh the page data to show updated post
      await _loadPageData();
    }
  }

  Future<void> _deletePost(Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
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

    if (confirmed == true) {
      try {
        await _postRepository.deletePost(post.id);
        await _loadPageData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete post: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showDeleteDialog() async {
    final page = _pageData ?? widget.page;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Page'),
        content: Text('Are you sure you want to delete "${page.name}"? This action cannot be undone and will delete all posts and events associated with this page.'),
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

    if (confirmed == true) {
      try {
        await _pageRepository.deletePage(page.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Page deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Go back to pages list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete page: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

/// Yellow Bubble 02 Painter - Exact Figma SVG path pe2b6900 (from search screen)
class _Bubble02Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final path = Path();
    final scaleX = size.width / 325;
    final scaleY = size.height / 368;

    path.moveTo(142.573 * scaleX, 33.5385 * scaleY);
    path.cubicTo(
      221.639 * scaleX, -74.0067 * scaleY,
      324.97 * scaleX, 103.016 * scaleY,
      309.453 * scaleX, 200.418 * scaleY,
    );
    path.cubicTo(
      293.936 * scaleX, 297.821 * scaleY,
      234.738 * scaleX, 367.298 * scaleY,
      142.573 * scaleX, 367.298 * scaleY,
    );
    path.cubicTo(
      50.4079 * scaleX, 367.298 * scaleY,
      7.1557 * scaleX, 288.01 * scaleY,
      0.447188 * scaleX, 203.99 * scaleY,
    );
    path.cubicTo(
      -6.26132 * scaleX, 119.97 * scaleY,
      63.5071 * scaleX, 141.084 * scaleY,
      142.573 * scaleX, 33.5385 * scaleY,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Pulsing dots widget with repeating animation
class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

// Animated Action Button Widget with modern design
class _AnimatedActionButton extends StatefulWidget {
  final AnimationController animationController;
  final Animation<double> scaleAnimation;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color? borderColor;
  final IconData? icon;
  final Color? iconColor;
  final String text;
  final Color textColor;
  final double height;
  final double padding;
  final double borderRadius;
  final double borderWidth;
  final double iconSize;
  final double fontSize;
  final bool hasGradient;
  final bool isLoading;
  final double? width;

  const _AnimatedActionButton({
    required this.animationController,
    required this.scaleAnimation,
    this.onTap,
    required this.backgroundColor,
    this.borderColor,
    this.icon,
    this.iconColor,
    required this.text,
    required this.textColor,
    required this.height,
    required this.padding,
    required this.borderRadius,
    required this.borderWidth,
    required this.iconSize,
    required this.fontSize,
    this.hasGradient = false,
    this.isLoading = false,
    this.width,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    widget.animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.animationController.reverse();
    _rippleController.forward().then((_) => _rippleController.reset());
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    widget.animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.scaleAnimation, _rippleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onTap != null ? _handleTapDown : null,
            onTapUp: widget.onTap != null ? _handleTapUp : null,
            onTapCancel: widget.onTap != null ? _handleTapCancel : null,
            onTap: widget.onTap,
            child: Container(
              width: widget.width,
              height: widget.height,
              padding: EdgeInsets.symmetric(horizontal: widget.padding),
              decoration: BoxDecoration(
                gradient: widget.hasGradient
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.backgroundColor,
                          widget.backgroundColor.withOpacity(0.85),
                        ],
                      )
                    : null,
                color: widget.hasGradient ? null : widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: widget.borderColor != null
                    ? Border.all(color: widget.borderColor!, width: widget.borderWidth)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isPressed ? 0.15 : 0.1),
                    blurRadius: _isPressed ? 12 : 8,
                    offset: Offset(0, _isPressed ? 6 : 4),
                    spreadRadius: _isPressed ? 1 : 0,
                  ),
                  BoxShadow(
                    color: widget.backgroundColor.withOpacity(_isPressed ? 0.3 : 0.2),
                    blurRadius: _isPressed ? 8 : 4,
                    offset: Offset(0, _isPressed ? 4 : 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Ripple effect
                  if (_rippleAnimation.value > 0)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: _rippleAnimation.value * 1.5,
                              colors: [
                                Colors.white.withOpacity(0.3 * (1 - _rippleAnimation.value)),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Content
                  Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.textColor == Colors.black ? Colors.black : Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  transform: Matrix4.identity()
                                    ..scale(_isPressed ? 0.9 : 1.0),
                                  child: Icon(
                                    widget.icon,
                                    size: widget.iconSize,
                                    color: widget.iconColor,
                                  ),
                                ),
                                SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Text(
                                  widget.text,
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: widget.fontSize,
                                    fontWeight: FontWeight.w700,
                                    color: widget.textColor,
                                    letterSpacing: 0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
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

/// Black Bubble 01 Painter - Exact Figma SVG path p2b951e00 (from search screen)
class _Bubble01Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF02091A)
      ..style = PaintingStyle.fill;

    final path = Path();
    final scaleX = size.width / 244;
    final scaleY = size.height / 267;

    path.moveTo(122.23 * scaleX, 23.973 * scaleY);
    path.cubicTo(
      179.747 * scaleX, -54.2618 * scaleY,
      243.628 * scaleX, 78.3248 * scaleY,
      243.628 * scaleX, 145.371 * scaleY,
    );
    path.cubicTo(
      243.628 * scaleX, 212.418 * scaleY,
      189.276 * scaleX, 266.77 * scaleY,
      122.23 * scaleX, 266.77 * scaleY,
    );
    path.cubicTo(
      55.1834 * scaleX, 266.77 * scaleY,
      -8.01705 * scaleX, 215.723 * scaleY,
      0.831575 * scaleX, 145.371 * scaleY,
    );
    path.cubicTo(
      9.6802 * scaleX, 75.0195 * scaleY,
      64.7126 * scaleX, 102.208 * scaleY,
      122.23 * scaleX, 23.973 * scaleY,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

