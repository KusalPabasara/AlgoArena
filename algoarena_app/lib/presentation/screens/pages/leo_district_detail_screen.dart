import 'package:flutter/material.dart';

/// Leo District Detail Page - implements exact Figma design from Leo_district_362 folder
/// This page shows when a district is clicked from the District Pages list
/// Bubbles: left:-239.41, top:-479.78, w:609.977, h:570.222, viewBox 610x571 (same as Pages)
/// Profile: Leo District 306 D2 with ellipse border
/// Posts: Social media style posts with likes, comments, etc.

class LeoDistrictDetailScreen extends StatefulWidget {
  final String districtName;
  final String mutuals;
  final String image;
  
  const LeoDistrictDetailScreen({
    super.key,
    required this.districtName,
    required this.mutuals,
    required this.image,
  });

  @override
  State<LeoDistrictDetailScreen> createState() => _LeoDistrictDetailScreenState();
}

class _LeoDistrictDetailScreenState extends State<LeoDistrictDetailScreen> {
  // Sample posts data matching Figma design
  final List<Map<String, dynamic>> _posts = [
    {
      'authorName': 'Leo District 306 D2',
      'authorImage': 'assets/images/pages/cba507d80d35e8876a479cce78f72f4bb9d95def.png',
      'timeAgo': '8 hours ago',
      'postImage': 'assets/images/pages/6d81b876706ace03505fb1391671ba47b0073e5e.png',
      'likes': '2156 likes',
      'username': 'john_d',
      'caption': 'City lights and urban nights ✨',
      'comments': 'View all 67 comments',
    },
    {
      'authorName': 'Leo District 306 D2',
      'authorImage': 'assets/images/pages/cba507d80d35e8876a479cce78f72f4bb9d95def.png',
      'timeAgo': '2 days ago',
      'postImage': 'assets/images/pages/28144f3b7b31659eca64dd7042213cc7b21abe19.png',
      'likes': '2156 likes',
      'username': 'john_d',
      'caption': 'Leoism is built on friendship...',
      'comments': 'View all 67 comments',
    },
    {
      'authorName': 'john_d',
      'authorImage': 'assets/images/pages/4cab12f568771ad0b3afa40dc378bc7ed480eb86.png',
      'timeAgo': '8 hours ago',
      'postImage': 'assets/images/pages/2d56f1c4118e0f4442bbdf50c8d39b18e1794de0.png',
      'likes': '2156 likes',
      'username': 'john_d',
      'caption': 'City lights and urban nights ✨',
      'comments': 'View all 67 comments',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Bubbles - same as Pages screen but positioned higher
          // Figma: left:-239.41, top:-479.78, w:609.977, h:570.222
          Positioned(
            left: -239.41,
            top: -479.78,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, opacity, child) {
                return Opacity(opacity: opacity, child: child);
              },
              child: SizedBox(
                width: 609.977,
                height: 570.222,
                child: CustomPaint(
                  size: const Size(609.977, 570.222),
                  painter: _DistrictDetailBubblesPainter(),
                ),
              ),
            ),
          ),
          
