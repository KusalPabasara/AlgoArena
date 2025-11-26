import 'package:flutter/material.dart';
import 'leo_district_detail_screen.dart';
import '../../widgets/app_bottom_nav.dart';

/// District Pages List Screen - implements exact Figma design from Pages_district folder
/// Bubbles: left:-189.94, top:-336.1, w:570.671, h:579.191, viewBox 571x580
/// SVG paths: p14491f00 (yellow), p1d0f2140 (black)
/// Title "District Pages :": left:35, top:169, 26px Raleway Bold
/// List frame: left:35, top:211, h:634, w:332

class DistrictPagesListScreen extends StatefulWidget {
  const DistrictPagesListScreen({super.key});

  @override
  State<DistrictPagesListScreen> createState() => _DistrictPagesListScreenState();
}

class _DistrictPagesListScreenState extends State<DistrictPagesListScreen> {
  // District pages data from Figma DistrictPages.tsx
  final List<Map<String, dynamic>> _districtPages = [
    {
      'name': 'Leo District D1',
      'mutuals': '102 mutuals',
      'image': 'assets/images/pages/6417bd0c09713d4aef96b17af8d17856e95bcca9.png',
      'isFollowing': false,
      'isLargeCard': false,
    },
    {
      'name': 'Leo District D2',
      'mutuals': '97 mutuals',
      'image': 'assets/images/pages/cba507d80d35e8876a479cce78f72f4bb9d95def.png',
      'isFollowing': false,
      'isLargeCard': false,
    },
    {
      'name': 'Leo District D3',
      'mutuals': '97 mutuals',
      'image': 'assets/images/pages/8337621cebd2c612040ac41416ac02d00a169b85.png',
      'isFollowing': false,
      'isLargeCard': true, // This card has height 134px in Figma
    },
    {
      'name': 'Leo District D2',
      'mutuals': '97 mutuals',
      'image': 'assets/images/pages/cba507d80d35e8876a479cce78f72f4bb9d95def.png',
      'isFollowing': false,
      'isLargeCard': false,
    },
    {
      'name': 'Leo District D2',
      'mutuals': '97 mutuals',
      'image': 'assets/images/pages/cba507d80d35e8876a479cce78f72f4bb9d95def.png',
      'isFollowing': false,
      'isLargeCard': false,
    },
    {
      'name': 'Leo District D7',
      'mutuals': '97 mutuals',
      'image': 'assets/images/pages/cba507d80d35e8876a479cce78f72f4bb9d95def.png',
      'isFollowing': false,
      'isLargeCard': false,
    },
  ];

  void _toggleFollow(int index) {
    setState(() {
      _districtPages[index]['isFollowing'] = !_districtPages[index]['isFollowing'];
    });
    
    final name = _districtPages[index]['name'];
    final isFollowing = _districtPages[index]['isFollowing'] as bool;
    
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Bubbles - District Pages has different bubble shape than Pages screen
          // Figma: left:-189.94, top:-336.1, w:570.671, h:579.191, viewBox 571x580
          Positioned(
            left: -189.94,
            top: -336.1,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, opacity, child) {
                return Opacity(opacity: opacity, child: child);
              },
              child: SizedBox(
                width: 570.671,
                height: 579.191,
                child: CustomPaint(
                  size: const Size(570.671, 579.191),
                  painter: _DistrictBubblesPainter(),
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
                        
                        // "District Pages :" title - Figma: left:35, top:169
                        const Padding(
                          padding: EdgeInsets.only(left: 35),
                          child: Text(
                            'District Pages :',
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
                        
                        // District Pages list - Figma: left:35, top:211, h:634
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _districtPages.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 11),
                            itemBuilder: (context, index) {
                              final page = _districtPages[index];
                              final isLargeCard = page['isLargeCard'] == true;
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
          
          // "Pages" title - Figma: left:69, top:48, 50px Raleway Bold
          const Positioned(
            left: 69,
            top: 48,
            child: Text(
              'Pages',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 50,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 59 / 50,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
  
  // Build page card - matches exact Figma design
  // Normal card: h:117px, w:332px, rounded:20px
  // Large card (D3): h:134px
  Widget _buildPageCard(Map<String, dynamic> page, int index, bool isLargeCard) {
    final cardHeight = isLargeCard ? 134.0 : 117.0;
    final isFollowing = page['isFollowing'] as bool;
    
    return GestureDetector(
      onTap: () {
        // Navigate to Leo District detail page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                LeoDistrictDetailScreen(
                  districtName: page['name'],
                  mutuals: page['mutuals'],
                  image: page['image'],
                ),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
      child: Container(
        width: 332,
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
          // Profile image container - Figma: ml:15, mt:14, 91x91px with #8F7902 border
          Positioned(
            left: 15,
            top: 14,
            child: Container(
              width: 91,
              height: 91,
              decoration: BoxDecoration(
                color: const Color(0xFF8F7902),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Container(
                  width: 81,
                  height: 81,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      page['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // District name - Figma: ml:121, mt:14, 16px Nunito Sans ExtraBold
          Positioned(
            left: 121,
            top: 14,
            child: Text(
              page['name'],
              style: const TextStyle(
                fontFamily: 'NunitoSans',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                height: 31 / 16,
              ),
            ),
          ),
          
          // Mutuals count - Figma: ml:121, mt:33 (or mt:48 for large card), 10px Nunito Sans Regular
          Positioned(
            left: 121,
            top: isLargeCard ? 48 : 33,
            child: Text(
              page['mutuals'],
              style: const TextStyle(
                fontFamily: 'NunitoSans',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                height: 31 / 10,
              ),
            ),
          ),
          
          // Follow/Unfollow button - Figma: ml:121, mt:66 (or mt:81 for large card), w:196, h:39
          Positioned(
            left: 121,
            top: isLargeCard ? 81 : 66,
            child: GestureDetector(
              onTap: () => _toggleFollow(index),
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
                      fontFamily: 'NunitoSans',
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
  }
}

// District Pages bubbles painter - different shape than Pages screen
// viewBox="0 0 571 580", exact SVG paths from Figma DistrictPages.tsx
class _DistrictBubblesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 571;
    final scaleY = size.height / 580;
    
    canvas.scale(scaleX, scaleY);
    
    // Yellow bubble (bubble 02) - p14491f00
    final yellowPath = Path();
    yellowPath.moveTo(413.27, 419.238);
    yellowPath.cubicTo(423.603, 580.029, 200.991, 479.632, 129.48, 394.41);
    yellowPath.cubicTo(57.9705, 309.188, 69.0865, 182.131, 154.309, 110.621);
    yellowPath.cubicTo(239.531, 39.1109, 341.043, 78.8666, 412.437, 151.352);
    yellowPath.cubicTo(483.831, 223.838, 402.936, 258.448, 413.27, 419.238);
    yellowPath.close();
    
    final yellowPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(yellowPath, yellowPaint);
    
    // Black bubble (bubble 01) - p1d0f2140
    final blackPath = Path();
    blackPath.moveTo(61.3756, 288.426);
    blackPath.cubicTo(-68.439, 192.988, 151.561, 86.99, 262.811, 86.99);
    blackPath.cubicTo(374.061, 86.99, 464.247, 177.176, 464.247, 288.426);
    blackPath.cubicTo(464.247, 399.675, 374.061, 489.861, 262.811, 489.861);
    blackPath.cubicTo(151.561, 489.861, 191.19, 383.864, 61.3756, 288.426);
    blackPath.close();
    
    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(blackPath, blackPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
