import 'package:flutter/material.dart';
import '../../widgets/app_bottom_nav.dart';
import '../club/club_profile_screen.dart';
import '../pages/leo_district_detail_screen.dart';

/// Search Screen - Exact match to Figma search/src/imports/Search.tsx
/// Design specs:
/// - Back button: left:10, top:50, 50x53px
/// - Search field: iOS style with magnifying glass, "Search" placeholder
/// - Recents section with 5 items (X to remove each)
/// - Image grid: 112px cells in mosaic layout
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  
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
  List<String> _recentSearches = [
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top spacing for status bar and back button area
                const SizedBox(height: 140),
                
                // White overlay behind recents section (from Figma)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.0833 - 4.5),
                  padding: const EdgeInsets.only(bottom: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
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
          
          // Fixed search field overlay - Figma: top:92, iOS style
          Positioned(
            left: MediaQuery.of(context).size.width * 0.0833 + 1.5,
            right: MediaQuery.of(context).size.width * 0.0833 + 1.5,
            top: 92,
            child: _buildSearchField(),
          ),
          
          // Search results dropdown - appears when typing
          if (_searchResults.isNotEmpty)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.0833 + 1.5,
              right: MediaQuery.of(context).size.width * 0.0833 + 1.5,
              top: 140,
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
                  'assets/images/search/e5b2d02426dff02ff323daa74a9b12f7fea3649b.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
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
        color: Colors.white,
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
          color: Colors.black.withOpacity(0.05),
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
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  isDense: true,
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
