import 'package:flutter/material.dart';

/// Contact Us Screen - Exact Figma Implementation 377:1141
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Bubbles
          Positioned(
            right: -100,
            bottom: 200,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -80,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 140,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.black, Color(0xFFFFD700)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 10,
                        top: 20,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Positioned(
                        left: 67,
                        top: 48,
                        child: Text(
                          'Contact Us',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Raleway',
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.52,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Phone', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 7),
                        Container(
                          width: 302,
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: const Color(0x1A000000), borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: const [
                              Icon(Icons.phone, size: 20, color: Colors.black),
                              SizedBox(width: 12),
                              Text('+94 112 863 066', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 27),
                        const Text('Email', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 7),
                        Container(
                          width: 302,
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: const Color(0x1A000000), borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: const [
                              Icon(Icons.mail, size: 20, color: Colors.black),
                              SizedBox(width: 12),
                              Text('admin@lionsmd306.lk', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, decoration: TextDecoration.underline)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 27),
                        const Text('Address', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 7),
                        Container(
                          width: 302,
                          height: 73,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(color: const Color(0x1A000000), borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Padding(padding: EdgeInsets.only(top: 2), child: Icon(Icons.location_on, size: 20, color: Colors.black)),
                              SizedBox(width: 12),
                              Expanded(child: Text('Lions Activity Center,\nMorris Rajapakse Mw,\nSri Jayawardanapura, Kotte,\nSri Lanka', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, height: 1.17))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 27),
                        const Text('Website', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 7),
                        Container(
                          width: 302,
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: const Color(0x1A000000), borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: const [
                              Icon(Icons.language, size: 20, color: Colors.black),
                              SizedBox(width: 12),
                              Text('https://leomd306.org', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, decoration: TextDecoration.underline)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                        const Text('Follow us', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(width: 40, height: 39.22, decoration: BoxDecoration(color: const Color(0xFF3747D6), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.facebook, color: Colors.white, size: 24)),
                            const SizedBox(width: 12),
                            Container(width: 40, height: 39.22, decoration: BoxDecoration(color: const Color(0xFF85A8FB), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.business, color: Colors.white, size: 20)),
                          ],
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
