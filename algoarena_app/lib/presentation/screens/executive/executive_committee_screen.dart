import 'package:flutter/material.dart';

/// Executive Committee Screen - Exact Figma Implementation 386:1297
class ExecutiveCommitteeScreen extends StatelessWidget {
  const ExecutiveCommitteeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(right: -150, bottom: 350, child: Container(width: 400, height: 400, decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.3), shape: BoxShape.circle))),
          Positioned(left: -80, top: -100, child: Container(width: 220, height: 220, decoration: BoxDecoration(color: Colors.black.withOpacity(0.04), shape: BoxShape.circle))),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 140,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.black, Color(0xFFFFD700)]),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(left: 10, top: 20, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28), onPressed: () => Navigator.pop(context))),
                      const Positioned(left: 67, top: 48, child: Text('Executive\nCommittee', style: TextStyle(color: Colors.white, fontFamily: 'Raleway', fontSize: 50, fontWeight: FontWeight.bold, letterSpacing: -0.52, height: 1))),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 353,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0x1A000000), borderRadius: BorderRadius.circular(15)),
                          child: const Text(
                            'The Executive Committee of LEO District 306 is the primary leadership body entrusted with overseeing district operations, ensuring organizational discipline, and guiding the strategic direction of all Leo clubs. Each member of the committee plays a vital role in upholding the district\'s standards and driving initiatives that contribute to youth development and community service.\n\n      Aligned with the district theme "Strive to Thrive," the Executive Committee is committed to fostering excellence, strengthening inter-club collaboration, and supporting the personal and professional growth of every Leo within the district.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: 353,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0x1A000000), borderRadius: BorderRadius.circular(15)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Executive Committee Positions', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black, height: 1.33)),
                              SizedBox(height: 8),
                              Text('District Leadership', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, height: 1.33)),
                              Text('   District President', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33)),
                              Text('   District Vice President', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33)),
                              Text('   Immediate Past District President', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33)),
                              SizedBox(height: 8),
                              Text('Administrative Officers', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, height: 1.33)),
                              Text('   District Secretary', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33)),
                              Text('   Assistant District Secretary', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33)),
                              Text('   District Treasurer', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33)),
                              Text('   Assistant District Treasurer', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33)),
                              SizedBox(height: 8),
                              Text('Program & Operations', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, height: 1.33)),
                              Text('   District Chairperson  Membership', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33)),
                              Text('   District Chairperson  Leadership Development', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33)),
                              Text('   District Chairperson  Service Activities', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33)),
                              Text('   District Coordinator  IT & Digital Media', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33)),
                              Text('   District Coordinator  Public Relations', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33)),
                              Text('   District Coordinator  Special Projects', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33)),
                              SizedBox(height: 8),
                              Text('Regional & Zone Leadership', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, height: 1.33)),
                              Text('   Regional Chairpersons (All Regions)', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33)),
                              Text('   Zone Chairpersons (All Zones)', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.33)),
                            ],
                          ),
                        ),
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
}
