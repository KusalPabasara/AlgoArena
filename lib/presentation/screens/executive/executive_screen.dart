import 'package:flutter/material.dart';
import '../../widgets/custom_back_button.dart';
import '../../../core/constants/colors.dart';

class ExecutiveScreen extends StatelessWidget {
  const ExecutiveScreen({super.key});

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
            left: -63,
            top: -230,
            child: Transform.rotate(
              angle: 4.115, // 235.784 degrees
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
            left: -125,
            top: -264,
            child: Transform.rotate(
              angle: 3.84, // 220 degrees
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
                // Header - Back button handled by CustomBackButton in Stack
                SizedBox(height: MediaQuery.of(context).padding.top + 48),
                
                // Title
                const Padding(
                  padding: EdgeInsets.only(left: 69, bottom: 20),
                  child: Text(
                    'Executive\nCommittee',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.52,
                      height: 1.0,
                    ),
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 23),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        
                        // Introduction
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'The Executive Committee of LEO District 306 is the primary leadership body entrusted with overseeing district operations, ensuring organizational discipline, and guiding the strategic direction of all Leo clubs. Each member of the committee plays a vital role in upholding the district\'s standards and driving initiatives that contribute to youth development and community service.\n\n      Aligned with the district theme "Strive to Thrive," the Executive Committee is committed to fostering excellence, strengthening inter-club collaboration, and supporting the personal and professional growth of every Leo within the district.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.33,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Executive Committee Positions
                        const Text(
                          'Executive Committee Positions',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            height: 2.75,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'District Leadership',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 1.33,
                                ),
                              ),
                              _buildBulletPoint('District President'),
                              _buildBulletPoint('District Vice President'),
                              _buildBulletPoint('Immediate Past District President'),
                              const SizedBox(height: 8),
                              
                              const Text(
                                'Administrative Officers',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 1.33,
                                ),
                              ),
                              _buildBulletPoint('District Secretary'),
                              _buildBulletPoint('Assistant District Secretary'),
                              _buildBulletPoint('District Treasurer'),
                              _buildBulletPoint('Assistant District Treasurer'),
                              const SizedBox(height: 8),
                              
                              const Text(
                                'Program & Operations',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 1.33,
                                ),
                              ),
                              _buildBulletPoint('District Chairperson – Membership'),
                              _buildBulletPoint('District Chairperson – Leadership Development'),
                              _buildBulletPoint('District Chairperson – Service Activities'),
                              _buildBulletPoint('District Coordinator – IT & Digital Media'),
                              _buildBulletPoint('District Coordinator – Public Relations'),
                              _buildBulletPoint('District Coordinator – Special Projects'),
                              const SizedBox(height: 8),
                              
                              const Text(
                                'Regional & Zone Leadership',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 1.33,
                                ),
                              ),
                              _buildBulletPoint('Regional Chairpersons (All Regions)'),
                              _buildBulletPoint('Zone Chairpersons (All Zones)'),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                
                // Bottom bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    width: 146,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(34),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Back button - top left
          CustomBackButton(
            backgroundColor: Colors.white, // White background
            iconSize: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.33,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
