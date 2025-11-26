import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';

/// Club Profile Screen - Based on Home_Page_link Figma design
/// Shows a Leo Club's profile page with posts and info
class ClubProfileScreen extends StatefulWidget {
  final String clubName;
  final String clubLogo;
  final String? clubDescription;

  const ClubProfileScreen({
    super.key,
    required this.clubName,
    required this.clubLogo,
    this.clubDescription,
  });

  @override
  State<ClubProfileScreen> createState() => _ClubProfileScreenState();
}

class _ClubProfileScreenState extends State<ClubProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isFollowing = false;

  // Demo posts for the club
  final List<Map<String, dynamic>> _clubPosts = [
    {
      'image': 'assets/images/Home/lion_post.png',
      'caption': 'City lights and urban nights ✨',
      'likes': 2156,
      'comments': 67,
      'timeAgo': '8 hours ago',
    },
    {
      'image': 'assets/images/pages/bubble01.png',
      'caption': 'Leoism is built on friendship...',
      'likes': 1823,
      'comments': 45,
      'timeAgo': '2 days ago',
    },
    {
      'image': 'assets/images/pages/bubble02.png',
      'caption': 'Making a difference together 🌟',
      'likes': 987,
      'comments': 23,
      'timeAgo': '5 days ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Yellow bubble background (top-left)
          Positioned(
            top: -200,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFD700),
              ),
            ),
          ),
          // Black bubble (smaller, overlapping)
          Positioned(
            top: -100,
            left: 100,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
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
                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 60), // Space for back arrow
                            // Club profile header
                            _buildProfileHeader(),
                            const SizedBox(height: 24),
                            // Follow button
                            _buildFollowButton(),
                            const SizedBox(height: 24),
                            // Club posts
                            ..._clubPosts.map((post) => _buildPostCard(post)),
                            const SizedBox(height: 20),
                            // Post grid
                            _buildPostGrid(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Back arrow positioned on top of bubbles
          _buildAppBar(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Positioned(
      left: 10,
      top: 50,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 50,
          height: 53,
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            'assets/images/profile/back_arrow.png',
            fit: BoxFit.contain,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Club avatar with golden ring
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
              child: Image.asset(
                widget.clubLogo,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.primary,
                  child: const Center(
                    child: Text(
                      'LC',
                      style: TextStyle(
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
        ),
        const SizedBox(height: 16),
        // Club name
        Text(
          widget.clubName,
          style: const TextStyle(
            fontFamily: 'Arimo',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 4),
        // Description
        Text(
          widget.clubDescription ?? 'Leo District 306 D2 • Sri Lanka',
          style: const TextStyle(
            fontFamily: 'Arimo',
            fontSize: 14,
            color: Color(0xFF6A7282),
          ),
        ),
        const SizedBox(height: 16),
        // Stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem('2.5k', 'Followers'),
            Container(
              width: 1,
              height: 30,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(horizontal: 24),
            ),
            _buildStatItem('156', 'Posts'),
            Container(
              width: 1,
              height: 30,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(horizontal: 24),
            ),
            _buildStatItem('48', 'Events'),
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

  Widget _buildFollowButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFollowing = !_isFollowing;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 332,
        height: 39,
        decoration: BoxDecoration(
          color: _isFollowing ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(14),
          border: _isFollowing ? Border.all(color: Colors.black, width: 2) : null,
        ),
        child: Center(
          child: Text(
            _isFollowing ? 'Following' : 'Follow',
            style: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _isFollowing ? Colors.black : const Color(0xFFF3F3F3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                // Club avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      widget.clubLogo,
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
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Club name and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.clubName,
                        style: const TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF101828),
                        ),
                      ),
                      Text(
                        post['timeAgo'],
                        style: const TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 12,
                          color: Color(0xFF6A7282),
                        ),
                      ),
                    ],
                  ),
                ),
                // Three dots menu
                _buildDotsMenu(),
              ],
            ),
          ),
          // Post image
          ClipRRect(
            child: Image.asset(
              post['image'],
              width: double.infinity,
              height: 400,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 400,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          // Actions row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.favorite_border, size: 24, color: Colors.black),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline, size: 24, color: Colors.black),
                const SizedBox(width: 16),
                Transform.rotate(
                  angle: -0.5,
                  child: const Icon(Icons.send_outlined, size: 22, color: Colors.black),
                ),
                const Spacer(),
                const Icon(Icons.bookmark_border, size: 24, color: Colors.black),
              ],
            ),
          ),
          // Likes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${post['likes']} likes',
              style: const TextStyle(
                fontFamily: 'Arimo',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101828),
              ),
            ),
          ),
          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Arimo',
                  fontSize: 16,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: widget.clubName.replaceAll(' ', '_').toLowerCase() + ' ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: post['caption'],
                    style: const TextStyle(color: Color(0xFF364153)),
                  ),
                ],
              ),
            ),
          ),
          // Comments link
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'View all ${post['comments']} comments',
              style: const TextStyle(
                fontFamily: 'Arimo',
                fontSize: 16,
                color: Color(0xFF6A7282),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDotsMenu() {
    return Container(
      width: 36,
      height: 36,
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
    );
  }

  Widget _buildDot() {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF364153),
      ),
    );
  }

  Widget _buildPostGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Posts',
            style: TextStyle(
              fontFamily: 'Arimo',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final images = [
                'assets/images/Home/lion_post.png',
                'assets/images/pages/bubble01.png',
                'assets/images/pages/bubble02.png',
                'assets/images/pages/club1.png',
                'assets/images/pages/club2.png',
                'assets/images/pages/club3.png',
                'assets/images/Home/lion_post.png',
                'assets/images/pages/bubble01.png',
                'assets/images/pages/bubble02.png',
              ];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    images[index % images.length],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
