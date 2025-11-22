import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/post.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../widgets/post_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/app_bottom_nav.dart';
import 'side_menu.dart';
import '../../../core/utils/animation_lifecycle_mixin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with TickerProviderStateMixin, AnimationLifecycleMixin {
  final _postRepository = PostRepository();
  final _authRepository = AuthRepository();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  
  List<Post> _posts = [];
  User? _currentUser;
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  int _currentIndex = 0;
  
  // Animation controllers
  late AnimationController _bubbleController;
  late AnimationController _greetingController;
  late Animation<double> _bubbleAnimation;
  late Animation<Offset> _greetingSlideAnimation;
  late Animation<double> _greetingFadeAnimation;
  
  @override
  List<AnimationController> get animationControllers => [
    _bubbleController,
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _scrollController.addListener(_onScroll);
    _loadData();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && _hasMore && !_isLoading) {
        _loadMorePosts();
      }
    }
  }
  
  void _initAnimations() {
    // Bubble float animation
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _bubbleAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOut),
    );
    
    // Greeting animation
    _greetingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _greetingSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _greetingController,
      curve: Curves.easeOut,
    ));
    
    _greetingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _greetingController, curve: Curves.easeIn),
    );
    
    _greetingController.forward();
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _bubbleController.dispose();
    _greetingController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final user = await _authRepository.getCurrentUser();
      final posts = await _postRepository.getFeed(page: 1, limit: 10);
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _posts = posts;
          _currentPage = 1;
          _hasMore = posts.length >= 10;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMore) return;
    
    setState(() => _isLoadingMore = true);
    
    try {
      final newPosts = await _postRepository.getFeed(
        page: _currentPage + 1,
        limit: 10,
      );
      
      if (mounted) {
        setState(() {
          if (newPosts.isEmpty || newPosts.length < 10) {
            _hasMore = false;
          } else {
            _posts.addAll(newPosts);
            _currentPage++;
          }
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _isRefreshing = true;
      _currentPage = 1;
      _hasMore = true;
    });
    
    try {
      final posts = await _postRepository.getFeed(page: 1, limit: 10);
      
      if (mounted) {
        setState(() {
          _posts = posts;
          _hasMore = posts.length >= 10;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _handleLike(Post post) async {
    try {
      await _postRepository.toggleLike(post.id);
      await _refreshFeed();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to like post'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleDelete(Post post) async {
    try {
      await _postRepository.deletePost(post.id);
      setState(() {
        _posts.removeWhere((p) => p.id == post.id);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post deleted'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete post'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _navigateToCreatePost() {
    // Navigate to create post screen
    Navigator.pushNamed(context, '/create-post').then((_) => _refreshFeed());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated Decorative bubbles background
          AnimatedBuilder(
            animation: _bubbleAnimation,
            builder: (context, child) {
              return Positioned(
                left: -50,
                top: -100 + _bubbleAnimation.value,
                child: Opacity(
                  opacity: 0.15,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _bubbleAnimation,
            builder: (context, child) {
              return Positioned(
                right: -80,
                bottom: 100 - _bubbleAnimation.value * 0.5,
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 28),
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                      const Spacer(),
                      Image.asset(
                        'assets/images/leos_logo_with_icon.png',
                        height: 55,
                        fit: BoxFit.contain,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, size: 24),
                        onPressed: () {
                          Navigator.pushNamed(context, '/notifications');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu, size: 24),
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                    ],
                  ),
                ),
                
                // Animated User greeting
                SlideTransition(
                  position: _greetingSlideAnimation,
                  child: FadeTransition(
                    opacity: _greetingFadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hello,',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 52,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF202020),
                                  height: 1.0,
                                ),
                              ),
                              Text(
                                _currentUser?.fullName.split(' ').first ?? 'Leo',
                                style: const TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 19,
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFF202020),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (_currentUser?.profilePhoto != null)
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(_currentUser!.profilePhoto!),
                            )
                          else
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                _currentUser?.fullName[0].toUpperCase() ?? 'L',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Feed area
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
                        : _posts.isEmpty
                            ? Container(
                                height: 300,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.post_add,
                                      size: 80,
                                      color: AppColors.disabled,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No posts yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.zero,
                                itemCount: _posts.length + (_hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _posts.length) {
                                    // Loading indicator for pagination
                                    return _isLoadingMore
                                        ? const Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink();
                                  }
                                  
                                  final post = _posts[index];
                                  return _AnimatedPostCard(
                                    post: post,
                                    index: index,
                                    currentUserId: _currentUser?.id,
                                    onLike: () => _handleLike(post),
                                    onComment: () {},
                                    onShare: () {},
                                    onDelete: () => _handleDelete(post),
                                  );
                                },
                              ),
                          
                          // Suggested to Follow section
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Suggested to Follow',
                                  style: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF202020),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 340,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 3,
                                    itemBuilder: (context, index) {
                                      return _buildClubCard(
                                        'LEO Club of ${index == 0 ? 'Katuwala' : index == 1 ? 'Colombo' : 'Kandy'}',
                                        'An outstanding performer in past 2 years continuously....',
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Bottom bar indicator
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    width: 146,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(34),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: SideMenu(user: _currentUser),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: _currentIndex),
    );
  }
  
  Widget _buildClubCard(String name, String description) {
    return Container(
      width: 198,
      height: 317,
      margin: const EdgeInsets.only(right: 16, top: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withOpacity(0.37),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 169,
            height: 169,
            decoration: BoxDecoration(
              color: const Color(0xFF8F7902),
              shape: BoxShape.circle,
            ),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.groups,
                size: 80,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 10,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 169,
            height: 31,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Follow',
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF3F3F3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated Post Card Widget with staggered entrance animation
class _AnimatedPostCard extends StatefulWidget {
  final Post post;
  final int index;
  final String? currentUserId;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _AnimatedPostCard({
    required this.post,
    required this.index,
    this.currentUserId,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onDelete,
  });

  @override
  State<_AnimatedPostCard> createState() => _AnimatedPostCardState();
}

class _AnimatedPostCardState extends State<_AnimatedPostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Staggered animation based on index
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: PostCard(
            post: widget.post,
            currentUserId: widget.currentUserId,
            onLike: widget.onLike,
            onComment: widget.onComment,
            onShare: widget.onShare,
            onDelete: widget.onDelete,
          ),
        ),
      ),
    );
  }
}
