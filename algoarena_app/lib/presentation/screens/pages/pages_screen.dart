import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/colors.dart';
import '../../../data/models/club.dart';
import '../../widgets/loading_indicator.dart';

class PagesScreen extends StatefulWidget {
  const PagesScreen({Key? key}) : super(key: key);

  @override
  State<PagesScreen> createState() => _PagesScreenState();
}

class _PagesScreenState extends State<PagesScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<Club> _clubs = [];
  late AnimationController _bubblesController;
  late AnimationController _listController;
  late AnimationController _headerController;

  @override
  void initState() {
    super.initState();
    
    // Floating bubbles animation
    _bubblesController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
    
    // List items stagger animation
    _listController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Header animation
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _headerController.forward();
    _loadClubs();
  }
  
  @override
  void dispose() {
    _bubblesController.dispose();
    _listController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _loadClubs() async {
    // Mock data for now
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        final now = DateTime.now();
        _clubs = [
          Club(
            id: '1',
            name: 'Leo Club of Katuwawala',
            logo: 'assets/images/pages/club1.png',
            description: 'Leo Club serving Katuwawala area',
            districtId: 'd1',
            members: [],
            adminId: 'a1',
            location: Location(country: 'Sri Lanka', city: 'Katuwawala'),
            createdAt: now,
            updatedAt: now,
            mutualCount: 97,
            isFollowing: false,
          ),
          Club(
            id: '2',
            name: 'Leo Club of Colombo',
            logo: 'assets/images/pages/club2.png',
            description: 'Leo Club serving Colombo area',
            districtId: 'd1',
            members: [],
            adminId: 'a1',
            location: Location(country: 'Sri Lanka', city: 'Colombo'),
            createdAt: now,
            updatedAt: now,
            mutualCount: 102,
            isFollowing: false,
          ),
          Club(
            id: '3',
            name: 'Leo Club of University of Moratuwa',
            logo: 'assets/images/pages/club3.png',
            description: 'Leo Club at University of Moratuwa',
            districtId: 'd1',
            members: [],
            adminId: 'a1',
            location: Location(country: 'Sri Lanka', city: 'Moratuwa'),
            createdAt: now,
            updatedAt: now,
            mutualCount: 97,
            isFollowing: false,
          ),
          Club(
            id: '4',
            name: 'Leo Club of Gampaha',
            logo: 'assets/images/pages/club1.png',
            description: 'Leo Club serving Gampaha area',
            districtId: 'd1',
            members: [],
            adminId: 'a1',
            location: Location(country: 'Sri Lanka', city: 'Gampaha'),
            createdAt: now,
            updatedAt: now,
            mutualCount: 97,
            isFollowing: false,
          ),
          Club(
            id: '5',
            name: 'Leo Club of Kandy',
            logo: 'assets/images/pages/club1.png',
            description: 'Leo Club serving Kandy area',
            districtId: 'd1',
            members: [],
            adminId: 'a1',
            location: Location(country: 'Sri Lanka', city: 'Kandy'),
            createdAt: now,
            updatedAt: now,
            mutualCount: 85,
            isFollowing: false,
          ),
        ];
        _isLoading = false;
      });
      
      // Start list animation after data loaded
      _listController.forward();
    }
  }

  void _toggleFollow(String clubId) {
    setState(() {
      final index = _clubs.indexWhere((c) => c.id == clubId);
      if (index != -1) {
        final newFollowingState = !(_clubs[index].isFollowing ?? false);
        _clubs[index] = _clubs[index].copyWith(
          isFollowing: newFollowingState,
        );
        
        // Show snackbar with animation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newFollowingState
                  ? 'Following ${_clubs[index].name}'
                  : 'Unfollowed ${_clubs[index].name}',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: newFollowingState
                ? AppColors.success
                : AppColors.textSecondary,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Animated Decorative bubbles background - Figma 337:657
          AnimatedBuilder(
            animation: _bubblesController,
            builder: (context, child) {
              return Stack(
                children: [
                  // Yellow/gold bubble - floating animation
                  Positioned(
                    left: -189.94 + math.sin(_bubblesController.value * 2 * math.pi) * 25,
                    top: -336.1 + math.cos(_bubblesController.value * 2 * math.pi * 0.8) * 20,
                    child: Transform.rotate(
                      angle: _bubblesController.value * 2 * math.pi * 0.4,
                      child: Container(
                        width: 570.671,
                        height: 579.191,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFFD700).withOpacity(0.22),
                              const Color(0xFFFFD700).withOpacity(0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Secondary bubble - slower rotation
                  Positioned(
                    right: -120,
                    bottom: 100 + math.sin(_bubblesController.value * 2 * math.pi * 0.6) * 30,
                    child: Transform.rotate(
                      angle: -_bubblesController.value * 2 * math.pi * 0.2,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated Header with back button and title
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _headerController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
                    child: Row(
                      children: [
                        // Material back button with ripple
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 50,
                              height: 53,
                              padding: const EdgeInsets.all(12),
                              child: const Icon(
                                Icons.arrow_back,
                                size: 28,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        // Title with shadow effect
                        Stack(
                          children: [
                            // White shadow layer
                            Text(
                              'Pages',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 50,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withOpacity(0.8),
                                letterSpacing: -0.52,
                              ),
                            ),
                            // Black foreground layer
                            Text(
                              'Pages',
                              style: const TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 50,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                                letterSpacing: -0.52,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // "Club Pages :" section title with animation
                FadeTransition(
                  opacity: _headerController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-0.3, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _headerController,
                      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                    )),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 35),
                      child: Text(
                        'Club Pages :',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                          height: 32 / 26,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 11),
                
                // Scrollable club list with staggered animations
                Expanded(
                  child: _isLoading
                      ? const LoadingIndicator()
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          itemCount: _clubs.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 11),
                          itemBuilder: (context, index) {
                            final club = _clubs[index];
                            return _buildAnimatedClubCard(club, index);
                          },
                        ),
                ),
                
                // Bottom indicator
                Center(
                  child: Container(
                    width: 145.848,
                    height: 5.442,
                    margin: const EdgeInsets.only(bottom: 12, top: 8),
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
    );
  }

  Widget _buildAnimatedClubCard(Club club, int index) {
    // Staggered animation for each card
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _listController,
        curve: Interval(
          index * 0.1,
          index * 0.1 + 0.5,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    
    // Check if club name needs two lines
    final isTwoLines = club.name.length > 25;
    final cardHeight = isTwoLines ? 134.0 : 117.0;
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - animation.value), 0),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to club detail
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening ${club.name}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: cardHeight,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                // Club logo with gold border and hero animation
                Positioned(
                  left: 15,
                  top: 14,
                  child: Hero(
                    tag: 'club_logo_${club.id}',
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
                        // Club image
                        Positioned(
                          left: 5,
                          top: 5,
                          child: Container(
                            width: 81,
                            height: 81,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: AssetImage(club.imageUrl ?? 'assets/images/pages/club1.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Club info and button
                Positioned(
                  left: 121,
                  top: 14,
                  right: 15,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Club name
                      if (isTwoLines) ...[
                        Text(
                          club.name.contains(' of ') ? club.name.split(' of ')[0] + ' of' : club.name,
                          style: const TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                            height: 1.94,
                          ),
                        ),
                        if (club.name.contains(' of '))
                          Text(
                            club.name.split(' of ')[1],
                            style: const TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                              height: 1.94,
                            ),
                          ),
                      ] else
                        Text(
                          club.name,
                          style: const TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                            height: 1.94,
                          ),
                        ),
                      
                      const SizedBox(height: 3),
                      
                      // Mutual count
                      Text(
                        '${club.mutualCount ?? 0} mutuals',
                        style: const TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black,
                          height: 3.1,
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Follow/Unfollow button with Material ripple
                      Material(
                        color: (club.isFollowing ?? false)
                            ? const Color(0xFF8F7902)
                            : AppColors.black,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () => _toggleFollow(club.id),
                          borderRadius: BorderRadius.circular(14),
                          splashColor: Colors.white.withOpacity(0.3),
                          highlightColor: Colors.white.withOpacity(0.1),
                          child: Container(
                            width: 196,
                            height: 39,
                            alignment: Alignment.center,
                            child: Text(
                              (club.isFollowing ?? false) ? 'Following' : 'Follow',
                              style: const TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFF3F3F3),
                                height: 2.07,
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
          ),
        ),
      ),
    );
  }
}
