import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/post.dart';
import '../../../data/models/user.dart';
import '../../../data/models/page.dart' as page_model;
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/page_follow_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../main/main_screen.dart';
import '../pages/page_detail_screen.dart';
import '../pages/create_page_post_screen.dart';
import 'edit_post_screen.dart';
import 'side_menu.dart';

/// Home Screen - Matches Home_Page/src/imports/Home.tsx exactly
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final GlobalKey<_HomeScreenState> globalKey = GlobalKey<_HomeScreenState>();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _postRepository = PostRepository();
  final _authRepository = AuthRepository();
  final _pageRepository = PageRepository();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  
  List<Post> _posts = [];
  User? _currentUser;
  List<page_model.Page> _myPages = []; // Pages where user is webmaster
  List<page_model.Page> _availableClubs = []; // Available clubs to follow
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isMenuOpen = false;
  
  // Track when clubs were followed (for 1-minute timer)
  final Map<String, DateTime> _clubFollowTimestamps = {};
  final Map<String, Timer> _followTimers = {}; // Store timer per club
  
  // Animation controllers for follow buttons
  final Map<String, AnimationController> _followButtonControllers = {};
  final Map<String, Animation<double>> _followButtonAnimations = {};
  
  // Local state for likes and comments (frontend only)
  final Map<String, bool> _likedPosts = {}; // postId -> isLiked
  final Map<String, int> _postLikesCount = {}; // postId -> likesCount
  final Map<String, List<Map<String, dynamic>>> _postComments = {}; // postId -> comments list
  final Map<String, int> _postCommentsCount = {}; // postId -> commentsCount (for real-time updates)
  
  // Double-tap like animation controllers
  final Map<String, AnimationController> _likeAnimationControllers = {};
  final Map<String, Animation<double>> _likeAnimations = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    // Dispose all animation controllers
    for (var controller in _likeAnimationControllers.values) {
      controller.dispose();
    }
    _likeAnimationControllers.clear();
    _likeAnimations.clear();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // First check AuthProvider for user (works for Super Admin)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      User? user = authProvider.user;
      
      // If not in AuthProvider, try API
      if (user == null) {
        try {
          user = await _authRepository.getCurrentUser();
        } catch (e) {
          // Ignore API error if we already have user from AuthProvider
        }
      }
      
      // Load posts (may fail for Super Admin but that's okay)
      List<Post> posts = [];
      try {
        posts = await _postRepository.getFeed().timeout(
          const Duration(seconds: 10),
          onTimeout: () => <Post>[],
        );
      } catch (e) {
        // Use empty posts if API fails
        posts = [];
      }
      
      // Load user's pages if they are a webmaster
      List<page_model.Page> myPages = [];
      if (user != null && (user.role == 'webmaster' || user.role == 'superadmin') && user.leoId != null) {
        try {
          myPages = await _pageRepository.getMyPages().timeout(
            const Duration(seconds: 10),
            onTimeout: () => <page_model.Page>[],
          );
        } catch (e) {
          // Use empty list if API fails
          myPages = [];
        }
      }
      
      // Load available clubs to follow
      List<page_model.Page> availableClubs = [];
      if (user != null && user.leoId != null && user.leoId!.isNotEmpty) {
        try {
          final allPages = await _pageRepository.getAllPages().timeout(
            const Duration(seconds: 10),
            onTimeout: () => <page_model.Page>[],
          );
          
          // Get user's followed pages
          final followProvider = Provider.of<PageFollowProvider>(context, listen: false);
          await followProvider.loadFollowStatuses(allPages.map((p) => p.id).toList());
          
          // Filter: only club and district pages that user is not following and not a webmaster of
          final myPageIds = myPages.map((p) => p.id).toSet();
          availableClubs = allPages.where((page) {
            if (page.type != 'club' && page.type != 'district') return false;
            if (myPageIds.contains(page.id)) return false; // User is webmaster
            return !followProvider.isFollowing(page.id); // User is not following
          }).toList();
          
          // Sort by createdAt descending (newest first)
          availableClubs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } catch (e) {
          // Use empty list if API fails
          availableClubs = [];
        }
      }
      
      if (mounted) {
        // Sort posts: followed pages first, then others (both sorted by createdAt desc)
        final followProvider = Provider.of<PageFollowProvider>(context, listen: false);
        final followedPageIds = followProvider.getFollowedPageIds();
        
        // Separate posts into followed and non-followed
        final followedPosts = <Post>[];
        final nonFollowedPosts = <Post>[];
        
        for (var post in posts) {
          if (post.pageId != null && followedPageIds.contains(post.pageId)) {
            followedPosts.add(post);
          } else {
            nonFollowedPosts.add(post);
          }
        }
        
        // Sort both lists by createdAt descending (newest first)
        followedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        nonFollowedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        // Combine: followed posts first, then non-followed posts
        final sortedPosts = [...followedPosts, ...nonFollowedPosts];
        
        setState(() {
          _currentUser = user;
          _posts = sortedPosts;
          _myPages = myPages;
          _availableClubs = availableClubs;
          _isLoading = false;
          
          // Initialize local like state and comment state from backend data
          if (user != null) {
            for (var post in posts) {
              if (post.id.isNotEmpty && user.id.isNotEmpty) {
                if (post.isLikedBy(user.id)) {
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
                } else if (!_postComments.containsKey(post.id)) {
                  // Initialize empty list if not already set
                  _postComments[post.id] = [];
                  _postCommentsCount[post.id] = 0;
                } else {
                  // Update count from existing comments
                  _postCommentsCount[post.id] = _postComments[post.id]!.length;
                }
              }
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // Always set loading to false
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;
        
        setState(() {
          _isLoading = false;
          // Use AuthProvider user if available (for Super Admin)
          if (user != null) {
            _currentUser = user;
            _posts = _posts; // Keep existing posts or empty
          }
        });
        
        // Only show error if we don't have a user at all
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  // Public method to refresh feed (called from MainScreen)
  void refreshFeed() {
    _refreshFeed();
  }

  Future<void> _refreshFeed() async {
    setState(() => _isRefreshing = true);
    
    try {
      // First check AuthProvider for user (works for Super Admin)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      User? user = authProvider.user;
      
      // If not in AuthProvider, try API
      if (user == null) {
        try {
          user = await _authRepository.getCurrentUser();
        } catch (e) {
          // Ignore API error
        }
      }
      
      // Load posts
      List<Post> posts = [];
      try {
        posts = await _postRepository.getFeed();
      } catch (e) {
        // Keep existing posts if API fails
        posts = _posts;
      }
      
      // Reload available clubs - Show to ALL users
      List<page_model.Page> availableClubs = [];
      final currentUser = user ?? _currentUser;
      // Remove leoId requirement - show to all users
      try {
        final allPages = await _pageRepository.getAllPages().timeout(
          const Duration(seconds: 10),
          onTimeout: () => <page_model.Page>[],
        );
        
        // Get user's followed pages (if user is logged in)
        final followProvider = Provider.of<PageFollowProvider>(context, listen: false);
        if (currentUser != null) {
          await followProvider.loadFollowStatuses(allPages.map((p) => p.id).toList());
        }
        
        // Get user's pages (webmaster) - only if user exists
        final myPageIds = currentUser != null ? _myPages.map((p) => p.id).toSet() : <String>{};
        
        // Filter: only club and district pages that user is not following and not a webmaster of
        // If user is not logged in, show all club and district pages
        availableClubs = allPages.where((page) {
          if (page.type != 'club' && page.type != 'district') return false;
          if (currentUser != null && myPageIds.contains(page.id)) return false; // User is webmaster
          if (currentUser != null) {
            return !followProvider.isFollowing(page.id); // User is not following
          }
          // If user is not logged in, show all club and district pages
          return true;
        }).toList();
        
        // Sort by createdAt descending (newest first)
        availableClubs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } catch (e) {
        // Keep existing clubs if API fails
        availableClubs = _availableClubs;
      }
      
      if (mounted) {
        // Sort posts: followed pages first, then others (both sorted by createdAt desc)
        final followProvider = Provider.of<PageFollowProvider>(context, listen: false);
        final followedPageIds = followProvider.getFollowedPageIds();
        
        // Separate posts into followed and non-followed
        final followedPosts = <Post>[];
        final nonFollowedPosts = <Post>[];
        
        for (var post in posts) {
          if (post.pageId != null && followedPageIds.contains(post.pageId)) {
            followedPosts.add(post);
          } else {
            nonFollowedPosts.add(post);
          }
        }
        
        // Sort both lists by createdAt descending (newest first)
        followedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        nonFollowedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        // Combine: followed posts first, then non-followed posts
        final sortedPosts = [...followedPosts, ...nonFollowedPosts];
        
        setState(() {
          _currentUser = currentUser;
          _posts = sortedPosts;
          _availableClubs = availableClubs;
          _isRefreshing = false;
          
          // Update local like state and comment state from backend data
          for (var post in posts) {
            if (post.id.isNotEmpty && _currentUser != null && _currentUser!.id.isNotEmpty) {
              if (post.isLikedBy(_currentUser!.id)) {
                _likedPosts[post.id] = true;
              } else if (!_likedPosts.containsKey(post.id)) {
                // Only set to false if we haven't locally toggled it
                _likedPosts[post.id] = false;
              }
              if (!_postLikesCount.containsKey(post.id)) {
                _postLikesCount[post.id] = post.likesCount;
              }
              
              // Update comment state from backend (merge with existing local comments)
              if (post.comments.isNotEmpty) {
                final backendComments = post.comments.map((comment) {
                  final stableId = '${comment.userId}_${comment.createdAt.millisecondsSinceEpoch}';
                  return {
                    'id': stableId,
                    'text': comment.text,
                    'authorName': comment.userName,
                    'authorId': comment.userId,
                    'timestamp': comment.createdAt,
                  };
                }).toList();
                
                // Merge with existing local comments (keep local ones that aren't in backend)
                if (_postComments.containsKey(post.id) && _postComments[post.id]!.isNotEmpty) {
                  final existingIds = backendComments.map((c) => c['id'] as String).toSet();
                  final now = DateTime.now();
                  // Keep local comments that aren't in backend (newly added comments, including temp ones or recently added)
                  final localOnlyComments = _postComments[post.id]!.where((c) {
                    final localId = c['id'] ?? '${c['authorId']}_${(c['timestamp'] as DateTime).millisecondsSinceEpoch}';
                    final isTempComment = localId.toString().startsWith('temp_');
                    // Check if comment was recently added locally (within last 30 seconds)
                    final addedAt = c['_addedAt'] as DateTime?;
                    final isRecentlyAdded = addedAt != null && now.difference(addedAt).inSeconds < 30;
                    // Keep if not in backend OR if it's a temp comment OR if it was recently added
                    return !existingIds.contains(localId) || isTempComment || isRecentlyAdded;
                  }).toList();
                  // Merge: backend comments first, then local-only comments
                  final mergedComments = [...backendComments, ...localOnlyComments];
                  // Sort by timestamp descending (newest first)
                  mergedComments.sort((a, b) {
                    final timeA = (a['timestamp'] as DateTime).millisecondsSinceEpoch;
                    final timeB = (b['timestamp'] as DateTime).millisecondsSinceEpoch;
                    return timeB.compareTo(timeA); // Descending order (newest first)
                  });
                  _postComments[post.id] = mergedComments;
                  // Update comment count from merged comments
                  _postCommentsCount[post.id] = mergedComments.length;
                } else {
                  _postComments[post.id] = backendComments;
                  // Update comment count from backend
                  _postCommentsCount[post.id] = backendComments.length;
                }
              } else {
                // Even if backend has no comments, preserve local comments if they exist
                if (!_postComments.containsKey(post.id)) {
                  _postComments[post.id] = [];
                  _postCommentsCount[post.id] = 0;
                } else {
                  // Update count from local comments
                  _postCommentsCount[post.id] = _postComments[post.id]!.length;
                }
                // Don't overwrite existing local comments if backend has none
              }
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  // Frontend-only like handler
  void _handleLike(Post post) async {
    if (post.id.isEmpty) return; // Safety check
    
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
      // Update like count from backend response if available
      if (result != null && result['likesCount'] != null) {
        setState(() {
          _postLikesCount[post.id] = result['likesCount'] as int;
        });
      }
      // No need to refresh entire feed - UI already updated optimistically
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _likedPosts[post.id] = wasLiked;
          final currentLikesCount = _postLikesCount[post.id] ?? post.likesCount;
          _postLikesCount[post.id] = wasLiked 
              ? currentLikesCount + 1
              : (currentLikesCount > 0 ? currentLikesCount - 1 : 0);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to like post: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Initialize animation controller for a post
  void _initLikeAnimation(String postId) {
    if (!_likeAnimationControllers.containsKey(postId)) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic, // Smoother animation
        ),
      );
      _likeAnimationControllers[postId] = controller;
      _likeAnimations[postId] = animation;
    }
  }
  
  // Handle double-tap like
  void _handleDoubleTapLike(Post post) {
    // Initialize animation if needed
    _initLikeAnimation(post.id);
    
    // Trigger like only if not already liked
    if (!_isPostLiked(post)) {
      _handleLike(post);
    }
    
    // Always trigger animation on double-tap
    final controller = _likeAnimationControllers[post.id];
    if (controller != null) {
      controller.forward().then((_) {
        controller.reverse();
      });
    }
  }

  // Check if post is liked (frontend state takes priority)
  bool _isPostLiked(Post post) {
    if (post.id.isEmpty) return false;
    
    // Check local state first
    if (_likedPosts.containsKey(post.id)) {
      return _likedPosts[post.id] ?? false;
    }
    
    // Fall back to backend state
    final userId = _currentUser?.id ?? '';
    if (userId.isEmpty) return false;
    return post.isLikedBy(userId);
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
    // Check local comment count first (for real-time updates)
    if (_postCommentsCount.containsKey(post.id)) {
      return _postCommentsCount[post.id]!;
    }
    // Fall back to local comments list length
    if (_postComments.containsKey(post.id)) {
      return _postComments[post.id]?.length ?? post.commentsCount;
    }
    // Fall back to backend count
    return post.commentsCount;
  }

  // Show comment dialog
  void _showCommentDialog(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentDialogWidget(
        post: post,
        currentUser: _currentUser,
        initialComments: _postComments[post.id] ?? [],
        onCommentAdded: (comment) {
          setState(() {
            if (!_postComments.containsKey(post.id)) {
              _postComments[post.id] = [];
            }
            // Check if this is a removal flag
            if (comment['_remove'] == true && _postComments[post.id]!.isNotEmpty) {
              _postComments[post.id]!.removeLast();
            } else if (comment['_remove'] != true) {
              // Get comment ID (use id if available, otherwise generate from authorId and timestamp)
              final commentId = comment['id'] ?? '${comment['authorId']}_${(comment['timestamp'] as DateTime).millisecondsSinceEpoch}';
              final tempId = comment['_tempId'];
              
              // First, try to find by tempId (if this is updating a temp comment)
              int existingIndex = -1;
              if (tempId != null) {
                existingIndex = _postComments[post.id]!.indexWhere((c) {
                  return c['id'] == tempId || c['_tempId'] == tempId;
                });
              }
              
              // If not found by tempId, try to find by comment ID
              if (existingIndex == -1) {
                existingIndex = _postComments[post.id]!.indexWhere((c) {
                  final cId = c['id'] ?? '${c['authorId']}_${(c['timestamp'] as DateTime).millisecondsSinceEpoch}';
                  return cId == commentId;
                });
              }
              
              if (existingIndex != -1) {
                // Update existing comment (replace optimistic with saved version)
                _postComments[post.id]![existingIndex] = comment;
              } else {
                // Add new comment
                _postComments[post.id]!.add(comment);
              }
            }
          });
        },
        formatTime: _formatTime,
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
    }

    final mainContent = Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header - Logo, Notification, Menu
            _buildHeader(),
            
            // Feed content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshFeed,
                color: AppColors.primary,
                child: _isRefreshing
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              // Show first 2 posts
                              ..._posts.take(2).map((post) => _buildPostCard(post)),
                              // Suggested to Follow section (after first 2 posts)
                              if (_availableClubs.isNotEmpty) ...[
                                const SizedBox(height: 0),
                                _buildSuggestedToFollow(),
                                const SizedBox(height: 20),
                              ],
                              // Show remaining posts
                              ..._posts.skip(2).map((post) => _buildPostCard(post)),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      // Floating action buttons for webmasters
      floatingActionButton: _isWebmaster && _myPages.isNotEmpty
          ? _buildWebmasterFloatingButtons()
          : null,
    );

    return SideMenu(
      user: _currentUser,
      isOpen: _isMenuOpen,
      onClose: () => setState(() => _isMenuOpen = false),
      onMenuStateChanged: (isOpen) {
        // Notify MainScreen to hide/show bottom nav using GlobalKey
        final mainScreenState = MainScreen.globalKey.currentState;
        if (mainScreenState != null) {
          mainScreenState.setMenuOpen(isOpen);
        } else {
          // Fallback: try finding by context
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final mainScreenState2 = MainScreen.globalKey.currentState;
            if (mainScreenState2 != null) {
              mainScreenState2.setMenuOpen(isOpen);
            }
          });
        }
      },
      child: mainContent,
    );
  }

  // Check if user is webmaster
  bool get _isWebmaster {
    return _currentUser != null && 
           (_currentUser!.role == 'webmaster' || _currentUser!.role == 'superadmin') &&
           _currentUser!.leoId != null;
  }

  // Build floating action buttons for webmasters
  Widget _buildWebmasterFloatingButtons() {
    if (_myPages.isEmpty) return const SizedBox.shrink();
    
    // Use first page if multiple pages exist
    final page = _myPages.first;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Button to create post for page
        FloatingActionButton(
          heroTag: "create_page_post",
          onPressed: () => _navigateToCreatePagePost(page),
          backgroundColor: const Color(0xFFFFD700),
          child: const Icon(
            Icons.add,
            color: Colors.black,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        // Button to go to page
        FloatingActionButton(
          heroTag: "go_to_page",
          onPressed: () => _navigateToPage(page),
          backgroundColor: const Color(0xFFFFD700),
          child: SvgPicture.asset(
            'assets/images/icons/go_to_page.svg',
            width: 28,
            height: 28,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }

  // Navigate to create page post screen
  void _navigateToCreatePagePost(page_model.Page page) async {
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
    
    // Refresh feed if post was created
    if (result == true) {
      _refreshFeed();
    }
  }

  // Navigate to page detail screen
  void _navigateToPage(page_model.Page page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageDetailScreen(page: page),
      ),
    );
  }

  /// Header matching Home.tsx - Group component
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Logo - Leos-Of-SriLanka-Maldives-Black-Version-1 1
          Image.asset(
            'assets/images/leos_logo_with_icon.png',
            height: 55,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          // Notification icon - LinearNotificationsNotificationUnreadLines
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/notifications'),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CustomPaint(
                painter: _NotificationIconPainter(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Hamburger menu icon - BrokenEssentionalUiHamburgerMenu
          GestureDetector(
            onTap: () => setState(() => _isMenuOpen = true),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CustomPaint(
                painter: _HamburgerMenuPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Removed hardcoded demo post - now using only real posts from API

  /// Suggested to Follow section - using real available clubs
  Widget _buildSuggestedToFollow() {
    if (_availableClubs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 12),
          child: const Text(
            'Suggested to Follow',
            style: TextStyle(
              fontFamily: 'Arimo',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF101828),
            ),
          ),
        ),
        // Horizontal scrollable list of club cards
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableClubs.length,
            itemBuilder: (context, index) {
              final club = _availableClubs[index];
              final followProvider = Provider.of<PageFollowProvider>(context);
              final isFollowing = followProvider.isFollowing(club.id);
              
              // Format followers count
              String membersText;
              if (club.followersCount >= 1000) {
                membersText = '${(club.followersCount / 1000).toStringAsFixed(1)}k members';
              } else {
                membersText = '${club.followersCount} members';
              }
              
              // Get initials for fallback
              final initials = club.name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
              
              return Container(
                width: 140,
                margin: EdgeInsets.only(right: index < _availableClubs.length - 1 ? 12 : 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Club logo
                    GestureDetector(
                      onTap: () => _navigateToPage(club),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: club.logo != null && club.logo!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: club.logo!,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Text(
                                        initials,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Text(
                                        initials,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Text(
                                      initials,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Club name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        onTap: () => _navigateToPage(club),
                        child: Text(
                          club.name,
                          style: const TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF101828),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Members count
                    Text(
                      membersText,
                      style: const TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Follow/Unfollow button with animation
                    _buildAnimatedFollowButton(club.id, isFollowing, () async {
                      final followProvider = Provider.of<PageFollowProvider>(context, listen: false);
                      final wasFollowing = followProvider.isFollowing(club.id);
                      await followProvider.toggleFollow(club.id);
                      final nowFollowing = followProvider.isFollowing(club.id);
                      
                      if (nowFollowing && !wasFollowing) {
                        // Just followed - start timer and update UI
                        setState(() {
                          _clubFollowTimestamps[club.id] = DateTime.now();
                        });
                        // Start timer to remove after 1 minute
                        _startFollowTimer(club.id);
                      } else if (!nowFollowing && wasFollowing) {
                        // Unfollowed - cancel timer and remove from timestamps
                        _cancelFollowTimer(club.id);
                        setState(() {
                          _clubFollowTimestamps.remove(club.id);
                        });
                      }
                      
                      // Re-sort posts to prioritize followed pages
                      _sortPostsByFollowedPages();
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Initialize follow button animation for a club
  void _initFollowButtonAnimation(String clubId) {
    if (!_followButtonControllers.containsKey(clubId)) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      final animation = Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
      _followButtonControllers[clubId] = controller;
      _followButtonAnimations[clubId] = animation;
    }
  }

  // Build animated follow button
  Widget _buildAnimatedFollowButton(String clubId, bool isFollowing, VoidCallback onTap) {
    // Initialize animation if needed
    _initFollowButtonAnimation(clubId);
    
    final controller = _followButtonControllers[clubId]!;
    final animation = _followButtonAnimations[clubId]!;
    
    return GestureDetector(
      onTap: () {
        // Trigger zoom animation
        controller.forward().then((_) {
          controller.reverse();
        });
        // Execute the callback
        onTap();
      },
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.scale(
            scale: animation.value,
              child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: isFollowing ? const Color(0xFFB8860B) : const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isFollowing ? 'Unfollow' : 'Follow',
                style: TextStyle(
                  fontFamily: 'Arimo',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isFollowing ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Cancel follow timer for a specific club
  void _cancelFollowTimer(String clubId) {
    final timer = _followTimers[clubId];
    if (timer != null) {
      timer.cancel();
      _followTimers.remove(clubId);
    }
  }

  // Start timer to remove club after 1 minute (only if still following)
  void _startFollowTimer(String clubId) {
    // Cancel existing timer for this club if any
    _cancelFollowTimer(clubId);
    
    // Set new timer
    final timer = Timer(const Duration(minutes: 1), () {
      if (mounted) {
        // Check if still following before removing
        final followProvider = Provider.of<PageFollowProvider>(context, listen: false);
        final isStillFollowing = followProvider.isFollowing(clubId);
        
        if (isStillFollowing) {
          // Only remove if still following after 1 minute
          setState(() {
            _availableClubs.removeWhere((c) => c.id == clubId);
            _clubFollowTimestamps.remove(clubId);
            // Clean up animation controllers
            _followButtonControllers[clubId]?.dispose();
            _followButtonControllers.remove(clubId);
            _followButtonAnimations.remove(clubId);
          });
        }
        // Remove timer from map
        _followTimers.remove(clubId);
      }
    });
    
    _followTimers[clubId] = timer;
  }
  
  /// Sort posts to prioritize followed pages
  void _sortPostsByFollowedPages() {
    final followProvider = Provider.of<PageFollowProvider>(context, listen: false);
    final followedPageIds = followProvider.getFollowedPageIds();
    
    // Separate posts into followed and non-followed
    final followedPosts = <Post>[];
    final nonFollowedPosts = <Post>[];
    
    for (var post in _posts) {
      if (post.pageId != null && followedPageIds.contains(post.pageId)) {
        followedPosts.add(post);
      } else {
        nonFollowedPosts.add(post);
      }
    }
    
    // Sort both lists by createdAt descending (newest first)
    followedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    nonFollowedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Combine: followed posts first, then non-followed posts
    final sortedPosts = [...followedPosts, ...nonFollowedPosts];
    
    if (mounted) {
      setState(() {
        _posts = sortedPosts;
      });
    }
  }

  // Map author names to Leo Club names and logos
  static const Map<String, Map<String, String>> _leoClubMapping = {
    'Admin User': {'name': 'Leo Club of Moratuwa', 'logo': 'assets/images/Home/Leo Club Moratuwa.jpg'},
    'Mike Johnson': {'name': 'Leo Club of Mt.Lavinia', 'logo': 'assets/images/Home/Leo Club Mt.Lavinia.jpg'},
    'Jane Smith': {'name': 'Leo Club of Katuwawala', 'logo': 'assets/images/Home/Leo Club of Katuwalawa.jpg'},
    'John Doe': {'name': 'Leo Club of Matara', 'logo': 'assets/images/Home/Leo Club of Matara.jpg'},
  };

  String _getLeoClubName(String authorName) {
    return _leoClubMapping[authorName]?['name'] ?? authorName;
  }

  String? _getLeoClubLogo(String authorName) {
    return _leoClubMapping[authorName]?['logo'];
  }

  /// Post card matching Home.tsx Post component
  Widget _buildPostCard(Post post) {
    final clubName = _getLeoClubName(post.authorName);
    final clubLogo = _getLeoClubLogo(post.authorName);
    
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
          // Post header - Container3 from Home.tsx
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar - Leo Club Logo
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                  ),
                  child: ClipOval(
                    child: clubLogo != null
                        ? Image.asset(
                            clubLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.primary,
                              child: const Center(
                                child: Text(
                                  'LC',
                                  style: TextStyle(
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
                                clubName[0].toUpperCase(),
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
                // Text info - Container1 from Home.tsx
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Club name - Text component
                      Text(
                        clubName,
                        style: const TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF101828),
                        ),
                      ),
                      // Time ago - Text1 component
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
                // Options button - Button/Icon component (3 dots)
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
          // Post image - ImageWithFallback1 from Home.tsx with double-tap like
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
          // Post content (if no image, show content) with double-tap like
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
                    // Trigger animation on tap
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
                            // Smoother scale animation with easing
                            final animationValue = _likeAnimations[post.id]!.value;
                            final scale = 1.0 + (animationValue * 0.25); // Slightly less scale for smoother effect
                            return Transform.scale(
                              scale: scale,
                              child: Icon(
                                _isPostLiked(post) 
                                    ? Icons.favorite 
                                    : Icons.favorite_border,
                                size: 24,
                                color: _isPostLiked(post) 
                                    ? const Color(0xFFFFD700) // Gold color
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
                              ? const Color(0xFFFFD700) // Gold color
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
                      text: '${clubName.replaceAll(' ', '_').toLowerCase()} ',
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
          // Also show content if no images (standalone text post)
          if (post.images.isEmpty && post.content.isNotEmpty)
            Padding(
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

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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

  void _showPostOptions(Post post) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;
    final isSuperAdmin = authProvider.isSuperAdmin;
    final isAuthor = post.authorId == currentUser?.id;
    
    // Check if user is webmaster of the page that owns this post
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
        // If page fetch fails, continue without webmaster check
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
      // Refresh the feed to show updated post
      await _refreshFeed();
    }
  }

  Future<void> _deletePost(Post post) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _postRepository.deletePost(post.id);
      if (mounted) {
        setState(() {
          _posts.removeWhere((p) => p.id == post.id);
          // Also remove from comments cache
          _postComments.remove(post.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete post: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Notification icon painter - matches LinearNotificationsNotificationUnreadLines
class _NotificationIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Main rectangle path
    final rectPath = Path();
    rectPath.moveTo(size.width * 0.917, size.height * 0.438);
    rectPath.lineTo(size.width * 0.917, size.height * 0.5);
    rectPath.cubicTo(
      size.width * 0.917, size.height * 0.696,
      size.width * 0.917, size.height * 0.795,
      size.width * 0.856, size.height * 0.856,
    );
    rectPath.cubicTo(
      size.width * 0.795, size.height * 0.917,
      size.width * 0.696, size.height * 0.917,
      size.width * 0.5, size.height * 0.917,
    );
    rectPath.cubicTo(
      size.width * 0.304, size.height * 0.917,
      size.width * 0.205, size.height * 0.917,
      size.width * 0.144, size.height * 0.856,
    );
    rectPath.cubicTo(
      size.width * 0.083, size.height * 0.795,
      size.width * 0.083, size.height * 0.696,
      size.width * 0.083, size.height * 0.5,
    );
    rectPath.cubicTo(
      size.width * 0.083, size.height * 0.304,
      size.width * 0.083, size.height * 0.205,
      size.width * 0.144, size.height * 0.144,
    );
    rectPath.cubicTo(
      size.width * 0.205, size.height * 0.083,
      size.width * 0.304, size.height * 0.083,
      size.width * 0.5, size.height * 0.083,
    );
    rectPath.lineTo(size.width * 0.562, size.height * 0.083);
    canvas.drawPath(rectPath, paint);

    // Notification dot circle
    canvas.drawCircle(
      Offset(size.width * 0.792, size.height * 0.208),
      size.width * 0.125,
      paint,
    );

    // Line 1
    canvas.drawLine(
      Offset(size.width * 0.292, size.height * 0.583),
      Offset(size.width * 0.667, size.height * 0.583),
      paint,
    );

    // Line 2
    canvas.drawLine(
      Offset(size.width * 0.292, size.height * 0.729),
      Offset(size.width * 0.542, size.height * 0.729),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Hamburger menu icon painter - matches BrokenEssentionalUiHamburgerMenu
class _HamburgerMenuPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Top line - "4 7L7 7M20 7L11 7"
    canvas.drawLine(
      Offset(size.width * 0.167, size.height * 0.292),
      Offset(size.width * 0.292, size.height * 0.292),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.833, size.height * 0.292),
      Offset(size.width * 0.458, size.height * 0.292),
      paint,
    );

    // Bottom line - "20 17H17M4 17L13 17"
    canvas.drawLine(
      Offset(size.width * 0.833, size.height * 0.708),
      Offset(size.width * 0.708, size.height * 0.708),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.167, size.height * 0.708),
      Offset(size.width * 0.542, size.height * 0.708),
      paint,
    );

    // Middle line - "4 12H7L20 12"
    canvas.drawLine(
      Offset(size.width * 0.167, size.height * 0.5),
      Offset(size.width * 0.833, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Comment Dialog Widget - Stateful to update instantly when comments are added
class _CommentDialogWidget extends StatefulWidget {
  final Post post;
  final User? currentUser;
  final List<Map<String, dynamic>> initialComments;
  final Function(Map<String, dynamic>) onCommentAdded;
  final String Function(DateTime) formatTime;

  const _CommentDialogWidget({
    required this.post,
    required this.currentUser,
    required this.initialComments,
    required this.onCommentAdded,
    required this.formatTime,
  });

  @override
  State<_CommentDialogWidget> createState() => _CommentDialogWidgetState();
}

class _CommentDialogWidgetState extends State<_CommentDialogWidget> {
  List<Map<String, dynamic>> _comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize comments from backend post data
    _loadInitialComments();
  }

  void _loadInitialComments() {
    // Load comments from post
    final backendComments = widget.post.comments.map((comment) {
      return {
        'id': '${comment.userId}_${comment.createdAt.millisecondsSinceEpoch}',
        'text': comment.text,
        'authorName': comment.userName,
        'authorId': comment.userId,
        'timestamp': comment.createdAt,
      };
    }).toList();
    
    // Add any initial local comments that aren't in backend
    final existingIds = backendComments.map((c) => c['id'] as String).toSet();
    final localComments = widget.initialComments.where((c) {
      final id = c['id'] ?? '${c['authorId']}_${(c['timestamp'] as DateTime).millisecondsSinceEpoch}';
      return !existingIds.contains(id);
    }).toList();
    
    // Combine and sort (newest first)
    _comments = [...backendComments, ...localComments];
    _sortComments();
  }

  void _sortComments() {
    _comments.sort((a, b) {
      final timeA = (a['timestamp'] as DateTime).millisecondsSinceEpoch;
      final timeB = (b['timestamp'] as DateTime).millisecondsSinceEpoch;
      return timeB.compareTo(timeA); // Newest first
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment(String text) async {
    if (text.trim().isEmpty) return;

    final now = DateTime.now();
    final commentId = '${widget.currentUser?.id ?? ''}_${now.millisecondsSinceEpoch}';
    
    // Create new comment
    final newComment = {
      'id': commentId,
      'text': text.trim(),
      'authorName': widget.currentUser?.fullName ?? 'You',
      'authorId': widget.currentUser?.id ?? '',
      'timestamp': now,
    };

    // Add comment to UI immediately (at the top)
    setState(() {
      _comments.insert(0, newComment);
    });

    // Update parent comment count immediately
    widget.onCommentAdded(newComment);

    // Clear input
    _commentController.clear();

    // Save to backend (fire and forget - comment is already visible)
    final postRepository = PostRepository();
    postRepository.addComment(widget.post.id, text.trim()).then((savedComment) {
      // Update comment with saved data (in case IDs differ)
      if (mounted) {
        setState(() {
          // Find and update the comment
          final index = _comments.indexWhere((c) => c['id'] == commentId);
          if (index != -1) {
            _comments[index] = {
              'id': '${savedComment.userId}_${savedComment.createdAt.millisecondsSinceEpoch}',
              'text': savedComment.text,
              'authorName': savedComment.userName,
              'authorId': savedComment.userId,
              'timestamp': savedComment.createdAt,
            };
            _sortComments();
          }
        });
      }
    }).catchError((e) {
      // On error, remove the comment
      if (mounted) {
        setState(() {
          _comments.removeWhere((c) => c['id'] == commentId);
        });
        widget.onCommentAdded({
          '_remove': true,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Comments list
              Expanded(
                child: _comments.isEmpty
                    ? const Center(
                        child: Text(
                          'No comments yet.\nBe the first to comment!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          final authorName = comment['authorName'] as String;
                          final firstLetter = authorName.isNotEmpty 
                              ? authorName[0].toUpperCase() 
                              : '?';
                          
                          // Create a stable unique key for each comment using id
                          final commentId = comment['id'] ?? '${comment['authorId']}_${(comment['timestamp'] as DateTime).millisecondsSinceEpoch}';
                          final commentKey = 'comment_$commentId';
                          
                          return KeyedSubtree(
                            key: ValueKey(commentKey),
                            child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.grey[300],
                                  child: Text(
                                    firstLetter,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              authorName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              comment['text'] as String,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.formatTime(comment['timestamp'] as DateTime),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          );
                        },
                      ),
              ),
              // Comment input - fixed at bottom
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          onSubmitted: _addComment,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: AppColors.primary),
                        onPressed: () => _addComment(_commentController.text),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
