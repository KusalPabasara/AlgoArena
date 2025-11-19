import 'package:flutter/material.dart';

/// Leo Assist Screen - Exact Figma Implementation 395:1574
class LeoAssistScreen extends StatelessWidget {
  const LeoAssistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(right: -180, bottom: 150, child: Container(width: 450, height: 450, decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.22), shape: BoxShape.circle))),
          Positioned(left: -110, top: -120, child: Container(width: 280, height: 280, decoration: BoxDecoration(color: Colors.black.withOpacity(0.035), shape: BoxShape.circle))),
          SafeArea(
            child: Column(
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
                      const Positioned(left: 67, top: 58, child: Text('LeoAssist', style: TextStyle(color: Colors.white, fontFamily: 'Raleway', fontSize: 50, fontWeight: FontWeight.bold, letterSpacing: -0.52))),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFFFD700), shape: BoxShape.circle), child: const Center(child: Text('L', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)))),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8F7902).withOpacity(0.77),
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Hello Kusal ! How can I help you today?', style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: Colors.white, height: 1.4)),
                                    SizedBox(height: 8),
                                    Text('7:20', style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildSuggestionChip('What is LeoAssist?'),
                            _buildSuggestionChip('What is Leo club?'),
                            _buildSuggestionChip('FAQs'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(color: const Color(0xFFE8EBF0), borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: const [
                              Expanded(child: Text('Type your message here...', style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: Colors.black54))),
                              Icon(Icons.send, size: 24, color: Color(0xFFFFD700)),
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

  Widget _buildSuggestionChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFF3F5F6), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
    );
  }
}
