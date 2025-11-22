import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../../core/utils/animation_lifecycle_mixin.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin, AnimationLifecycleMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  late AnimationController _searchBarController;
  late AnimationController _bubbleController;
  late Animation<double> _searchBarAnimation;
  late Animation<double> _bubbleAnimation;
  
  @override
  List<AnimationController> get animationControllers => [
    _bubbleController,
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Search bar slide animation
    _searchBarController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _searchBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchBarController, curve: Curves.easeOut),
    );
    
    // Background bubble float animation
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _bubbleAnimation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOut),
    );
    
    _searchBarController.forward();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchBarController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Animated Background Bubbles
          AnimatedBuilder(
            animation: _bubbleAnimation,
            builder: (context, child) {
              return Positioned(
                right: -100,
                top: 50 + _bubbleAnimation.value,
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _bubbleAnimation,
            builder: (context, child) {
              return Positioned(
                left: -80,
                bottom: 100 - _bubbleAnimation.value * 0.8,
                child: Opacity(
                  opacity: 0.08,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.15),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // App Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        AppStrings.search,
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Animated Search bar
                FadeTransition(
                  opacity: _searchBarAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.3),
                      end: Offset.zero,
                    ).animate(_searchBarController),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: AppStrings.searchUsers,
                            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Search tabs
                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          indicatorColor: AppColors.primary,
                          labelStyle: const TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          tabs: const [
                            Tab(text: 'Users'),
                            Tab(text: 'Clubs'),
                            Tab(text: 'Districts'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildUsersList(),
                              _buildClubsList(),
                              _buildDistrictsList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _buildUsersList() {
    if (_searchQuery.isEmpty) {
      return _AnimatedEmptyState(
        icon: Icons.people_outline,
        message: 'Search for users',
      );
    }

    // Show animated results
    return _AnimatedSearchResults(
      query: _searchQuery,
      resultType: 'users',
    );
  }

  Widget _buildClubsList() {
    if (_searchQuery.isEmpty) {
      return _AnimatedEmptyState(
        icon: Icons.groups_outlined,
        message: 'Search for clubs',
      );
    }

    return _AnimatedSearchResults(
      query: _searchQuery,
      resultType: 'clubs',
    );
  }

  Widget _buildDistrictsList() {
    if (_searchQuery.isEmpty) {
      return _AnimatedEmptyState(
        icon: Icons.location_city_outlined,
        message: 'Search for districts',
      );
    }

    return _AnimatedSearchResults(
      query: _searchQuery,
      resultType: 'districts',
    );
  }
}

/// Animated Empty State Widget
class _AnimatedEmptyState extends StatefulWidget {
  final IconData icon;
  final String message;

  const _AnimatedEmptyState({
    required this.icon,
    required this.message,
  });

  @override
  State<_AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<_AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 64,
                color: AppColors.disabled,
              ),
              const SizedBox(height: 16),
              Text(
                widget.message,
                style: const TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated Search Results Widget
class _AnimatedSearchResults extends StatelessWidget {
  final String query;
  final String resultType;

  const _AnimatedSearchResults({
    required this.query,
    required this.resultType,
  });

  @override
  Widget build(BuildContext context) {
    // Simulated results - in production, this would fetch from API
    final List<String> mockResults = List.generate(
      5,
      (index) => '$resultType result ${index + 1} for "$query"',
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockResults.length,
      itemBuilder: (context, index) {
        return _AnimatedResultItem(
          title: mockResults[index],
          index: index,
        );
      },
    );
  }
}

/// Animated Result Item with staggered entrance
class _AnimatedResultItem extends StatefulWidget {
  final String title;
  final int index;

  const _AnimatedResultItem({
    required this.title,
    required this.index,
  });

  @override
  State<_AnimatedResultItem> createState() => _AnimatedResultItemState();
}

class _AnimatedResultItemState extends State<_AnimatedResultItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Staggered animation
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


