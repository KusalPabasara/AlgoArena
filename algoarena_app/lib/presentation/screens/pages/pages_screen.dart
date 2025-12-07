import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/page_follow_provider.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../data/models/page.dart' as models;
import '../../widgets/custom_back_button.dart';
import '../../../utils/responsive_utils.dart';
import 'create_page_screen.dart';
import 'edit_page_screen.dart';
import 'page_detail_screen.dart';

class PagesScreen extends StatefulWidget {
  const PagesScreen({super.key});
  
  static final GlobalKey<_PagesScreenState> globalKey = GlobalKey<_PagesScreenState>();

  @override
  State<PagesScreen> createState() => _PagesScreenState();
}

class _PagesScreenState extends State<PagesScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<Offset>? _bubblesSlideAnimation;
  Animation<Offset>? _contentSlideAnimation;
  Animation<double>? _bubblesFadeAnimation;
  Animation<double>? _contentFadeAnimation;
  DateTime? _lastAnimationTime;

  final _pageRepository = PageRepository();
  List<models.Page> _clubPages = [];
  List<models.Page> _districtPages = [];
  bool _isLoadingPages = true;
  String _selectedFilter = 'club'; // 'club' or 'district'

  @override
  void initState() {
    super.initState();
    _loadPages();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Bubbles animation - coming from outside (top-left)
    _bubblesSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOutCubic,
    ));
    
    _bubblesFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    // Content animation - coming from bottom
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
  }
  
  // Public method to restart animation (called from MainScreen)
  void restartAnimation() {
    if (!mounted || _animationController == null) return;
    
    final now = DateTime.now();
    if (_lastAnimationTime == null || 
        now.difference(_lastAnimationTime!).inMilliseconds > 200) {
      _lastAnimationTime = now;
      
      if (_animationController!.isAnimating) {
        _animationController!.stop();
      }
      
      _animationController!.reset();
      _animationController!.forward();
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _showDeleteDialog(models.Page page) async {
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
            SnackBar(
              content: Text('Page "${page.name}" deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadPages(); // Reload pages after deletion
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

  Future<void> _loadPages() async {
    if (!mounted) return;
    
    setState(() => _isLoadingPages = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isSuperAdmin = authProvider.isSuperAdmin;
      
      // For super admin without token, show empty list gracefully
      if (isSuperAdmin) {
        try {
          final pages = await _pageRepository.getAllPages();
          if (mounted) {
            setState(() {
              _clubPages = pages.where((p) => p.type == 'club').toList();
              _districtPages = pages.where((p) => p.type == 'district').toList();
              _isLoadingPages = false;
            });
          }
        } catch (e) {
          // Super admin might not have backend access - show empty list
          if (mounted) {
            setState(() {
              _clubPages = [];
              _districtPages = [];
              _isLoadingPages = false;
            });
          }
        }
      } else {
        final pages = await _pageRepository.getAllPages();
        if (mounted) {
          setState(() {
            _clubPages = pages.where((p) => p.type == 'club').toList();
            _districtPages = pages.where((p) => p.type == 'district').toList();
            _isLoadingPages = false;
          });
          // Load follow statuses after pages are loaded using provider
          final followProvider = Provider.of<PageFollowProvider>(context, listen: false);
          final allPageIds = [..._clubPages, ..._districtPages].map((p) => p.id).toList();
          followProvider.loadFollowStatuses(allPageIds);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPages = false);
        // Only show error if not super admin (super admin might not have backend access)
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isSuperAdmin) {
          // Log error for debugging
          print('Error loading pages: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load pages: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          // Super admin - just show empty list
          setState(() {
            _clubPages = [];
            _districtPages = [];
          });
        }
      }
    }
  }

  Future<void> _toggleFollow(models.Page page) async {
    final followProvider = Provider.of<PageFollowProvider>(context, listen: false);
    
    try {
      final isFollowing = await followProvider.toggleFollow(page.id);
      
      if (mounted) {
        // Follower count is already updated by toggleFollow in the provider
        // No need to reload all pages - UI updates automatically via Consumer widgets
        
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
        final currentStatus = followProvider.isFollowing(page.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${currentStatus ? 'unfollow' : 'follow'}: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive utilities
    ResponsiveUtils.init(context);
    
    // Check if animations are initialized
    if (_animationController == null || 
        _bubblesFadeAnimation == null || 
        _contentFadeAnimation == null) {
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
          // Bubbles background - keep original position, only animate fade
          _buildBubbles(),
          
          // Main content - animated to slide up from bottom
          SafeArea(
            child: FadeTransition(
              opacity: _contentFadeAnimation!,
              child: SlideTransition(
                position: _contentSlideAnimation!,
                child: Column(
                  children: [
                    // Scrollable content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: ResponsiveUtils.dp(140)), // Space to push content below bubbles
                          
                          // Filter buttons - Club and District (Fixed, not scrollable)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.dp(35)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildFilterButton('Club Pages', 'club'),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFilterButton('District Pages', 'district'),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: ResponsiveUtils.dp(20)),
                          
                          // Scrollable content below fixed buttons
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Show cards based on selected filter
                                  _isLoadingPages
                                      ? const Center(child: CircularProgressIndicator())
                                      : _buildFilteredContent(),
                                  
                                  SizedBox(height: ResponsiveUtils.dp(80)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Back button - top left
          CustomBackButton(
            backgroundColor: Colors.black, // Dark area (image/shape background)
            iconSize: 24,
            navigateToHome: true,
          ),
          
          // "Pages" title - Figma: left: calc(16.67% + 2px), top: 48px
          Positioned(
            left: MediaQuery.of(context).size.width * 0.1667 + 2,
            top: 48,
            child: const Text(
              'Pages',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.52,
                height: 1.0,
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
                // Refresh pages list if page was created successfully
                if (result == true && mounted) {
                  _loadPages();
                }
                
                // Reload pages after creation
                if (result == true) {
                  _loadPages();
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
    );
  }

  Widget _buildBubbles() {
    // Exact Figma values: left:-239.41px, top:-332.78px, w:609.977px, h:570.222px
    // viewBox="0 0 610 571" with fade-in and slide-in animation
    return Positioned(
      left: -209.41,
      top: -292.78,
      child: FadeTransition(
        opacity: _bubblesFadeAnimation!,
        child: SlideTransition(
          position: _bubblesSlideAnimation!,
          child: SizedBox(
            width: 609.977,
            height: 570.222,
            child: CustomPaint(
              size: const Size(609.977, 570.222),
              painter: _BubblesPainter(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageCard(models.Page page, VoidCallback onFollowTap) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userLeoId = authProvider.user?.leoId;
    final isWebmaster = userLeoId != null && page.webmasterIds.contains(userLeoId);
    final isSuperAdmin = authProvider.isSuperAdmin;
    final canEdit = isWebmaster || isSuperAdmin;
    
    return Consumer<PageFollowProvider>(
      builder: (context, followProvider, child) {
        final isFollowing = followProvider.isFollowing(page.id);
        final followersCount = followProvider.getFollowerCount(page.id);
        final isToggling = followProvider.isToggling(page.id);
        
        // Use provider's follower count if available, otherwise use page's
        final displayCount = followersCount > 0 ? followersCount : page.followersCount;
        
        return Container(
      height: ResponsiveUtils.dp(117),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.dp(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Logo with gold border - Figma: left:15, top:14
          Positioned(
            left: ResponsiveUtils.dp(15),
            top: ResponsiveUtils.dp(14),
            child: Stack(
              children: [
                // Gold border background
                Container(
                  width: ResponsiveUtils.dp(91),
                  height: ResponsiveUtils.dp(91),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8F7902),
                    borderRadius: BorderRadius.circular(ResponsiveUtils.dp(18)),
                  ),
                ),
                // Image
                Positioned(
                  left: ResponsiveUtils.dp(5),
                  top: ResponsiveUtils.dp(5),
                  child: Container(
                    width: ResponsiveUtils.dp(81),
                    height: ResponsiveUtils.dp(81),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.dp(15)),
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
          
          // Page name - Figma: left:121, top:14
          Positioned(
            left: ResponsiveUtils.dp(121),
            top: ResponsiveUtils.dp(14),
            child: Text(
              page.name,
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: ResponsiveUtils.sp(16),
                fontWeight: FontWeight.w800,
                color: Colors.black,
                height: 31 / 16,
              ),
            ),
          ),
          
          // Followers count - Figma: left:121, top:33
          Positioned(
            left: ResponsiveUtils.dp(121),
            top: ResponsiveUtils.dp(33),
            child: Text(
              '$displayCount followers',
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: ResponsiveUtils.sp(10),
                fontWeight: FontWeight.w400,
                color: Colors.black,
                height: 31 / 10,
              ),
            ),
          ),
          
          // Follow/Unfollow button - Figma: left:121, top:66
          Positioned(
            left: ResponsiveUtils.dp(121),
            top: ResponsiveUtils.dp(66),
            child: GestureDetector(
              onTap: isToggling ? null : onFollowTap,
              child: Container(
                width: ResponsiveUtils.dp(196),
                height: ResponsiveUtils.dp(39),
                decoration: BoxDecoration(
                  color: isFollowing ? const Color(0xFF8F7902) : Colors.black,
                  borderRadius: BorderRadius.circular(ResponsiveUtils.dp(14)),
                ),
                alignment: Alignment.center,
                child: isToggling
                    ? SizedBox(
                        width: ResponsiveUtils.dp(20),
                        height: ResponsiveUtils.dp(20),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF3F3F3)),
                        ),
                      )
                    : Text(
                        isFollowing ? 'Unfollow' : 'Follow',
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: ResponsiveUtils.sp(15),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF3F3F3),
                          height: 31 / 15,
                        ),
                      ),
              ),
            ),
          ),
          
          // Edit and Delete buttons for webmasters/super admin (top right) - Modern Design
          if (canEdit)
            Positioned(
              right: ResponsiveUtils.dp(8),
              top: ResponsiveUtils.dp(8),
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
                          _loadPages(); // Reload pages after edit
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
                        onTap: () => _showDeleteDialog(page),
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
            ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildFilterButton(String label, String filterType) {
    final isSelected = _selectedFilter == filterType;
    
    // Choose SVG asset based on filter type
    String svgAsset;
    if (filterType == 'club') {
      svgAsset = 'assets/images/icons/club_pages_icon.svg';
    } else {
      svgAsset = 'assets/images/icons/district_pages_icon.svg';
    }
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = filterType;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // SVG Icon above text - circular background for district icon
              filterType == 'district'
                  ? ClipOval(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFF8F7902).withOpacity(0.1) // Light gold background for selected
                              : Colors.grey[200], // Light gray background for unselected
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            svgAsset,
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              isSelected 
                                  ? const Color(0xFF8F7902) // Dark gold for selected (replaces black)
                                  : Colors.grey[700]!, // Dark gray for unselected
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SvgPicture.asset(
                      svgAsset,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        isSelected 
                            ? const Color(0xFF8F7902) // Dark gold for selected (replaces black)
                            : Colors.grey[700]!, // Dark gray for unselected
                        BlendMode.srcIn,
                      ),
                    ),
              const SizedBox(height: 6),
              // Text label
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected 
                      ? Colors.black // Dark for selected
                      : Colors.grey[700], // Gray for unselected
                ),
              ),
              const SizedBox(height: 4),
              // Underline indicator for selected tab
              SizedBox(
                width: 100, // Fixed container width
                child: Align(
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: 2,
                    width: isSelected ? 80 : 0, // Animate width within fixed container
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFF8F7902) // Gold underline
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilteredContent() {
    final pages = _selectedFilter == 'club' ? _clubPages : _districtPages;
    final emptyMessage = _selectedFilter == 'club' 
        ? 'No club pages yet' 
        : 'No district pages yet';
    
    if (pages.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.dp(35)),
        child: Center(
          child: Text(
            emptyMessage,
            style: TextStyle(
              fontSize: ResponsiveUtils.sp(16),
              color: Colors.grey,
              fontFamily: 'Nunito Sans',
            ),
          ),
        ),
      );
    }
    
    // Show all pages as scrollable list
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.dp(35)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: pages.length,
        separatorBuilder: (_, __) => SizedBox(height: ResponsiveUtils.dp(11)),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PageDetailScreen(
                    page: pages[index],
                  ),
                ),
              );
            },
            child: _buildPageCard(
              pages[index],
              () => _toggleFollow(pages[index]),
            ),
          );
        },
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
