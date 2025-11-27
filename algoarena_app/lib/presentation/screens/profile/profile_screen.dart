import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/app_bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _authRepository = AuthRepository();
  final ScrollController _scrollController = ScrollController();
  
  User? _user;
  bool _isLoading = true;
  double _scrollOffset = 0.0;
  
  late AnimationController _headerController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeIn),
    );
    
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    
    _loadProfile();
  }
  
  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _authRepository.getCurrentUser();
      
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
        _headerController.forward();
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

  Future<void> _logout() async {
    try {
      await _authRepository.logout();
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
      return Scaffold(
        backgroundColor: AppColors.white,
        body: const Center(
          child: Text('Failed to load profile'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Animated Decorative bubbles background with parallax - Black bubble
          Positioned(
            left: -200 + (_scrollOffset * 0.1),
            top: -250 + (_scrollOffset * 0.15),
            child: Transform.rotate(
              angle: 240 * 3.14159 / 180,
              child: Image.asset(
                'assets/images/profile/bubble01.png',
                width: 400,
                height: 450,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Gold/Yellow bubble
          Positioned(
            left: -350 - (_scrollOffset * 0.08),
            top: -180 + (_scrollOffset * 0.2),
            child: Transform.rotate(
              angle: 112 * 3.14159 / 180,
              child: Image.asset(
                'assets/images/profile/bubble02.png',
                width: 380,
                height: 450,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          // Main content with animated scroll
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated Header with back button and title
                  SlideTransition(
                    position: _headerSlideAnimation,
                    child: FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: Transform.scale(
                        scale: 1.0 - (_scrollOffset * 0.001).clamp(0.0, 0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 50,
                                  height: 53,
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    'assets/images/profile/back_arrow.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 9),
                              const Text(
                                'Profile',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 50,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                  letterSpacing: -0.52,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Animated Profile avatar with verified badge
                  FadeTransition(
                    opacity: _headerFadeAnimation,
                    child: Transform.scale(
                      scale: 1.0 - (_scrollOffset * 0.0008).clamp(0.0, 0.25),
                      child: Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 127,
                              height: 127,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFFD700).withOpacity(0.5),
                                  width: 5,
                                ),
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
                            // Verified badge
                            if (_user!.isVerified)
                              Positioned(
                                bottom: -10,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF15FF00),
                                      border: Border.all(color: const Color(0xFF0D9700), width: 3),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Verified',
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Form fields
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name field
                        _buildFieldLabel('Name'),
                        const SizedBox(height: 8),
                        _buildTextField(_user!.fullName),
                        
                        const SizedBox(height: 20),
                        
                        // Leo ID field with verify button
                        _buildFieldLabel('Leo ID'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 7,
                              child: _buildTextField('12345'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: _buildVerifyButton(),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Role field
                        _buildFieldLabel('Role'),
                        const SizedBox(height: 8),
                        _buildTextField(_user!.role == 'admin' ? 'Administrator' : 'Member'),
                        
                        const SizedBox(height: 20),
                        
                        // Email field
                        _buildFieldLabel('email'),
                        const SizedBox(height: 8),
                        _buildTextField(_user!.email),
                        
                        const SizedBox(height: 40),
                        
                        // Edit Profile button
                        SizedBox(
                          width: double.infinity,
                          height: 61,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to edit profile
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFF3F3F3),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Logout button
                        SizedBox(
                          width: double.infinity,
                          height: 61,
                          child: ElevatedButton(
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(0, 0, 0, 0.27),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Nunito Sans',
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: Color(0xFF202020),
      ),
    );
  }

  Widget _buildTextField(String value) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.05),
        borderRadius: BorderRadius.circular(60),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: _user!.isVerified 
            ? const Color.fromRGBO(28, 196, 6, 0.35)
            : const Color.fromRGBO(0, 0, 0, 0.22),
        borderRadius: BorderRadius.circular(60),
      ),
      child: Center(
        child: Text(
          _user!.isVerified ? 'Verified' : 'Verify',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
      ),
    );
  }
}
