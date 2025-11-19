import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/club.dart';
import '../../widgets/loading_indicator.dart';

class PagesScreen extends StatefulWidget {
  const PagesScreen({Key? key}) : super(key: key);

  @override
  State<PagesScreen> createState() => _PagesScreenState();
}

class _PagesScreenState extends State<PagesScreen> {
  bool _isLoading = true;
  List<Club> _clubs = [];

  @override
  void initState() {
    super.initState();
    _loadClubs();
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
            isFollowing: true,
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
    }
  }

  void _toggleFollow(String clubId) {
    setState(() {
      final index = _clubs.indexWhere((c) => c.id == clubId);
      if (index != -1) {
        _clubs[index] = _clubs[index].copyWith(
          isFollowing: !(_clubs[index].isFollowing ?? false),
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
          // Decorative bubbles background
          Positioned(
            left: -239,
            top: -333,
            child: Image.asset(
              'assets/images/pages/bubbles.png',
              width: 610,
              height: 570,
              fit: BoxFit.contain,
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button and title
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 50,
                          height: 53,
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            'assets/images/pages/back_arrow.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Text(
                        'Pages',
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
                
                // Black "Pages" title overlay
                const Padding(
                  padding: EdgeInsets.fromLTRB(69, 0, 0, 20),
                  child: Text(
                    'Pages',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 50,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                      letterSpacing: -0.52,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // "Club Pages :" section title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 35),
                  child: Text(
                    'Club Pages :',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                      height: 1.19,
                    ),
                  ),
                ),
                
                const SizedBox(height: 11),
                
                // Scrollable club list
                Expanded(
                  child: _isLoading
                      ? const LoadingIndicator()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          itemCount: _clubs.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 11),
                          itemBuilder: (context, index) {
                            final club = _clubs[index];
                            return _buildClubCard(club);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubCard(Club club) {
    // Check if club name needs two lines
    final isTwoLines = club.name.length > 25;
    final cardHeight = isTwoLines ? 134.0 : 117.0;
    
    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Club logo with gold border
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
                    club.name.contains(' of ') ? club.name.split(' of ')[0] : club.name,
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
                
                // Follow/Unfollow button
                GestureDetector(
                  onTap: () => _toggleFollow(club.id),
                  child: Container(
                    width: 196,
                    height: 39,
                    decoration: BoxDecoration(
                      color: (club.isFollowing ?? false)
                          ? const Color(0xFF8F7902)
                          : AppColors.black,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        (club.isFollowing ?? false) ? 'Unfollow' : 'Follow',
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
    );
  }
}
