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

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _postRepository = PostRepository();
  final _authRepository = AuthRepository();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  
  List<Post> _posts = [];
  User? _currentUser;
  bool _isLoading = true;
  bool _isRefreshing = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _authRepository.getCurrentUser();
      final posts = await _postRepository.getFeed();
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _posts = posts;
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

  Future<void> _refreshFeed() async {
    setState(() => _isRefreshing = true);
    
    try {
      final posts = await _postRepository.getFeed();
      
      if (mounted) {
        setState(() {
          _posts = posts;
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
          // Decorative bubbles background
          Positioned(
            left: -50,
            top: -100,
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
          ),
          Positioned(
            right: -80,
            bottom: 100,
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
                
                // User greeting
                Padding(
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
                
                // Feed area
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshFeed,
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Posts feed
                          if (_posts.isEmpty)
                            Container(
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
                          else
                            ...(_posts.take(3).map((post) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: PostCard(
                                post: post,
                                currentUserId: _currentUser?.id,
                                onLike: () => _handleLike(post),
                                onComment: () {},
                                onShare: () {},
                                onDelete: () => _handleDelete(post),
                              ),
                            ))),
                          
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
