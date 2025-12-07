import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../data/models/page.dart' as models;
import '../../../providers/auth_provider.dart';
import '../../../providers/page_follow_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import 'page_detail_screen.dart';

class ClubPagesListScreen extends StatefulWidget {
  const ClubPagesListScreen({super.key});

  @override
  State<ClubPagesListScreen> createState() => _ClubPagesListScreenState();
}

class _ClubPagesListScreenState extends State<ClubPagesListScreen> {
  final _pageRepository = PageRepository();
  List<models.Page> _clubPages = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadClubPages();
  }
  
  Future<void> _loadClubPages() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isSuperAdmin) {
        setState(() {
          _clubPages = [];
          _isLoading = false;
        });
        return;
      }
      
      final pages = await _pageRepository.getAllPages();
      if (mounted) {
        setState(() {
          _clubPages = pages.where((p) => p.type == 'club').toList();
          _isLoading = false;
        });
        // Load follow statuses using provider
        final followProvider = Provider.of<PageFollowProvider>(context, listen: false);
        final pageIds = _clubPages.map((p) => p.id).toList();
        followProvider.loadFollowStatuses(pageIds);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load club pages: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _toggleFollow(models.Page page, int index) async {
    final followProvider = Provider.of<PageFollowProvider>(context, listen: false);
    
    try {
      final isFollowing = await followProvider.toggleFollow(page.id);
      // Follower count is already updated by toggleFollow in the provider
      // No need to reload all pages - UI updates automatically via Consumer widgets
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFollowing 
                ? 'Following ${page.name}' 
                : 'Unfollowed ${page.name}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
            backgroundColor: isFollowing 
                ? const Color(0xFF8F7902) 
                : Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to toggle follow: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Bubbles - Club Pages uses same bubble shape as Pages screen
          // Figma: left:-239.41, top:-332.78, w:609.977, h:570.222, viewBox 610x571
          Positioned(
            left: -239.41,
            top: -332.78,
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
                  painter: _ClubBubblesPainter(),
                ),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Scrollable content - Figma: left:35, top:211, h:634, w:332
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 120), // Space for header
                        
                        // "Club Pages :" title - Figma: left:35, top:169
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
                        
                        // Club Pages list - Figma: left:35, top:211, h:644
                        _isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 35),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : _clubPages.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 35),
                                    child: Center(
                                      child: Text(
                                        'No club pages available',
                                        style: TextStyle(fontSize: 14, color: Colors.grey),
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 35),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _clubPages.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 11),
                                      itemBuilder: (context, index) {
                                        final page = _clubPages[index];
                                        // Check if name is long (2 lines)
                                        final isLargeCard = page.name.length > 25;
                                        return _buildPageCard(page, index, isLargeCard);
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
                  'assets/images/pages/a6c3b1de0238b60ae5f0966181a9108216c6d648.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          
          // "Pages" title - Figma: left:69, top:48, white on bubbles
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
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  Widget _buildPageCard(models.Page page, int index, bool isLargeCard) {
    return Consumer<PageFollowProvider>(
      builder: (context, followProvider, child) {
        final isFollowing = followProvider.isFollowing(page.id);
        final followersCount = followProvider.getFollowerCount(page.id);
        final isToggling = followProvider.isToggling(page.id);
        final cardHeight = isLargeCard ? 134.0 : 117.0;
        final buttonTop = isLargeCard ? 81.0 : 66.0;
        
        // Use provider's follower count if available, otherwise use page's
        final displayCount = followersCount > 0 ? followersCount : page.followersCount;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PageDetailScreen(page: page),
          ),
        );
      },
      child: Container(
      height: cardHeight,
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
                      color: Colors.grey[300],
                      image: page.logo != null
                          ? DecorationImage(
                              image: NetworkImage(page.logo!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: page.logo == null
                        ? const Icon(Icons.group, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
              ],
            ),
          ),
          
          // Name - Figma: left:121, top:14
          Positioned(
            left: 121,
            top: 14,
            child: Text(
              page.name,
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                height: 31 / 16,
              ),
            ),
          ),
          
          // Followers count - Figma: left:121, top:33 (or 48 for large card)
          Positioned(
            left: 121,
            top: isLargeCard ? 48 : 33,
            child: Text(
              '$displayCount followers',
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                height: 31 / 10,
              ),
            ),
          ),
          
          // Follow button - Figma: left:121, top:66 (or 81 for large card)
          Positioned(
            left: 121,
            top: buttonTop,
            child: GestureDetector(
              onTap: isToggling ? null : () => _toggleFollow(page, index),
              child: Container(
                width: 196,
                height: 39,
                decoration: BoxDecoration(
                  color: isFollowing ? const Color(0xFF8F7902) : Colors.black,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
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
          ),
        ],
      ),
      ),
    );
      },
    );
  }
}

// Club Pages bubbles painter - same as Pages screen bubbles
// viewBox="0 0 610 571", exact SVG paths from Figma ClubPages.tsx
class _ClubBubblesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 610;
    final scaleY = size.height / 571;
    
    canvas.scale(scaleX, scaleY);
    
    // Yellow bubble (bubble 02) - p3c380100
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
    
    // Black bubble (bubble 01) - p4253040
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
