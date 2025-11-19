import 'package:flutter/material.dart';

/// Notifications Screen - Exact Figma Implementation 360:1805
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  Widget _buildNotificationCard(String text) {
    return Container(
      width: 332,
      height: 66,
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
      decoration: BoxDecoration(color: const Color(0x1A000000), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFF9E9E9E), shape: BoxShape.circle), child: const Icon(Icons.person, color: Colors.white, size: 30)),
          const SizedBox(width: 6),
          Expanded(child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Nunito Sans', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black, height: 1.2))),
        ],
      ),
    );
  }

  Widget _buildSeeMoreButton() {
    return Container(
      width: 332,
      height: 39,
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: const Color(0xFFE6E6E6), borderRadius: BorderRadius.circular(14)),
      child: const Center(child: Text('See more...', style: TextStyle(fontFamily: 'Nunito Sans', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(right: -120, bottom: 300, child: Container(width: 380, height: 380, decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.27), shape: BoxShape.circle))),
          Positioned(left: -85, top: -90, child: Container(width: 240, height: 240, decoration: BoxDecoration(color: Colors.black.withOpacity(0.045), shape: BoxShape.circle))),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                      const Positioned(left: 67, top: 58, child: Text('Notifications', style: TextStyle(color: Colors.white, fontFamily: 'Raleway', fontSize: 50, fontWeight: FontWeight.bold, letterSpacing: -0.52))),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Announcement :', style: TextStyle(fontFamily: 'Raleway', fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 12),
                        _buildNotificationCard('Monthly meeting schedule for November is now available'),
                        _buildNotificationCard('Attendance policy updated  please read the new guidelines'),
                        _buildSeeMoreButton(),
                        const SizedBox(height: 18),
                        const Text('News :', style: TextStyle(fontFamily: 'Raleway', fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 12),
                        _buildNotificationCard('Leo Club of Colombo recognized as Best Community Service Club 2025!'),
                        _buildNotificationCard('New message from Club President'),
                        _buildSeeMoreButton(),
                        const SizedBox(height: 18),
                        const Text('Notifications :', style: TextStyle(fontFamily: 'Raleway', fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 12),
                        _buildNotificationCard('Membership renewal due soon. Don\'t forget to renew before Nov 15'),
                        _buildNotificationCard('Your profile has been updated successfully'),
                        _buildSeeMoreButton(),
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
