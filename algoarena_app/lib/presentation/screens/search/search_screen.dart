import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/custom_back_button.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/models/page.dart' as models;
import '../../../data/models/post.dart' as post_models;
import '../pages/page_detail_screen.dart';

/// Search Screen - Exact match to Figma search/src/imports/Search.tsx
/// Design specs:
/// - Back button: left:10, top:50, 50x53px
/// - Search field: iOS style with magnifying glass, "Search" placeholder
/// - Recents section with 5 items (X to remove each)
/// - Image grid: 112px cells in mosaic layout
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  
  static final GlobalKey<_SearchScreenState> globalKey = GlobalKey<_SearchScreenState>();

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _bubblesSlideAnimation;
  late Animation<double> _bubblesFadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  
  final _pageRepository = PageRepository();
  final _postRepository = PostRepository();
  List<models.Page> _allPages = [];
  bool _isLoadingPages = true;
  
  // Posts with images for the grid
  List<post_models.Post> _postsWithImages = [];
  bool _isLoadingPosts = true;

  @override
  void initState() {
    super.initState();
    print('🚀 SearchScreen.initState: Called');
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    print('🚀 SearchScreen.initState: Animation controller initialized');
    
    // Bubbles animation - coming from outside (top-left)
    _bubblesSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, -0.5),
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
    print('🚀 SearchScreen.initState: Animations initialized');
    
    // Load all pages and posts from backend
    // Use Future.microtask to ensure initState completes first
    print('🚀 SearchScreen.initState: Scheduling _loadPages() and _loadPosts()');
    Future.microtask(() {
      print('🔄 SearchScreen.initState: About to call _loadPages() and _loadPosts()');
      _loadPages().catchError((error, stackTrace) {
        print('❌ SearchScreen.initState: Error in _loadPages(): $error');
        print('📚 SearchScreen.initState: Stack trace: $stackTrace');
        if (mounted) {
          setState(() {
            _isLoadingPages = false;
          });
          print('✅ SearchScreen.initState: Set loading state to false after error');
        }
      });
      _loadPosts().catchError((error, stackTrace) {
        print('❌ SearchScreen.initState: Error in _loadPosts(): $error');
        if (mounted) {
          setState(() {
            _isLoadingPosts = false;
          });
        }
      });
    });
    
    print('🚀 SearchScreen.initState: Completed');
    // Don't start animation immediately - wait for restartAnimation() call
    // This ensures bubbles are hidden initially
  }
  
  Future<void> _loadPages() async {
    print('🔄 _loadPages: Starting to load pages for search...');
    print('🔄 _loadPages: Current state - _isLoadingPages: $_isLoadingPages, _allPages.length: ${_allPages.length}');
    
    try {
      // Add timeout to prevent hanging
      print('🔄 _loadPages: Calling getAllPages()...');
      final pages = await _pageRepository.getAllPages()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              print('⏱️ _loadPages: Timeout loading pages');
              return <models.Page>[];
            },
          );
      
      print('📦 _loadPages: Received ${pages.length} pages from repository');
      if (mounted) {
        setState(() {
          _allPages = pages;
          _isLoadingPages = false;
        });
        print('✅ _loadPages: Loaded ${pages.length} pages for search. Loading state: $_isLoadingPages');
        if (pages.isNotEmpty) {
          print('📋 _loadPages: Page names: ${pages.map((p) => p.name).join(", ")}');
        } else {
          print('⚠️ _loadPages: No pages loaded - this might be an authentication or API issue');
        }
      } else {
        print('⚠️ _loadPages: Widget not mounted, skipping setState');
      }
    } catch (e, stackTrace) {
      print('❌ _loadPages: Error loading pages for search: $e');
      print('📚 _loadPages: Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _allPages = [];
          _isLoadingPages = false;
        });
        print('✅ _loadPages: Set loading state to false after error');
      } else {
        print('⚠️ _loadPages: Widget not mounted, cannot set state');
      }
    }
  }
  
  Future<void> _loadPosts() async {
    print('🔄 _loadPosts: Starting to load posts with images...');
    try {
      // Fetch feed posts
      final posts = await _postRepository.getFeed(page: 1, limit: 50)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              print('⏱️ _loadPosts: Timeout loading posts');
              return <post_models.Post>[];
            },
          );
      
      print('📦 _loadPosts: Received ${posts.length} total posts from feed');
      
      // Filter posts that have images (prefer posts with pageId, but include all posts with images)
      final postsWithImages = posts
          .where((post) {
            final hasImages = post.images.isNotEmpty;
            if (hasImages) {
              print('  ✓ Post ${post.id}: has ${post.images.length} images, pageId: ${post.pageId}');
            }
            return hasImages;
          })
          .toList();
      
      print('📦 _loadPosts: Found ${postsWithImages.length} posts with images');
      
      // Sort by createdAt (newest first)
      postsWithImages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Take up to 12 posts (matching grid positions)
      final limitedPosts = postsWithImages.take(12).toList();
      
      print('📦 _loadPosts: Selected ${limitedPosts.length} posts for grid display');
      
      if (mounted) {
        setState(() {
          _postsWithImages = limitedPosts;
          _isLoadingPosts = false;
        });
        print('✅ _loadPosts: Loaded ${limitedPosts.length} posts for grid');
      }
    } catch (e, stackTrace) {
      print('❌ _loadPosts: Error loading posts: $e');
      print('📚 _loadPosts: Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _postsWithImages = [];
          _isLoadingPosts = false;
        });
      }
    }
  }
  
  // Public method to refresh posts (called when returning from creating a post)
  void refreshPosts() {
    _loadPosts();
  }
  
  // Public method to restart animation (called from MainScreen)
  void restartAnimation() {
    if (!mounted) return;
    
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    
    _animationController.reset();
    _animationController.forward();
    
    // Refresh posts when tab becomes active (to show new posts at top)
    refreshPosts();
  }
  
  // Recent searches - stored locally
  final List<String> _recentSearches = [];
  
  // Grid layout positions (same as Figma design)
  // Grid layout: 3 columns x varying rows, each cell 112px
  final List<Map<String, dynamic>> _gridPositions = [
    // Row 1
    {'left': 0, 'top': 0, 'width': 112, 'height': 112},
    {'left': 112, 'top': 56, 'width': 112, 'height': 112},
    {'left': 224, 'top': 0, 'width': 112, 'height': 112},
    // Row 2
    {'left': 0, 'top': 112, 'width': 112, 'height': 112},
    {'left': 224, 'top': 112, 'width': 112, 'height': 140},
    // Row 3
    {'left': 0, 'top': 224, 'width': 112, 'height': 112},
    {'left': 112, 'top': 168, 'width': 112, 'height': 140},
    {'left': 224, 'top': 252, 'width': 112, 'height': 112},
    // Row 4
    {'left': 112, 'top': 308, 'width': 112, 'height': 112},
    {'left': 0, 'top': 336, 'width': 112, 'height': 140},
    {'left': 224, 'top': 364, 'width': 112, 'height': 112},
  ];

  // Get filtered search results based on query - searches through real pages
  List<models.Page> get _searchResults {
    // Allow search even while loading if we have some pages loaded
    if (_searchQuery.isEmpty) {
      return [];
    }
    
    // If still loading but we have pages, use them
    if (_isLoadingPages && _allPages.isEmpty) {
      return [];
    }
    
    final query = _searchQuery.toLowerCase().trim();
    if (query.isEmpty) return [];
    
    final results = _allPages.where((page) {
      final name = page.name.toLowerCase();
      // Search for any keyword in the page name
      return name.contains(query);
    }).toList();
    
    print('🔍 Search for "$query": Found ${results.length} results from ${_allPages.length} total pages');
    if (results.isNotEmpty) {
      print('📝 Matching pages: ${results.map((p) => p.name).join(", ")}');
    }
    
    return results;
  }

  void _removeRecentSearch(int index) {
    setState(() {
      _recentSearches.removeAt(index);
    });
  }

  void _navigateToPage(models.Page page) {
    final pageName = page.name;
    
    // Add to recents (move to top if already exists - most recent first)
    setState(() {
      // Remove if already exists
      _recentSearches.remove(pageName);
      // Insert at the beginning (most recent first)
      _recentSearches.insert(0, pageName);
      // Keep only last 5
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
    });
    
    // Navigate to Page Detail Screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PageDetailScreen(page: page),
      ),
    );
    
    // Clear search
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
    _searchFocusNode.unfocus();
  }

  void _onSearchSubmit(String query) {
    if (query.isNotEmpty) {
      setState(() {
        // Remove if already exists
        _recentSearches.remove(query);
        // Insert at the beginning (most recent first)
        _recentSearches.insert(0, query);
        // Keep only last 5
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bubbles - animated to slide in from outside
          FadeTransition(
            opacity: _bubblesFadeAnimation,
            child: SlideTransition(
              position: _bubblesSlideAnimation,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Bubble 02 - Yellow top left, rotated 158°
                  Positioned(
                    left: -131.97,
                    top: -205.67,
                    child: Transform.rotate(
                      angle: 158 * math.pi / 180,
                      child: SizedBox(
                        width: 311.014,
                        height: 367.298,
                        child: CustomPaint(
                          painter: _Bubble02Painter(),
                        ),
                      ),
                    ),
                  ),

                  // Bubble 01 - Black bottom right
                  Positioned(
                    left: 283.73,
                    top: 41,
                    child: SizedBox(
                      width: 243.628,
                      height: 266.77,
                      child: CustomPaint(
                        painter: _Bubble01Painter(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top spacing for status bar and back button area (moved lower to match search bar)
                const SizedBox(height: 158),
                
                // Transparent overlay behind recents section
                Container(
                  margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.0833 - 4.5),
                  padding: const EdgeInsets.only(bottom: 16),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "Recents" header - Figma: Poppins ExtraBold 12px
                      const Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 8, top: 16),
                        child: Text(
                          'Recents',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      
                      // Recent search items
                      ..._recentSearches.asMap().entries.map((entry) {
                        return _buildRecentItem(entry.value, entry.key);
                      }),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Image Grid - Figma mosaic layout
                _buildImageGrid(),
                
                // Debug: Show post count
                if (_postsWithImages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Showing ${_postsWithImages.length} posts',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                
                // Bottom padding for nav bar
                const SizedBox(height: 100),
              ],
            ),
          ),
          
          // Fixed search field overlay - iOS style (moved lower)
          Positioned(
            left: MediaQuery.of(context).size.width * 0.0833 + 1.5,
            right: MediaQuery.of(context).size.width * 0.0833 + 1.5,
            top: 110, // Moved lower from 92 to 110
            child: _buildSearchField(),
          ),
          
          // Search results dropdown - appears when typing
          // Positioned after search field to ensure it's on top
          if (_searchQuery.isNotEmpty && !_isLoadingPages)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.0833 + 1.5,
              right: MediaQuery.of(context).size.width * 0.0833 + 1.5,
              top: 158, // Adjusted to maintain spacing below search bar (110 + 48 = 158)
              child: IgnorePointer(
                ignoring: false,
                child: Material(
                  elevation: 12,
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  shadowColor: Colors.black.withOpacity(0.3),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4, // Responsive max height
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: _searchResults.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No pages found matching "$_searchQuery"',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final page = _searchResults[index];
                              return _buildSearchResultItem(page);
                            },
                          ),
                  ),
                ),
              ),
            ),
          
          // Back button - top left (routes to home)
          CustomBackButton(
            backgroundColor: Colors.white, // White background, so button will be black
            iconSize: 24,
            navigateToHome: true,
          ),

          // "Search" title - Figma: left: calc(16.67% + 2px), top: 48px
          Positioned(
            left: MediaQuery.of(context).size.width * 0.1667 + 2,
            top: 48,
            child: const Text(
              'Search',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -0.52,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Search result item with icon and name
  Widget _buildSearchResultItem(models.Page page) {
    return InkWell(
      onTap: () => _navigateToPage(page),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Profile image/icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                border: Border.all(
                  color: const Color(0xFF8F7902),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: page.logo != null
                    ? CachedNetworkImage(
                        imageUrl: page.logo!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Icon(
                          page.type == 'club' ? Icons.groups : Icons.location_city,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      )
                    : Icon(
                        page.type == 'club' ? Icons.groups : Icons.location_city,
                        color: Colors.grey[600],
                        size: 20,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Name and type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    page.name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    page.type == 'club' ? 'Club' : 'District',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  /// iOS-style search field from Figma
  /// BG: white with rounded corners, shadow, gray overlay
  Widget _buildSearchField() {
    return Container(
      height: 43,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(1000),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 0,
            spreadRadius: 1,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(1000),
        ),
        padding: const EdgeInsets.only(left: 8, right: 4),
        child: Row(
          children: [
            // Magnifying glass icon - Figma uses SF Pro Rounded
            Container(
              width: 16,
              height: 15,
              alignment: Alignment.center,
              child: const Icon(
                Icons.search,
                size: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 2),
            // Search text input
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4C4C4C),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  isDense: true,
                  filled: false,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  // Debug info after setState
                  print('🔍 Search query updated: "$_searchQuery"');
                  print('📊 Total pages loaded: ${_allPages.length}');
                  print('⏳ Is loading pages: $_isLoadingPages');
                  print('📋 Search results count: ${_searchResults.length}');
                  if (_allPages.isNotEmpty) {
                    print('📝 Available pages: ${_allPages.map((p) => p.name).join(", ")}');
                  }
                },
                onSubmitted: _onSearchSubmit,
              ),
            ),
            // Clear button (shows when there's text)
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
                child: Container(
                  width: 16,
                  height: 15,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Color(0xFF4C4C4C),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Recent search item with X button
  /// Figma: Poppins Medium 13.794px, X button at right
  Widget _buildRecentItem(String text, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Search text - Figma: left offset from container - Make it clickable
          Expanded(
            child: InkWell(
              onTap: () => _navigateFromRecentSearch(text),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.794,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
          // X button - Figma: Poppins Medium 20px, ⨯ character
          GestureDetector(
            onTap: () => _removeRecentSearch(index),
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: const Text(
                '⨯',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Navigate to page from recent search text
  void _navigateFromRecentSearch(String searchText) {
    // Move clicked recent search to the top (most recent first)
    setState(() {
      _recentSearches.remove(searchText);
      _recentSearches.insert(0, searchText);
    });
    
    // Find matching page from loaded pages
    final query = searchText.toLowerCase().trim();
    if (query.isEmpty) return;
    
    // Search for matching page (case-insensitive partial match)
    models.Page? matchingPage;
    try {
      matchingPage = _allPages.firstWhere(
        (page) => page.name.toLowerCase().contains(query),
      );
    } catch (e) {
      // No matching page found
      matchingPage = null;
    }
    
    if (matchingPage != null) {
      // Navigate to the page (this will also update recents)
      _navigateToPage(matchingPage);
    } else {
      // If no exact match found, set the search query to show suggestions
      setState(() {
        _searchQuery = searchText;
        _searchController.text = searchText;
      });
      // Focus the search field to show suggestions
      _searchFocusNode.requestFocus();
    }
  }

  /// Image grid matching Figma mosaic layout with real post images
  /// Frame container: width 336px, images positioned absolutely
  Widget _buildImageGrid() {
    // Calculate scale factor based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.8333; // ~336px on 402px screen
    final scale = containerWidth / 336;
    
    // If loading or no posts, show placeholder or empty
    if (_isLoadingPosts) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.0833 + 3.5),
        height: 476 * scale, // Approximate height
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_postsWithImages.isEmpty) {
      print('⚠️ _buildImageGrid: No posts with images to display');
      return const SizedBox.shrink();
    }
    
    print('🖼️ _buildImageGrid: Building grid with ${_postsWithImages.length} posts');
    
    // Calculate total height needed (based on furthest bottom image)
    final maxBottom = _gridPositions.map((pos) => 
      (pos['top'] as int) + (pos['height'] as int)
    ).reduce((a, b) => a > b ? a : b);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.0833 + 3.5),
      width: containerWidth,
      height: maxBottom * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: _gridPositions.asMap().entries.map((entry) {
          final index = entry.key;
          final position = entry.value;
          
          // Use post image if available, otherwise skip
          if (index >= _postsWithImages.length) {
            return const SizedBox.shrink();
          }
          
          final post = _postsWithImages[index];
          if (post.images.isEmpty) {
            return const SizedBox.shrink();
          }
          
          final imageUrl = post.images.first; // Use first image from post
          final leftPos = (position['left'] as int) * scale;
          final topPos = (position['top'] as int) * scale;
          final width = (position['width'] as int) * scale;
          final height = (position['height'] as int) * scale;
          
          print('🖼️ _buildImageGrid: Adding image $index at ($leftPos, $topPos) size ${width}x$height: $imageUrl');
          
          return Positioned(
            left: leftPos,
            top: topPos,
            width: width,
            height: height,
            child: GestureDetector(
              onTap: () {
                print('🖱️ Image tapped for post: ${post.id}');
                _navigateToPostPage(post);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: width,
                    height: height,
                    placeholder: (context, url) => Container(
                      width: width,
                      height: height,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      print('❌ Error loading image: $url - $error');
                      return Container(
                        width: width,
                        height: height,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  /// Navigate to page from post
  void _navigateToPostPage(post_models.Post post) {
    print('🖱️ _navigateToPostPage: Clicked on post ${post.id}');
    print('   Post pageId: ${post.pageId}');
    print('   Total pages loaded: ${_allPages.length}');
    print('   Page IDs: ${_allPages.map((p) => p.id).join(", ")}');
    
    // If post has a pageId, navigate to that page
    if (post.pageId != null) {
      // Find the page
      models.Page? page;
      try {
        page = _allPages.firstWhere(
          (p) => p.id == post.pageId,
        );
        print('✅ Found page: ${page.name} (${page.id})');
      } catch (e) {
        // Page not found
        page = null;
        print('❌ Page not found in cache for post.pageId: ${post.pageId}');
        print('   Error: $e');
      }
      
      if (page != null) {
        print('🚀 Navigating to page: ${page.name}');
        _navigateToPage(page);
      } else {
        // If page not found in cache, try to fetch it or show error
        print('⚠️ Page not found for post: ${post.pageId}');
        // Show a snackbar to inform the user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Page not found. Please try again.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      // If post doesn't have a pageId, it's a user post - we can't navigate to a page
      print('⚠️ Post ${post.id} does not have a pageId - cannot navigate to page');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This post is not associated with a page.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

/// Yellow Bubble 02 Painter - Exact Figma SVG path pe2b6900
class _Bubble02Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final path = Path();
    final scaleX = size.width / 325;
    final scaleY = size.height / 368;

    path.moveTo(142.573 * scaleX, 33.5385 * scaleY);
    path.cubicTo(
      221.639 * scaleX, -74.0067 * scaleY,
      324.97 * scaleX, 103.016 * scaleY,
      309.453 * scaleX, 200.418 * scaleY,
    );
    path.cubicTo(
      293.936 * scaleX, 297.821 * scaleY,
      234.738 * scaleX, 367.298 * scaleY,
      142.573 * scaleX, 367.298 * scaleY,
    );
    path.cubicTo(
      50.4079 * scaleX, 367.298 * scaleY,
      7.1557 * scaleX, 288.01 * scaleY,
      0.447188 * scaleX, 203.99 * scaleY,
    );
    path.cubicTo(
      -6.26132 * scaleX, 119.97 * scaleY,
      63.5071 * scaleX, 141.084 * scaleY,
      142.573 * scaleX, 33.5385 * scaleY,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Black Bubble 01 Painter - Exact Figma SVG path p2b951e00
class _Bubble01Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF02091A)
      ..style = PaintingStyle.fill;

    final path = Path();
    final scaleX = size.width / 244;
    final scaleY = size.height / 267;

    path.moveTo(122.23 * scaleX, 23.973 * scaleY);
    path.cubicTo(
      179.747 * scaleX, -54.2618 * scaleY,
      243.628 * scaleX, 78.3248 * scaleY,
      243.628 * scaleX, 145.371 * scaleY,
    );
    path.cubicTo(
      243.628 * scaleX, 212.418 * scaleY,
      189.276 * scaleX, 266.77 * scaleY,
      122.23 * scaleX, 266.77 * scaleY,
    );
    path.cubicTo(
      55.1834 * scaleX, 266.77 * scaleY,
      -8.01705 * scaleX, 215.723 * scaleY,
      0.831575 * scaleX, 145.371 * scaleY,
    );
    path.cubicTo(
      9.6802 * scaleX, 75.0195 * scaleY,
      64.7126 * scaleX, 102.208 * scaleY,
      122.23 * scaleX, 23.973 * scaleY,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
