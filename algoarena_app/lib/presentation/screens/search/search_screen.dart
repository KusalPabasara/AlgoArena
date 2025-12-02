import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../club/club_profile_screen.dart';
import '../pages/leo_district_detail_screen.dart';
import '../../widgets/custom_back_button.dart';

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
    
    // Don't start animation immediately - wait for restartAnimation() call
    // This ensures bubbles are hidden initially
  }
  
  // Public method to restart animation (called from MainScreen)
  void restartAnimation() {
    if (!mounted) return;
    
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    
    _animationController.reset();
    _animationController.forward();
  }
  
  // Searchable items - Leo Club of Colombo and Leo District 362
  final List<Map<String, dynamic>> _searchableItems = [
    {
      'name': 'Leo Club of Colombo',
      'type': 'club',
      'image': 'assets/images/Home/Leo club colombo.png',
    },
    {
      'name': 'Leo District 362',
      'type': 'district',
      'image': 'assets/images/pages/cba507d80d35e8876a479cce78f72f4bb9d95def.png',
      'mutuals': '97 mutuals',
    },
  ];
  
  // Recent searches from Figma design
  final List<String> _recentSearches = [
    'Leo Club of University of Peradeniya',
    'Colombo Leo',
    'Leo Ashen',
    'University of Jayawardenapura',
    'Moratuwa Leo',
  ];
  
  // Image grid data from Figma - 11 images with positions
  // Grid layout: 3 columns x varying rows, each cell 112px
  final List<Map<String, dynamic>> _gridImages = [
    // Row 1
    {'image': '5e1dd65ca0c4106010fd33a3f7c80497f02ca5b2.png', 'left': 0, 'top': 0, 'width': 112, 'height': 112},
    {'image': 'e5d9b8d8ac11fbaed7d6cc23de63bf603678d299.png', 'left': 112, 'top': 56, 'width': 112, 'height': 112},
    {'image': '2d56f1c4118e0f4442bbdf50c8d39b18e1794de0.png', 'left': 224, 'top': 0, 'width': 112, 'height': 112},
    // Row 2
    {'image': '237afce60b859bf919b00b17311ef161184b01fe.png', 'left': 0, 'top': 112, 'width': 112, 'height': 112},
    {'image': '6d81b876706ace03505fb1391671ba47b0073e5e.png', 'left': 224, 'top': 112, 'width': 112, 'height': 140},
    // Row 3
    {'image': '31d07557884264b1b070f971cc49466a561b5a39.png', 'left': 0, 'top': 224, 'width': 112, 'height': 112},
    {'image': '28144f3b7b31659eca64dd7042213cc7b21abe19.png', 'left': 112, 'top': 168, 'width': 112, 'height': 140},
    {'image': 'd55abeca497825d9ce40ca4f10173f822afc9c9f.png', 'left': 224, 'top': 252, 'width': 112, 'height': 112},
    // Row 4
    {'image': '9f8954359f3c93def292b23cee12251aaa490596.png', 'left': 112, 'top': 308, 'width': 112, 'height': 112},
    {'image': '2150df91f2f6c22cddc53debbf42c2fa7187bd8d.png', 'left': 0, 'top': 336, 'width': 112, 'height': 140},
    {'image': 'd5f71bfb65c17c551f045f288e5355bedd23b999.png', 'left': 224, 'top': 364, 'width': 112, 'height': 112},
  ];

  // Get filtered search results based on query
  List<Map<String, dynamic>> get _searchResults {
    if (_searchQuery.isEmpty) return [];
    final query = _searchQuery.toLowerCase();
    return _searchableItems.where((item) {
      final name = (item['name'] as String).toLowerCase();
      return name.contains(query);
    }).toList();
  }

  void _removeRecentSearch(int index) {
    setState(() {
      _recentSearches.removeAt(index);
    });
  }

  void _navigateToResult(Map<String, dynamic> item) {
    final type = item['type'] as String;
    final name = item['name'] as String;
    
    // Add to recents
    if (!_recentSearches.contains(name)) {
      setState(() {
        _recentSearches.insert(0, name);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }
    
    if (type == 'club') {
      // Navigate to Club Profile Screen
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ClubProfileScreen(
            clubName: name,
            clubLogo: item['image'] as String,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            
            var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeIn),
            );
            
            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else if (type == 'district') {
      // Navigate to Leo District Detail Screen (same as District Pages list)
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => LeoDistrictDetailScreen(
            districtName: name,
            mutuals: item['mutuals'] as String? ?? '97 mutuals',
            image: item['image'] as String,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
    
    // Clear search
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
    _searchFocusNode.unfocus();
  }

  void _onSearchSubmit(String query) {
    if (query.isNotEmpty && !_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
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
          if (_searchResults.isNotEmpty)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.0833 + 1.5,
              right: MediaQuery.of(context).size.width * 0.0833 + 1.5,
              top: 158, // Adjusted to maintain spacing below search bar
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      return _buildSearchResultItem(item);
                    },
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
  Widget _buildSearchResultItem(Map<String, dynamic> item) {
    final name = item['name'] as String;
    final type = item['type'] as String;
    final image = item['image'] as String;
    
    return InkWell(
      onTap: () => _navigateToResult(item),
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
              ),
              child: ClipOval(
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    type == 'club' ? Icons.groups : Icons.location_city,
                    color: Colors.grey[600],
                    size: 20,
                  ),
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
                    name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    type == 'club' ? 'Club' : 'District',
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
          // Search text - Figma: left offset from container
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
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

  /// Image grid matching Figma mosaic layout
  /// Frame container: width 336px, images positioned absolutely
  Widget _buildImageGrid() {
    // Calculate scale factor based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.8333; // ~336px on 402px screen
    final scale = containerWidth / 336;
    
    // Calculate total height needed (based on furthest bottom image)
    final maxBottom = _gridImages.map((img) => 
      (img['top'] as int) + (img['height'] as int)
    ).reduce((a, b) => a > b ? a : b);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.0833 + 3.5),
      height: maxBottom * scale,
      child: Stack(
        children: _gridImages.map((imageData) {
          return Positioned(
            left: (imageData['left'] as int) * scale,
            top: (imageData['top'] as int) * scale,
            width: (imageData['width'] as int) * scale,
            height: (imageData['height'] as int) * scale,
            child: Image.asset(
              'assets/images/search/${imageData['image']}',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          );
        }).toList(),
      ),
    );
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