          // White header background - Figma: h:93px
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: 93,
            child: Container(
              color: Colors.white,
            ),
          ),
          
          // Scrollable content area - Figma: left:10, top:50, w:377, h:811
          Positioned(
            left: 10,
            top: 100,
            right: 10,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  
                  // Header row with profile image and title
                  _buildProfileHeader(),
                  
                  const SizedBox(height: 12),
                  
                  // Description text
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Text(
                      '${widget.districtName} is one of the leading Leo Districts in Sri Lanka.',
                      style: const TextStyle(
                        fontFamily: 'NunitoSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 18 / 12,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 18),
                  
                  // Action buttons row
                  _buildActionButtons(),
                  
                  const SizedBox(height: 20),
                  
                  // Posts list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 17),
                    itemBuilder: (context, index) => _buildPostCard(_posts[index]),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          
          // Back button - Figma: left:10, top:50, 50x53px
          Positioned(
            left: 10,
            top: 50,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: SizedBox(
                width: 50,
                height: 53,
                child: Image.asset(
                  'assets/images/pages/e5b2d02426dff02ff323daa74a9b12f7fea3649b.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/pages/a6c3b1de0238b60ae5f0966181a9108216c6d648.png',
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Settings icon - Figma: right side, top:59, 34x34px
          Positioned(
            right: 15,
            top: 59,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings coming soon...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.settings,
                  size: 28,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Profile header with image, name, mutuals - Figma layout
  Widget _buildProfileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Profile image on left, badge/map on right
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image with golden border - Figma: ellipse with #8F7902 border
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8F7902),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.16),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 85,
                    height: 85,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        widget.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, size: 40),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Badge/logo image - Figma: D2-370x493 1
              SizedBox(
                width: 120,
                height: 150,
                child: Image.asset(
                  'assets/images/pages/22ef6a6cb7a634b7184f32f521583aa56558f323.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 15),
        
        // District name - below profile image
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            widget.districtName,
            style: const TextStyle(
              fontFamily: 'NunitoSans',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              height: 31 / 22,
            ),
          ),
        ),
        
        // Mutuals - below name
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            widget.mutuals,
            style: const TextStyle(
              fontFamily: 'NunitoSans',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black,
              height: 20 / 12,
            ),
          ),
        ),
      ],
    );
  }
  
  // Action buttons: Create new post, Add announcement
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          // Create new post button - with + icon, border style
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Create new post coming soon...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              height: 39,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, size: 18, color: Colors.black),
                  SizedBox(width: 6),
                  Text(
                    'Create new post',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Add announcement button - solid black
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add announcement coming soon...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              height: 39,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'Add announcement',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF3F3F3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Post card - matches Figma Post component
  // w:373, h:620, bg:white, rounded:16, shadow
  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 0.667),
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
          // Post header - author info and menu
          _buildPostHeader(post),
          
          // Post image - increased height to show full content
          SizedBox(
            height: 400,
            width: double.infinity,
            child: Image.asset(
              post['postImage'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[100],
                  child: const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          
          // Post footer - likes, caption, comments
          _buildPostFooter(post),
        ],
      ),
    );
  }
  
  // Post header with author avatar, name, time and menu
  Widget _buildPostHeader(Map<String, dynamic> post) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Author info
          Row(
            children: [
              // Avatar - rounded with border
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[200]!, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    post['authorImage'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 20),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Name and time
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    post['authorName'],
                    style: const TextStyle(
                      fontFamily: 'Arimo',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF101828),
                      height: 24 / 16,
                    ),
                  ),
                  Text(
                    post['timeAgo'],
                    style: const TextStyle(
                      fontFamily: 'Arimo',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6A7282),
                      height: 16 / 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Menu button (3 dots)
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, color: Color(0xFF364153)),
          ),
        ],
      ),
    );
  }
  
  // Post footer with action buttons, likes, caption, comments
  Widget _buildPostFooter(Map<String, dynamic> post) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left buttons: like, comment, share
              Row(
                children: [
                  // Heart icon
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      Icons.favorite_border,
                      size: 24,
                      color: Color(0xFF364153),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Comment icon
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      size: 24,
                      color: Color(0xFF364153),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Share icon
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      Icons.send_outlined,
                      size: 24,
                      color: Color(0xFF364153),
                    ),
                  ),
                ],
              ),
              
              // Bookmark icon
              GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.bookmark_border,
                  size: 24,
                  color: Color(0xFF364153),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Likes count
          Text(
            post['likes'],
            style: const TextStyle(
              fontFamily: 'Arimo',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF101828),
              height: 24 / 16,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Username and caption
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${post['username']} ',
                  style: const TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF101828),
                    height: 24 / 16,
                  ),
                ),
                TextSpan(
                  text: post['caption'],
                  style: const TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF364153),
                    height: 24 / 16,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 4),
          
          // View comments
          GestureDetector(
            onTap: () {},
            child: Text(
              post['comments'],
              style: const TextStyle(
                fontFamily: 'Arimo',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6A7282),
                height: 24 / 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// District Detail bubbles painter - same SVG paths as Pages screen
// viewBox="0 0 610 571", positioned at top:-479.78 instead of -332.78
class _DistrictDetailBubblesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 610;
    final scaleY = size.height / 571;
    
    canvas.scale(scaleX, scaleY);
    
    // Yellow bubble (bubble 02) - p2c14ce80
    final yellowPath = Path();
    yellowPath.moveTo(508.627, 340.687);
    yellowPath.cubicTo(593.237, 477.805, 349.549, 493.671, 246.4, 451.996);
    yellowPath.cubicTo(143.25, 410.321, 93.4158, 292.918, 135.091, 189.769);
    yellowPath.cubicTo(176.766, 86.6197, 285.06, 74.0647, 382.127, 104.549);
    yellowPath.cubicTo(479.194, 135.033, 424.016, 203.569, 508.627, 340.687);
    yellowPath.close();
    
    final yellowPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(yellowPath, yellowPaint);
    
    // Black bubble (bubble 01) - p38579800
    final blackPath = Path();
    blackPath.moveTo(135.167, 375.884);
    blackPath.cubicTo(-24.975, 358.14, 112.552, 156.343, 208.897, 100.718);
    blackPath.cubicTo(305.243, 45.093, 428.439, 78.1032, 484.064, 174.448);
    blackPath.cubicTo(539.689, 270.794, 506.678, 393.99, 410.333, 449.615);
    blackPath.cubicTo(313.988, 505.24, 295.309, 393.629, 135.167, 375.884);
    blackPath.close();
    
    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(blackPath, blackPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
