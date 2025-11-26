import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/post.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/app_bottom_nav.dart';
import '../club/club_profile_screen.dart';
import 'side_menu.dart';
import 'create_post_screen.dart';

/// Home Screen - Matches Home_Page/src/imports/Home.tsx exactly
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _loadData();
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
        posts = await _postRepository.getFeed();
      } catch (e) {
        // Use empty posts if API fails
      }
      
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
        // Only show error if we don't have a user at all
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.error,
            ),
          );
        } else {
          // Use AuthProvider user
          setState(() {
            _currentUser = authProvider.user;
          });
        }
      }
    }
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
      
      if (mounted) {
        setState(() {
          _currentUser = user ?? _currentUser;
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
        const SnackBar(
          content: Text('Failed to like post'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background bubbles - matching Home.tsx Bubbles component
          _buildBubbles(screenWidth, screenHeight),
          
          // Main content
          SafeArea(
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
                                  // Always show the Leo Club lion post first
                                  _buildDemoPost(),
                                  // Then show posts from API
                                  ..._posts.take(5).map((post) => _buildPostCard(post)),
                                  const SizedBox(height: 16),
                                  // Suggested to Follow section
                                  _buildSuggestedToFollow(),
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
        ],
      ),
      drawer: SideMenu(user: _currentUser),
      // Floating action button for verified users to create posts
      floatingActionButton: _currentUser?.isVerified == true
          ? FloatingActionButton(
              onPressed: _navigateToCreatePost,
              backgroundColor: const Color(0xFFFFD700),
              child: const Icon(
                Icons.add,
                color: Colors.black,
                size: 28,
              ),
            )
          : null,
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  // Navigate to create post screen
  void _navigateToCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(user: _currentUser!),
      ),
    );
    
    // Refresh feed if post was created
    if (result == true) {
      _refreshFeed();
    }
  }

  /// Bubbles background - exact from Home.tsx with fade-in transition
  Widget _buildBubbles(double screenWidth, double screenHeight) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Large bubble top-left (Ellipse 171) - 328x312, opacity 0.2
          Positioned(
            left: -226,
            top: -216,
            child: Container(
              width: 328,
              height: 312,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700).withOpacity(0.2),
              ),
            ),
          ),
          // Small bubble top (Ellipse 174) - 80x76, opacity 0.3
          Positioned(
            left: 36,
            top: -153,
            child: Container(
              width: 80,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700).withOpacity(0.3),
              ),
            ),
          ),
          // Bubble top-right (Ellipse 175) - 105x100, opacity 0.3
          Positioned(
            left: 333,
            top: -50,
            child: Container(
              width: 105,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700).withOpacity(0.3),
              ),
            ),
          ),
          // Bubble bottom-left (Ellipse 172) - 52x50, opacity 0.5
          Positioned(
            left: 17,
            bottom: 50,
            child: Container(
              width: 52,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700).withOpacity(0.5),
              ),
            ),
          ),
          // Bubble bottom-right (Ellipse 173) - 65x62, opacity 0.4
          Positioned(
            right: 30,
            bottom: 30,
            child: Container(
              width: 65,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700).withOpacity(0.4),
              ),
            ),
          ),
        ],
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
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
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

  /// Demo post from Leo Club of Colombo - matching Figma design
  /// Navigate to club profile with slide transition
  void _navigateToClubProfile(String clubName, String clubLogo) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ClubProfileScreen(
          clubName: clubName,
          clubLogo: clubLogo,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          
          var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeIn),
          );
          
          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildDemoPost() {
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
                // Avatar - Leo Club Colombo logo (clickable)
                GestureDetector(
                  onTap: () => _navigateToClubProfile(
                    'Leo Club of Colombo',
                    'assets/images/Home/Leo club colombo.png',
                  ),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                      color: const Color(0xFF1E3A8A),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/Home/Leo club colombo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text(
                            'LC',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Text info (clickable)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToClubProfile(
                      'Leo Club of Colombo',
                      'assets/images/Home/Leo club colombo.png',
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Leo Club of Colombo',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF101828),
                          ),
                        ),
                        Text(
                          '8 hours ago',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6A7282),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Options button (3 dots)
                GestureDetector(
                  onTap: () {},
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
          // Post image - Lion "Your Turn to Lead" post from assets
          Container(
            width: double.infinity,
            color: const Color(0xFFF5E6D3), // Background color matching image edges
            child: Image.asset(
              'assets/images/Home/lion_post.png',
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                height: 400,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFD4A574),
                      Color(0xFF8B6914),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets,
                        size: 80,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'YOUR TURN TO LEAD',
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Build skills | Make friends | Serve with pride',
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Post actions - Like, Comment, Share, Bookmark
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Like
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.favorite_border,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                // Comment
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                // Share
                GestureDetector(
                  onTap: () {},
                  child: Transform.rotate(
                    angle: -0.5, // Rotate send icon
                    child: const Icon(
                      Icons.send_outlined,
                      size: 22,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Spacer(),
                // Bookmark
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.bookmark_border,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Likes count
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '2,156 likes',
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 14,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: 'leo_colombo ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: 'City lights and urban nights ✨ Making a difference in our community!',
                    style: TextStyle(color: Color(0xFF374151)),
                  ),
                ],
              ),
            ),
          ),
          // Comments link
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'View all 67 comments',
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Suggested to Follow section - using Leo Clubs from different districts with actual logos
  Widget _buildSuggestedToFollow() {
    final suggestedClubs = [
      {'name': 'Leo Club of Moratuwa', 'members': '3.2k', 'logo': 'assets/images/pages/club1.png', 'color': const Color(0xFFDC2626)},
      {'name': 'Leo Club of Mt.Lavinia', 'members': '5.1k', 'logo': 'assets/images/pages/club2.png', 'color': const Color(0xFF2563EB)},
      {'name': 'Leo Club of Galle', 'members': '2.8k', 'logo': 'assets/images/pages/club3.png', 'color': const Color(0xFF7C3AED)},
      {'name': 'Leo Club of Matara', 'members': '2.1k', 'logo': 'assets/images/pages/club1.png', 'color': const Color(0xFF059669)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Suggested to Follow',
                style: TextStyle(
                  fontFamily: 'Arimo',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101828),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE6B800),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Horizontal scrollable list of club cards
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: suggestedClubs.length,
            itemBuilder: (context, index) {
              final club = suggestedClubs[index];
              return Container(
                width: 140,
                margin: EdgeInsets.only(right: index < suggestedClubs.length - 1 ? 12 : 0),
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
                    // Club logo from assets
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: club['color'] as Color,
                        boxShadow: [
                          BoxShadow(
                            color: (club['color'] as Color).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          club['logo'] as String,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              (club['name'] as String).split(' ').map((w) => w[0]).take(2).join(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
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
                      child: Text(
                        club['name'] as String,
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
                    const SizedBox(height: 2),
                    // Members count
                    Text(
                      '${club['members']} members',
                      style: const TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Follow button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Follow',
                        style: TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
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
          // Post image - ImageWithFallback1 from Home.tsx
          if (post.images.isNotEmpty)
            ClipRRect(
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
          // Post content (if no image, show content)
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
          // Post actions - Like, Comment, Share, Bookmark
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Like
                GestureDetector(
                  onTap: () => _handleLike(post),
                  child: Icon(
                    post.isLikedBy(_currentUser?.id ?? '') 
                        ? Icons.favorite 
                        : Icons.favorite_border,
                    size: 24,
                    color: post.isLikedBy(_currentUser?.id ?? '') 
                        ? Colors.red 
                        : Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                // Comment
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                // Share
                GestureDetector(
                  onTap: () {},
                  child: Transform.rotate(
                    angle: -0.5,
                    child: const Icon(
                      Icons.send_outlined,
                      size: 22,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Spacer(),
                // Bookmark
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.bookmark_border,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Likes count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${post.likesCount} likes',
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          // Caption
          if (post.content.isNotEmpty && post.images.isNotEmpty)
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
          // Comments link
          if (post.commentsCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'View all ${post.commentsCount} comments',
                style: const TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
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

  void _showPostOptions(Post post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Save'),
              onTap: () => Navigator.pop(context),
            ),
            if (post.authorId == _currentUser?.id)
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

  Future<void> _deletePost(Post post) async {
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
        const SnackBar(
          content: Text('Failed to delete post'),
          backgroundColor: AppColors.error,
        ),
      );
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
