import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../services/leo_assist_service.dart';

/// Leo Assist Screen - Exact Figma Implementation with CATMS API Integration
/// Source: Leo assist/src/imports/LeoAssist.tsx with svg-2y6j7mrshz.ts
/// API: CATMS Assistance chatbot
class LeoAssistScreen extends StatefulWidget {
  const LeoAssistScreen({super.key});

  @override
  State<LeoAssistScreen> createState() => _LeoAssistScreenState();
}

class _LeoAssistScreenState extends State<LeoAssistScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final LeoAssistService _chatService = LeoAssistService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add initial greeting
    _messages.add(ChatMessage(
      text: 'Hello! How can I help you today?',
      isBot: true,
      time: _getCurrentTime(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isBot: false,
        time: _getCurrentTime(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await _chatService.sendMessage(text);
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isBot: true,
          time: _getCurrentTime(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'I apologize, I encountered an error. Please try again.',
          isBot: true,
          time: _getCurrentTime(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _handleTagTap(String tag) {
    _sendMessage(tag);
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Bubble 02 - Yellow top left, rotated 158°
            Positioned(
              left: -131.97,
              top: -205.67,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.rotate(
                      angle: 158 * math.pi / 180,
                      child: SizedBox(
                        width: 311.014,
                        height: 367.298,
                        child: CustomPaint(
                          painter: _Bubble02Painter(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bubble 01 - Black bottom right
            Positioned(
              left: 283.73,
              top: 41,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: SizedBox(
                      width: 243.628,
                      height: 266.77,
                      child: CustomPaint(
                        painter: _Bubble01Painter(),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Header with Logo and Brand Name
            Positioned(
              left: 2,
              top: 120,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: CustomPaint(
                      painter: _WappGPTLogoPainter(),
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Text(
                    'LeoAssist',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Back button
            Positioned(
              left: 10,
              top: 50,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: SizedBox(
                  width: 49.568,
                  height: 53,
                  child: Image.asset(
                    'assets/images/leo_assist/back_button.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Center(
                          child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Chat messages area
            Positioned(
              left: 11,
              top: 180,
              right: 11,
              bottom: 180,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildLoadingIndicator();
                  }
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),

            // Footer with tags and text area
            Positioned(
              left: 2,
              bottom: 35,
              child: Container(
                width: screenWidth - 4,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tag container
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTag('What is LeoAssist?'),
                          const SizedBox(width: 8),
                          _buildTag('What is Leo club?'),
                          const SizedBox(width: 8),
                          _buildTag('FAQs'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Text area
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EBF0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFF3F5F6),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Type your message here...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF444444),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              maxLines: 3,
                              minLines: 1,
                              onSubmitted: _sendMessage,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _sendMessage(_messageController.text),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8F7902),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom bar
            Positioned(
              left: screenWidth * 0.3333 - 2,
              bottom: 10,
              child: Container(
                width: 145.848,
                height: 5.442,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(34),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            message.isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if (message.isBot) ...[
            // Bot message with bubble tail
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Bot avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 25,
                      child: CustomPaint(
                        painter: _WappGPTLogoSmallPainter(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8F7902).withValues(alpha: 0.77),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              message.time,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Action buttons
                            GestureDetector(
                              onTap: () => _copyMessage(message.text),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.copy,
                                  size: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // User message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF031B4E),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.time,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD700),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 25,
                child: CustomPaint(
                  painter: _WappGPTLogoSmallPainter(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8F7902).withValues(alpha: 0.77),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5 + (0.5 * math.sin(value * math.pi * 2))),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildTag(String text) {
    return GestureDetector(
      onTap: () => _handleTagTap(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F6),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF444444).withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }
}

/// Chat message model
class ChatMessage {
  final String text;
  final bool isBot;
  final String time;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.time,
  });
}

/// Yellow Bubble 02 Painter - Exact Figma SVG path pe2b6900
class _Bubble02Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final path = Path();
    final scaleX = size.width / 325;
    final scaleY = size.height / 368;

    path.moveTo(142.573 * scaleX, 33.5385 * scaleY);
    path.cubicTo(
      221.639 * scaleX, -74.0067 * scaleY,
      324.97 * scaleX, 103.016 * scaleY,
      309.453 * scaleX, 200.418 * scaleY,
    );
    path.cubicTo(
      293.936 * scaleX, 297.821 * scaleY,
      234.738 * scaleX, 367.298 * scaleY,
      142.573 * scaleX, 367.298 * scaleY,
    );
    path.cubicTo(
      50.4079 * scaleX, 367.298 * scaleY,
      7.1557 * scaleX, 288.01 * scaleY,
      0.447188 * scaleX, 203.99 * scaleY,
    );
    path.cubicTo(
      -6.26132 * scaleX, 119.97 * scaleY,
      63.5071 * scaleX, 141.084 * scaleY,
      142.573 * scaleX, 33.5385 * scaleY,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Black Bubble 01 Painter - Exact Figma SVG path p2b951e00
class _Bubble01Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF02091A)
      ..style = PaintingStyle.fill;

    final path = Path();
    final scaleX = size.width / 244;
    final scaleY = size.height / 267;

    path.moveTo(122.23 * scaleX, 23.973 * scaleY);
    path.cubicTo(
      179.747 * scaleX, -54.2618 * scaleY,
      243.628 * scaleX, 78.3248 * scaleY,
      243.628 * scaleX, 145.371 * scaleY,
    );
    path.cubicTo(
      243.628 * scaleX, 212.418 * scaleY,
      189.276 * scaleX, 266.77 * scaleY,
      122.23 * scaleX, 266.77 * scaleY,
    );
    path.cubicTo(
      55.1834 * scaleX, 266.77 * scaleY,
      -8.01705 * scaleX, 215.723 * scaleY,
      0.831575 * scaleX, 145.371 * scaleY,
    );
    path.cubicTo(
      9.6802 * scaleX, 75.0195 * scaleY,
      64.7126 * scaleX, 102.208 * scaleY,
      122.23 * scaleX, 23.973 * scaleY,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// WappGPT Logo Painter - Main logo in header
class _WappGPTLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final darkBluePaint = Paint()
      ..color = const Color(0xFF162550)
      ..style = PaintingStyle.fill;

    final cyanPaint = Paint()
      ..color = const Color(0xFF04FED1)
      ..style = PaintingStyle.fill;

    final scale = size.width / 48;

    final mainPath = Path();
    mainPath.moveTo(33.9145 * scale, 25.0886 * scale);
    mainPath.cubicTo(31.2154 * scale, 26.1708 * scale, 28.302 * scale, 26.8383 * scale, 25.2548 * scale, 27.0112 * scale);
    mainPath.cubicTo(24.7292 * scale, 27.041 * scale, 24.1997 * scale, 27.0562 * scale, 23.6667 * scale, 27.0562 * scale);
    mainPath.cubicTo(23.1336 * scale, 27.0562 * scale, 22.6041 * scale, 27.041 * scale, 22.0786 * scale, 27.0112 * scale);
    mainPath.cubicTo(19.0306 * scale, 26.8382 * scale, 16.1165 * scale, 26.1705 * scale, 13.4169 * scale, 25.0878 * scale);
    mainPath.cubicTo(7.75158 * scale, 22.8158 * scale, 3.03083 * scale, 18.7165 * scale, 0 * scale, 13.5281 * scale);
    mainPath.cubicTo(4.72407 * scale, 5.44098 * scale, 13.5537 * scale, 0 * scale, 23.6667 * scale, 0 * scale);
    mainPath.cubicTo(33.7796 * scale, 0 * scale, 42.6093 * scale, 5.44098 * scale, 47.3333 * scale, 13.5281 * scale);
    mainPath.cubicTo(44.3022 * scale, 18.7171 * scale, 39.5807 * scale, 22.8167 * scale, 33.9145 * scale, 25.0886 * scale);
    mainPath.close();
    canvas.drawPath(mainPath, whitePaint);

    final visorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(12.2546 * scale, 10.0675 * scale, 22.8741 * scale, 8.08988 * scale),
      Radius.circular(4.04494 * scale),
    );
    canvas.drawRRect(visorRect, darkBluePaint);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(29.9997 * scale, 14.0675 * scale),
        width: 2.99542 * scale,
        height: 2.9663 * scale,
      ),
      cyanPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(17.6553 * scale, 14.0675 * scale),
        width: 2.99542 * scale,
        height: 2.9663 * scale,
      ),
      cyanPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(23.6455 * scale, 34.0224 * scale),
        width: 2.99542 * scale,
        height: 2.9663 * scale,
      ),
      darkBluePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(17.6553 * scale, 34.0224 * scale),
        width: 2.99542 * scale,
        height: 2.9663 * scale,
      ),
      darkBluePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(29.637 * scale, 34.0224 * scale),
        width: 2.99542 * scale,
        height: 2.9663 * scale,
      ),
      darkBluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// WappGPT Logo Small Painter - Logo in chat bubble
class _WappGPTLogoSmallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final darkBluePaint = Paint()
      ..color = const Color(0xFF162550)
      ..style = PaintingStyle.fill;

    final cyanPaint = Paint()
      ..color = const Color(0xFF04FED1)
      ..style = PaintingStyle.fill;

    final scale = size.width / 33;

    final mainPath = Path();
    mainPath.moveTo(23.0895 * scale, 17.2484 * scale);
    mainPath.cubicTo(21.2519 * scale, 17.9924 * scale, 19.2684 * scale, 18.4513 * scale, 17.1938 * scale, 18.5702 * scale);
    mainPath.cubicTo(16.836 * scale, 18.5907 * scale, 16.4755 * scale, 18.6011 * scale, 16.1126 * scale, 18.6011 * scale);
    mainPath.cubicTo(15.7497 * scale, 18.6011 * scale, 15.3892 * scale, 18.5907 * scale, 15.0314 * scale, 18.5702 * scale);
    mainPath.cubicTo(12.9563 * scale, 18.4513 * scale, 10.9724 * scale, 17.9922 * scale, 9.13444 * scale, 17.2479 * scale);
    mainPath.cubicTo(5.27739 * scale, 15.6859 * scale, 2.06343 * scale, 12.8676 * scale, 0 * scale, 9.30056 * scale);
    mainPath.cubicTo(3.21622 * scale, 3.74067 * scale, 9.22758 * scale, 0 * scale, 16.1126 * scale, 0 * scale);
    mainPath.cubicTo(22.9977 * scale, 0 * scale, 29.009 * scale, 3.74067 * scale, 32.2252 * scale, 9.30056 * scale);
    mainPath.cubicTo(30.1616 * scale, 12.868 * scale, 26.9471 * scale, 15.6865 * scale, 23.0895 * scale, 17.2484 * scale);
    mainPath.close();
    canvas.drawPath(mainPath, whitePaint);

    final visorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8.34305 * scale, 6.92138 * scale, 15.573 * scale, 5.5618 * scale),
      Radius.circular(2.7809 * scale),
    );
    canvas.drawRRect(visorRect, darkBluePaint);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(20.4241 * scale, 9.67142 * scale),
        width: 2.03932 * scale,
        height: 2.03932 * scale,
      ),
      cyanPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(12.0201 * scale, 9.67142 * scale),
        width: 2.03932 * scale,
        height: 2.03932 * scale,
      ),
      cyanPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(16.098 * scale, 23.3904 * scale),
        width: 2.03932 * scale,
        height: 2.03932 * scale,
      ),
      darkBluePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(12.0201 * scale, 23.3904 * scale),
        width: 2.03932 * scale,
        height: 2.03932 * scale,
      ),
      darkBluePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(20.1772 * scale, 23.3904 * scale),
        width: 2.03932 * scale,
        height: 2.03932 * scale,
      ),
      darkBluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
