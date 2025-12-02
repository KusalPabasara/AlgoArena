import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/custom_back_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  
  static final GlobalKey<_ProfileScreenState> globalKey = GlobalKey<_ProfileScreenState>();

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _authRepository = AuthRepository();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _leoIdController = TextEditingController();
  
  User? _user;
  bool _isLoading = true;
  bool _isVerifying = false;
  
  late AnimationController _animationController;
  late Animation<Offset> _bubblesSlideAnimation;
  late Animation<Offset> _bottomYellowBubbleSlideAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _bubblesFadeAnimation;
  late Animation<double> _contentFadeAnimation;
  DateTime? _lastAnimationTime;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Bubbles animation - coming from outside (top-left)
    _bubblesSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, -0.5), // Start from top-left outside
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Bottom yellow bubble animation - coming from right outside
    _bottomYellowBubbleSlideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0), // Start from right outside
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
    
    // Content animation - coming from bottom
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    _loadProfile();
  }
  
  // Public method to restart animation (called from MainScreen)
  void restartAnimation() {
    if (!mounted) return;
    
    final now = DateTime.now();
    if (_lastAnimationTime == null || 
        now.difference(_lastAnimationTime!).inMilliseconds > 200) {
      _lastAnimationTime = now;
      
      if (_animationController.isAnimating) {
        _animationController.stop();
      }
      
      _animationController.reset();
      _animationController.forward();
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _leoIdController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      // First check if user is available from AuthProvider (for Super Admin)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      User? user = authProvider.user;
      
      // If not in AuthProvider, try to get from API
      if (user == null) {
        user = await _authRepository.getCurrentUser();
      }
      
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
          // Pre-fill Leo ID if already set
          if (user?.leoClubId != null && user!.leoClubId!.isNotEmpty) {
            _leoIdController.text = user.leoClubId!;
          }
        });
        // Don't start animation here - wait for restartAnimation() call
      }
    } catch (e) {
      // If API fails, still try to use AuthProvider user (for Super Admin)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null && mounted) {
        setState(() {
          _user = authProvider.user;
          _isLoading = false;
        });
        // Don't start animation here - wait for restartAnimation() call
        return;
      }
      
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

  // Verify Leo ID
  Future<void> _verifyLeoId() async {
    final leoId = _leoIdController.text.trim();
    
    if (leoId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Leo ID'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Basic Leo ID validation (e.g., must be at least 4 characters)
    if (leoId.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leo ID must be at least 4 characters'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() => _isVerifying = true);
    
    try {
      // Call backend to verify and save Leo ID
      final verifiedUser = await _authRepository.verifyLeoId(leoId);
      
      // Update local user state with verified user from backend
      setState(() {
        _user = verifiedUser;
        _isVerifying = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Leo ID verified successfully! You can now create posts.'),
          backgroundColor: Color(0xFF1CC406),
        ),
      );
    } catch (e) {
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _logout() async {
    try {
      // Use AuthProvider for logout (handles both Super Admin and regular users)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
    }

    if (_user == null) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Text('Failed to load profile'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Top Figma Bubbles - animated to slide in from top-left
          Positioned(
            left: -249.4,
            top: -294.78,
            child: FadeTransition(
              opacity: _bubblesFadeAnimation,
              child: SlideTransition(
                position: _bubblesSlideAnimation,
                child: SizedBox(
                  width: 816.339,
                  height: 1238.97,
                  child: CustomPaint(
                    painter: _TopFigmaBubblesPainter(),
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom Yellow Bubble - animated to slide in from right
          Positioned(
            left: -249.4,
            top: -294.78,
            child: FadeTransition(
              opacity: _bubblesFadeAnimation,
              child: SlideTransition(
                position: _bottomYellowBubbleSlideAnimation,
                child: SizedBox(
                  width: 816.339,
                  height: 1238.97,
                  child: CustomPaint(
                    painter: _BottomYellowBubblePainter(),
                  ),
                ),
              ),
            ),
          ),
          
          // Main content - animated to slide up from bottom
          Positioned(
            left: 0,
            right: 0,
            top: ResponsiveUtils.bh(155),
            bottom: 0,
            child: FadeTransition(
              opacity: _contentFadeAnimation,
              child: SlideTransition(
                position: _contentSlideAnimation,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: ResponsiveUtils.dp(20)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(35)),
                      child: Container(
                        width: ResponsiveUtils.dp(375),
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height - ResponsiveUtils.bh(155) - MediaQuery.of(context).padding.bottom - ResponsiveUtils.dp(40),
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(ResponsiveUtils.r(35)),
                        ),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUtils.spacingM + ResponsiveUtils.dp(4),
                                vertical: ResponsiveUtils.spacingM - ResponsiveUtils.dp(6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: ResponsiveUtils.dp(20)),
                  
                                  // Profile avatar with gold border - Figma: 127.2px size, border #8F7902 with shadow
                                  Center(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: ResponsiveUtils.dp(127.2),
                                          height: ResponsiveUtils.dp(127.2),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF8F7902), // Figma: #8F7902 dark gold
                                              width: ResponsiveUtils.dp(3),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.16),
                                                blurRadius: ResponsiveUtils.dp(5),
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: ClipOval(
                                            child: _user!.profilePhoto != null
                                                ? CachedNetworkImage(
                                                    imageUrl: _user!.profilePhoto!,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) => const CircularProgressIndicator(),
                                                    errorWidget: (context, url, error) => Image.asset(
                                                      'assets/images/profile/avatar_artist.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    'assets/images/profile/avatar_artist.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                        // Verified badge below avatar
                                        if (_user!.isVerified) ...[
                                          SizedBox(height: ResponsiveUtils.dp(12)),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: ResponsiveUtils.dp(16),
                                              vertical: ResponsiveUtils.dp(6),
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF15FF00).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(ResponsiveUtils.r(20)),
                                              border: Border.all(
                                                color: const Color(0xFF0D9700),
                                                width: ResponsiveUtils.dp(1.5),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.verified,
                                                  color: const Color(0xFF0D9700),
                                                  size: ResponsiveUtils.dp(18),
                                                ),
                                                SizedBox(width: ResponsiveUtils.dp(6)),
                                                Text(
                                                  'Verified Leo',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: ResponsiveUtils.bodySmall,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(0xFF0D9700),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(height: ResponsiveUtils.dp(35)),
                                    
                                  // Form fields - Figma: horizontal padding ~8.33% = 33.5px for 402px width
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Name field - Figma: top: 252px
                                      _buildFieldLabel('Name'),
                                      SizedBox(height: ResponsiveUtils.dp(8)),
                                      _buildTextField(_user!.fullName),
                                      
                                      SizedBox(height: ResponsiveUtils.dp(20)),
                                      
                                      // Leo ID field with verify button - Figma: top: 345px
                                      _buildFieldLabel('Leo ID'),
                                      SizedBox(height: ResponsiveUtils.dp(8)),
                                      Row(
                                        children: [
                                          // Leo ID input - Figma: 226px wide
                                          Expanded(
                                            flex: 7,
                                            child: _buildLeoIdField(),
                                          ),
                                          SizedBox(width: ResponsiveUtils.dp(8)),
                                          // Verify button - Figma: 98px wide, bg: rgba(0,0,0,0.22)
                                          Expanded(
                                            flex: 3,
                                            child: _buildVerifyButton(),
                                          ),
                                        ],
                                      ),
                                      
                                      SizedBox(height: ResponsiveUtils.dp(20)),
                                      
                                      // Role field - Figma: top: 438px
                                      _buildFieldLabel('Role'),
                                      SizedBox(height: ResponsiveUtils.dp(8)),
                                      _buildTextField(_user!.displayRole),
                                      
                                      SizedBox(height: ResponsiveUtils.dp(20)),
                                      
                                      // Email field - Figma: top: 531px
                                      _buildFieldLabel('email'),
                                      SizedBox(height: ResponsiveUtils.dp(8)),
                                      _buildTextField(_user!.email),
                                      
                                      SizedBox(height: ResponsiveUtils.dp(40)),
                                      
                                      // Edit Profile button - Figma: top: 624px, h: 61px, bg: black, rounded: 20px
                                      SizedBox(
                                        width: double.infinity,
                                        height: ResponsiveUtils.dp(61),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Navigate to edit profile
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(ResponsiveUtils.r(20)),
                                            ),
                                            elevation: 0,
                                          ),
                                          // Figma: Nunito Sans Regular 20px, color: #F3F3F3
                                          child: Text(
                                            'Edit Profile',
                                            style: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              fontSize: ResponsiveUtils.dp(20),
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFFF3F3F3),
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      SizedBox(height: ResponsiveUtils.dp(16)),
                                      
                                      // Logout button - Figma: top: 706px, h: 61px, bg: rgba(0,0,0,0.27), rounded: 20px
                                      SizedBox(
                                        width: double.infinity,
                                        height: ResponsiveUtils.dp(61),
                                        child: ElevatedButton(
                                          onPressed: _logout,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromRGBO(0, 0, 0, 0.27),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(ResponsiveUtils.r(20)),
                                            ),
                                            elevation: 0,
                                          ),
                                          // Figma: Nunito Sans Bold 20px, color: black
                                          child: Text(
                                            'Logout',
                                            style: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              fontSize: ResponsiveUtils.dp(20),
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      SizedBox(height: ResponsiveUtils.dp(100)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
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

          // "Profile" title - Figma: left: calc(16.67% + 2px), top: 48px
          Positioned(
            left: MediaQuery.of(context).size.width * 0.1667 + ResponsiveUtils.dp(2),
            top: ResponsiveUtils.bh(48),
            child: Text(
              'Profile',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: ResponsiveUtils.dp(50),
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -ResponsiveUtils.dp(0.52),
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Figma: Nunito Sans Light 14px, color: #202020
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Nunito Sans',
        fontSize: ResponsiveUtils.dp(14),
        fontWeight: FontWeight.w300,
        color: const Color(0xFF202020),
      ),
    );
  }

  // Figma: h: 52px, bg: rgba(0,0,0,0.05), rounded: 59.115px, px: 19.705px
  // Font: Poppins Medium 14px
  Widget _buildTextField(String value, {bool isPlaceholder = false}) {
    return Container(
      height: ResponsiveUtils.dp(52),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.dp(19.7),
        vertical: ResponsiveUtils.dp(15.76),
      ),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.05),
        borderRadius: BorderRadius.circular(ResponsiveUtils.dp(59.115)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: ResponsiveUtils.dp(14),
            fontWeight: FontWeight.w500,
            // Figma: placeholder color rgba(0,0,0,0.4), regular color black
            color: isPlaceholder 
                ? const Color.fromRGBO(0, 0, 0, 0.4)
                : Colors.black,
          ),
        ),
      ),
    );
  }

  // Editable Leo ID field
  Widget _buildLeoIdField() {
    return Container(
      height: ResponsiveUtils.dp(52),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.dp(19.7),
      ),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.05),
        borderRadius: BorderRadius.circular(ResponsiveUtils.dp(59.115)),
      ),
      child: TextField(
        controller: _leoIdController,
        enabled: !_user!.isVerified, // Disable if already verified
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: ResponsiveUtils.dp(14),
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Enter your Leo ID',
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: ResponsiveUtils.dp(14),
            fontWeight: FontWeight.w500,
            color: const Color.fromRGBO(0, 0, 0, 0.4),
          ),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: ResponsiveUtils.dp(14),
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  // Figma: h: 52px, bg: rgba(0,0,0,0.22), rounded: 59.115px
  // Font: Poppins Medium 14px, text-center
  Widget _buildVerifyButton() {
    final isVerified = _user!.isVerified;
    
    return GestureDetector(
      onTap: isVerified ? null : _verifyLeoId,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isVerified 
              ? const Color.fromRGBO(28, 196, 6, 0.35)
              : const Color.fromRGBO(0, 0, 0, 0.22),
          borderRadius: BorderRadius.circular(59.115),
        ),
        child: Center(
          child: _isVerifying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black54,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isVerified) ...[
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Color(0xFF0D9700),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      isVerified ? 'Verified' : 'Verify',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isVerified ? const Color(0xFF0D9700) : Colors.black,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Custom painter for top Figma bubbles (black and yellow middle) - exactly matching Profile.tsx SVG paths
class _TopFigmaBubblesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / 817;
    final double scaleY = size.height / 1239;
    
    // Yellow bubble 02 (middle) - Figma path p193cf500
    // fill: #FFD700
    final yellowPaint2 = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    
    final yellowPath2 = Path();
    yellowPath2.moveTo(542.619 * scaleX, 396.689 * scaleY);
    yellowPath2.cubicTo(
      627.229 * scaleX, 533.807 * scaleY,
      383.541 * scaleX, 549.673 * scaleY,
      280.392 * scaleX, 507.998 * scaleY,
    );
    yellowPath2.cubicTo(
      177.243 * scaleX, 466.323 * scaleY,
      127.408 * scaleX, 348.92 * scaleY,
      169.083 * scaleX, 245.771 * scaleY,
    );
    yellowPath2.cubicTo(
      210.758 * scaleX, 142.622 * scaleY,
      319.052 * scaleX, 130.067 * scaleY,
      416.119 * scaleX, 160.551 * scaleY,
    );
    yellowPath2.cubicTo(
      513.186 * scaleX, 191.034 * scaleY,
      458.009 * scaleX, 259.571 * scaleY,
      542.619 * scaleX, 396.689 * scaleY,
    );
    yellowPath2.close();
    canvas.drawPath(yellowPath2, yellowPaint2);
    
    // Black bubble 01 (top) - Figma path p38579800
    // fill: black
    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final blackPath = Path();
    blackPath.moveTo(135.167 * scaleX, 375.884 * scaleY);
    blackPath.cubicTo(
      -24.975 * scaleX, 358.14 * scaleY,
      112.552 * scaleX, 156.343 * scaleY,
      208.897 * scaleX, 100.718 * scaleY,
    );
    blackPath.cubicTo(
      305.243 * scaleX, 45.093 * scaleY,
      428.439 * scaleX, 78.1032 * scaleY,
      484.064 * scaleX, 174.448 * scaleY,
    );
    blackPath.cubicTo(
      539.689 * scaleX, 270.794 * scaleY,
      506.678 * scaleX, 393.99 * scaleY,
      410.333 * scaleX, 449.615 * scaleY,
    );
    blackPath.cubicTo(
      313.988 * scaleX, 505.24 * scaleY,
      295.309 * scaleX, 393.629 * scaleY,
      135.167 * scaleX, 375.884 * scaleY,
    );
    blackPath.close();
    canvas.drawPath(blackPath, blackPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for bottom yellow bubble - exactly matching Profile.tsx SVG path
class _BottomYellowBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / 817;
    final double scaleY = size.height / 1239;
    
    // Yellow bubble 04 (bottom) - Figma path p3141de00
    // fill: #FFD700
    final yellowPaint1 = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    
    final yellowPath1 = Path();
    yellowPath1.moveTo(776.561 * scaleX, 1048.32 * scaleY);
    yellowPath1.cubicTo(
      906.376 * scaleX, 1138.65 * scaleY,
      686.375 * scaleX, 1238.97 * scaleY,
      575.125 * scaleX, 1238.97 * scaleY,
    );
    yellowPath1.cubicTo(
      463.876 * scaleX, 1238.97 * scaleY,
      373.69 * scaleX, 1153.61 * scaleY,
      373.69 * scaleX, 1048.32 * scaleY,
    );
    yellowPath1.cubicTo(
      373.69 * scaleX, 943.027 * scaleY,
      469.395 * scaleX, 893.614 * scaleY,
      570.814 * scaleX, 885.95 * scaleY,
    );
    yellowPath1.cubicTo(
      672.232 * scaleX, 878.286 * scaleY,
      646.747 * scaleX, 957.992 * scaleY,
      776.561 * scaleX, 1048.32 * scaleY,
    );
    yellowPath1.close();
    canvas.drawPath(yellowPath1, yellowPaint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
