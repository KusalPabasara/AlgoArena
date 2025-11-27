import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Decorative bubbles background
          Positioned(
            right: -180,
            top: 495,
            child: Transform.rotate(
              angle: 1.9199, // 110 degrees
              child: Opacity(
                opacity: 0.3,
                child: Container(
                  width: 354,
                  height: 443,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -115,
            top: -254,
            child: Transform.rotate(
              angle: 4.115,
              child: Opacity(
                opacity: 0.2,
                child: Container(
                  width: 374,
                  height: 443,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -148,
            top: -290,
            child: Transform.rotate(
              angle: 4.189,
              child: Opacity(
                opacity: 0.2,
                child: Container(
                  width: 403,
                  height: 443,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 2),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                
                // Title
                const Padding(
                  padding: EdgeInsets.only(left: 69, bottom: 20),
                  child: Text(
                    'About',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.52,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection('About District 306', 'LEO District 306 is a leading youth-led service community in Sri Lanka, uniting passionate young leaders committed to personal growth, community service, and positive impact.\nBuilt on Leadership, Experience, and Opportunity, we empower Leos to develop real leadership skills and contribute meaningfully through humanitarian and youth development initiatives.', 169),
                        const SizedBox(height: 20),
                        _buildSection('Our Mission', 'To empower young individuals to become responsible leaders who create sustainable and meaningful change in their communities.', 89),
                        const SizedBox(height: 20),
                        _buildSection('Our Vision', 'A generation of youth equipped with compassion, leadership, and skills to build a better future for Sri Lanka and the world.', 89),
                        const SizedBox(height: 20),
                        _buildListSection('What We Do', [
                          'District 306 carries out:',
                          'Community service projects that uplift underserved communities',
                          'Youth leadership and skill-building programs',
                          'Environmental protection and sustainability initiatives',
                          'Health and wellness campaigns',
                          'Fundraisers and charity drives',
                          'District-wide conventions, training sessions, and competitions',
                          '',
                          'These activities help Leos enhance teamwork, public speaking, project management, and organizational skills.',
                        ], 217),
                        const SizedBox(height: 20),
                        _buildListSection('Our Structure', [
                          'The district is guided by:',
                          'District President & Executive Committee',
                          'Regional and Zone Chairpersons',
                          'Advisors, Coordinators, and Club Officers',
                          '',
                          'Together, they support all Leo clubs within District 306, ensuring smooth operations, strong collaboration, and impactful project outcomes.',
                        ], 154),
                        const SizedBox(height: 20),
                        _buildSection('Our Clubs', 'District 306 is composed of multiple Leo clubs across different cities and regions. Each club carries out unique service activities while contributing to the district\'s common goals.', 104),
                        const SizedBox(height: 20),
                        _buildListSection('Why Join Us?', [
                          'Being a Leo means:',
                          'Becoming a leader',
                          'Gaining real-world experience',
                          'Meeting inspiring youth',
                          'Serving communities that need help',
                          'Being part of an international movement',
                          '',
                          'District 306 is more than a youth organization - it\'s a family of passionate changemakers.',
                        ], 168),
                      ],
                    ),
                  ),
                ),
                Center(child: Container(margin: const EdgeInsets.only(bottom: 12), width: 145.848, height: 5.442, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(34)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, double height) {
    return Container(
      width: 353,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0x1A000000), borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, height: 2.58)),
          const SizedBox(height: 6),
          Text(content, textAlign: TextAlign.justify, style: const TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33)),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items, double height) {
    return Container(
      width: 353,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0x1A000000), borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, height: 2.58)),
          const SizedBox(height: 6),
          ...items.map((item) {
            if (item.isEmpty) return const SizedBox(height: 4);
            final isBullet = !item.endsWith(':') && items.indexOf(item) != 0 && items.indexOf(item) != items.length - 1 && items.indexOf(item) != items.length - 2;
            return Padding(
              padding: EdgeInsets.only(left: isBullet ? 18 : 0, bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isBullet) const Text(' ', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black)),
                  Expanded(child: Text(item, textAlign: TextAlign.justify, style: const TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33))),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
