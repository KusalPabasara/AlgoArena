import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import 'club_pages_list_screen.dart';
import 'district_pages_list_screen.dart';
import 'create_page_screen.dart';

class PagesScreen extends StatefulWidget {
  const PagesScreen({super.key});

  @override
  State<PagesScreen> createState() => _PagesScreenState();
}

class _PagesScreenState extends State<PagesScreen>
    with TickerProviderStateMixin {
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;
  bool _isInitialized = false;

  // Club pages data - Using Figma assets
  final List<Map<String, dynamic>> _clubPages = [
    {
      'name': 'Leo Club of Colombo',
      'followers': 102,
      'isFollowing': false,
      'image': 'assets/images/pages/c6d5f9dff52b37a28977be041de113bc88dfa388.png',
    },
    {
      'name': 'Leo Club of Katuwawala',
      'followers': 97,
      'isFollowing': false,
      'image': 'assets/images/pages/6cd6f189d2f86fcc32f0d234e0416b42a8dcf4dd.png',
    },
  ];

  // District pages data - Using Figma assets
  final List<Map<String, dynamic>> _districtPages = [
    {
      'name': 'Leo District 306 D2',
      'followers': 209,
      'isFollowing': false,
      'image': 'assets/images/pages/cba507d80d35e8876a479cce78f72f4bb9d95def.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeOut,
    );
    _fadeController!.forward();
    _isInitialized = true;
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    super.dispose();
  }

  void _toggleFollow(List<Map<String, dynamic>> list, int index) {
    setState(() {
      list[index]['isFollowing'] = !(list[index]['isFollowing'] as bool);
    });
    
    final name = list[index]['name'];
    final isFollowing = list[index]['isFollowing'] as bool;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFollowing ? 'Following $name' : 'Unfollowed $name'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        backgroundColor: isFollowing ? const Color(0xFF8F7902) : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wait for animation to be initialized
    if (!_isInitialized || _fadeAnimation == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Check if user is Super Admin
    final authProvider = Provider.of<AuthProvider>(context);
    final isSuperAdmin = authProvider.user?.isSuperAdmin ?? false;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Bubbles background - matching Figma positions
          _buildBubbles(),
          
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation!,
              child: Column(
                children: [
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 120), // More space to push content below bubbles
                          
                          // Club Pages section title - Figma: left:35, top:169
                          const Padding(
                            padding: EdgeInsets.only(left: 35),
                            child: Text(
                              'Club Pages :',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                height: 32 / 26,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Club Pages list - Figma: left:35, top:211, h:245
                          SizedBox(
                            height: 256, // 245 + 11 separator
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 35),
                              child: ListView.separated(
                                physics: const ClampingScrollPhysics(),
                                itemCount: _clubPages.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 11),
                                itemBuilder: (context, index) {
                                  return _buildPageCard(
                                    _clubPages[index],
                                    () => _toggleFollow(_clubPages, index),
                                  );
                                },
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 6),
                          
                          // See more button for clubs - navigates to ClubPagesListScreen with bubble transition
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 35),
                            child: _buildSeeMoreButton(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => 
                                        const ClubPagesListScreen(),
                                    transitionDuration: const Duration(milliseconds: 500),
                                    reverseTransitionDuration: const Duration(milliseconds: 400),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      // Fade transition for smooth bubble transition effect
                                      return FadeTransition(
                                        opacity: CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOut,
                                        ),
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 28),
                          
                          // District Pages section title - Figma: left:35, top:543
                          const Padding(
                            padding: EdgeInsets.only(left: 35),
                            child: Text(
                              'District Pages :',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                height: 34 / 26,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // District Pages list - Figma: left:29, top:584
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 29),
                            child: _buildPageCard(
                              _districtPages[0],
                              () => _toggleFollow(_districtPages, 0),
                            ),
                          ),
                          
                          const SizedBox(height: 6),
                          
                          // See more button for districts - navigates to DistrictPagesListScreen with bubble transition
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 29),
                            child: _buildSeeMoreButton(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => 
                                        const DistrictPagesListScreen(),
                                    transitionDuration: const Duration(milliseconds: 500),
                                    reverseTransitionDuration: const Duration(milliseconds: 400),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      // Fade transition for smooth bubble morphing effect
                                      return FadeTransition(
                                        opacity: CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOut,
                                        ),
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Back button - Figma: left:10, top:50, 50x53px (using image asset)
          Positioned(
            left: 10,
            top: 50,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: SizedBox(
                width: 50,
                height: 53,
                child: Image.asset(
                  'assets/images/pages/a6c3b1de0238b60ae5f0966181a9108216c6d648.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          
          // "Pages" title - Figma: left:69, top:48, 50px Raleway Bold
          // White text on the bubbles
          const Positioned(
            left: 69,
            top: 48,
            child: Text(
              'Pages',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 50,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.52,
              ),
            ),
          ),
        ],
      ),
      // Floating Action Button for Super Admin to create pages
      floatingActionButton: isSuperAdmin
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const CreatePageScreen(),
                    transitionDuration: const Duration(milliseconds: 400),
                    reverseTransitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          )),
                          child: child,
                        ),
                      );
                    },
                  ),
                );
                
                // Handle newly created page
                if (result != null && result is Map) {
                  // Add the new page to the appropriate list
                  setState(() {
                    if (result['type'] == 'club') {
                      _clubPages.add({
                        'name': result['name'],
                        'followers': result['followers'] ?? 0,
                        'isFollowing': false,
                        'image': result['image'] ?? 'assets/images/pages/c6d5f9dff52b37a28977be041de113bc88dfa388.png',
                      });
                    } else {
                      _districtPages.add({
                        'name': result['name'],
                        'followers': result['followers'] ?? 0,
                        'isFollowing': false,
                        'image': result['image'] ?? 'assets/images/pages/cba507d80d35e8876a479cce78f72f4bb9d95def.png',
                      });
                    }
                  });
                }
              },
              backgroundColor: const Color(0xFF8F7902),
              elevation: 4,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 32,
              ),
            )
          : null,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  Widget _buildBubbles() {
    // Exact Figma values: left:-239.41px, top:-332.78px, w:609.977px, h:570.222px
    // viewBox="0 0 610 571" with fade-in transition
    return Positioned(
      left: -239.41,
      top: -332.78,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        builder: (context, opacity, child) {
          return Opacity(
            opacity: opacity,
            child: child,
          );
        },
        child: SizedBox(
          width: 609.977,
          height: 570.222,
          child: CustomPaint(
            size: const Size(609.977, 570.222),
            painter: _BubblesPainter(),
          ),
        ),
      ),
    );
  }

  Widget _buildPageCard(Map<String, dynamic> page, VoidCallback onFollowTap) {
    final isFollowing = page['isFollowing'] as bool;
    
    return Container(
      height: 117,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Logo with gold border - Figma: left:15, top:14
          Positioned(
            left: 15,
            top: 14,
            child: Stack(
              children: [
                // Gold border background
                Container(
                  width: 91,
                  height: 91,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8F7902),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                // Image
                Positioned(
                  left: 5,
                  top: 5,
                  child: Container(
                    width: 81,
                    height: 81,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage(page['image'] as String),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Page name - Figma: left:121, top:14
          Positioned(
            left: 121,
            top: 14,
            child: Text(
              page['name'] as String,
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                height: 31 / 16,
              ),
            ),
          ),
          
          // Followers count - Figma: left:121, top:33
          Positioned(
            left: 121,
            top: 33,
            child: Text(
              '${page['followers']} followers',
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                height: 31 / 10,
              ),
            ),
          ),
          
          // Follow/Unfollow button - Figma: left:121, top:66
          Positioned(
            left: 121,
            top: 66,
            child: GestureDetector(
              onTap: onFollowTap,
              child: Container(
                width: 196,
                height: 39,
                decoration: BoxDecoration(
                  color: isFollowing ? const Color(0xFF8F7902) : Colors.black,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  isFollowing ? 'Unfollow' : 'Follow',
                  style: const TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF3F3F3),
                    height: 31 / 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeeMoreButton({VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading more pages...'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: 332,
        height: 39,
        decoration: BoxDecoration(
          color: const Color(0xFFE6E6E6),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: const Text(
          'See more...',
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            height: 31 / 15,
          ),
        ),
      ),
    );
  }
}

// Custom painter to draw the exact Figma bubble shapes
class _BubblesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Scale factor from viewBox (610x571) to actual size
    final scaleX = size.width / 610;
    final scaleY = size.height / 571;
    
    canvas.scale(scaleX, scaleY);
    
    // Yellow bubble (bubble 02) - exact SVG path from Figma
    final yellowPath = Path();
    yellowPath.moveTo(508.626, 340.687);
    yellowPath.cubicTo(593.237, 477.805, 349.548, 493.671, 246.399, 451.996);
    yellowPath.cubicTo(143.25, 410.321, 93.4156, 292.918, 135.091, 189.768);
    yellowPath.cubicTo(176.766, 86.6194, 285.06, 74.0645, 382.127, 104.548);
    yellowPath.cubicTo(479.194, 135.032, 424.016, 203.569, 508.626, 340.687);
    yellowPath.close();
    
    final yellowPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(yellowPath, yellowPaint);
    
    // Black bubble (bubble 01) - exact SVG path from Figma
    final blackPath = Path();
    blackPath.moveTo(135.167, 375.884);
    blackPath.cubicTo(-24.975, 358.14, 112.552, 156.343, 208.897, 100.718);
    blackPath.cubicTo(305.243, 45.0929, 428.439, 78.1032, 484.064, 174.448);
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
