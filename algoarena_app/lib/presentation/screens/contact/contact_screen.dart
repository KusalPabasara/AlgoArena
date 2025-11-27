import 'package:flutter/material.dart';
import '../../widgets/custom_back_button.dart';
import '../../../core/constants/colors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Decorative bubbles background
          Positioned(
            right: -180,
            top: 560,
            child: Transform.rotate(
              angle: 1.5708, // 90 degrees
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
            left: -121,
            top: -254,
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
            left: -139,
            top: -304,
            child: Transform.rotate(
              angle: 4.092, // 234.398 degrees
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
                    'Contact Us',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.52,
                    ),
                  ),
                ),

                // Content area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        
                        // Phone section
                        _buildSection(
                          'Phone',
                          '+94 112 863 066',
                          Icons.phone,
                        ),
                        
                        const SizedBox(height: 27),
                        
                        // Email section
                        _buildSection(
                          'Email',
                          'admin@lionsmd306.lk',
                          Icons.email,
                          isLink: true,
                        ),
                        
                        const SizedBox(height: 27),
                        
                        // Address section
                        _buildAddressSection(),
                        
                        const SizedBox(height: 77),
                        
                        // Follow us section
                        const Text(
                          'Follow us',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            height: 2.58,
                          ),
                        ),
                        
                        const SizedBox(height: 7),
                        
                        // Social media icons
                        Row(
                          children: [
                            _buildSocialIcon(
                              Icons.facebook,
                              const Color(0xFF3747D6),
                            ),
                            const SizedBox(width: 12),
                            _buildSocialIcon(
                              Icons.facebook, // LinkedIn (using placeholder)
                              const Color(0xFF85A8FB),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 80),
                        
                        // Website section
                        _buildSection(
                          'Website',
                          'https://leomd306.org',
                          Icons.language,
                          isLink: true,
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

  Widget _buildSection(String title, String content, IconData icon, {bool isLink = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Raleway',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            height: 2.58,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  content,
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    height: 2.58,
                    decoration: isLink ? TextDecoration.underline : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            height: 2.58,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.location_on, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lions Activity Center,',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.17,
                      ),
                    ),
                    Text(
                      'Morris Rajapakse Mw,',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.17,
                      ),
                    ),
                    Text(
                      'Sri Jayawardanapura, Kotte,',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.17,
                      ),
                    ),
                    Text(
                      'Sri Lanka',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.17,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 39,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}
