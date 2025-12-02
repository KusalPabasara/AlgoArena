import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import '../../../services/leo_assist_service.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/custom_back_button.dart';
import '../../../utils/responsive_utils.dart';

/// Leo Assist Screen - Exact Figma Implementation with CATMS API Integration
/// Source: Leo assist/src/imports/LeoAssist.tsx with svg-2y6j7mrshz.ts
/// API: CATMS Assistance chatbot
class LeoAssistScreen extends StatefulWidget {
  const LeoAssistScreen({super.key});

  @override
  State<LeoAssistScreen> createState() => _LeoAssistScreenState();
}

class _LeoAssistScreenState extends State<LeoAssistScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final LeoAssistService _chatService = LeoAssistService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  // Track feedback state for each message (index -> 'like', 'dislike', or null)
  final Map<int, String?> _messageFeedback = {};
  
  late AnimationController _animationController;
  late Animation<Offset> _bubblesSlideAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _bubblesFadeAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Bubbles animation - coming from outside (top-left)
    _bubblesSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _bubblesFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    // Content animation - coming from bottom
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    // Start animation immediately
    _animationController.forward();
    
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
    _animationController.dispose();
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


  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Bubbles - animated to slide in from outside
            FadeTransition(
              opacity: _bubblesFadeAnimation,
              child: SlideTransition(
                position: _bubblesSlideAnimation,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Bubble 02 - Yellow top left, rotated 158°
            Positioned(
              left: -131.97,
              top: -205.67,
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
            ),

            // Bubble 01 - Black bottom right
            Positioned(
              left: 283.73,
              top: 41,
                    child: SizedBox(
                      width: 243.628,
                      height: 266.77,
                      child: CustomPaint(
                        painter: _Bubble01Painter(),
                      ),
                    ),
                    ),
                  ],
                ),
              ),
            ),

            // Back button - top left
            CustomBackButton(
              backgroundColor: Colors.white, // White background, so button will be black
              iconSize: 24,
            ),

            // "Leo Assist" title - Figma: left: calc(16.67% + 2px), top: 48px
            Positioned(
              left: MediaQuery.of(context).size.width * 0.1667 + ResponsiveUtils.dp(2),
              top: ResponsiveUtils.bh(48),
              child: Text(
                'Leo Assist',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: ResponsiveUtils.dp(50),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: -ResponsiveUtils.dp(0.52),
                  height: 1.0,
                ),
              ),
            ),

            // Small attractive topic with icon background - positioned between title and chat box
            Positioned(
              left: ResponsiveUtils.spacingM,
              top: ResponsiveUtils.bh(120), // Between title (48) and chat box (185)
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.dp(16),
                  vertical: ResponsiveUtils.dp(10),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2), // Light yellow background
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                children: [
                    // Icon background circle
                  Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                      shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                    ),
                      child: Center(
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ),
                  ),
                    const SizedBox(width: 10),
                    // Text
                  const Text(
                    'LeoAssist',
                    style: TextStyle(
                      fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      color: Colors.black,
                        letterSpacing: 0.5,
                    ),
                  ),
                ],
                ),
              ),
            ),

            // Chat messages area - animated to slide up from bottom
            Positioned(
              left: 0,
              right: 0,
              // Positioned below the topic pill (which is at 120 + ~50 height = ~170)
              top: ResponsiveUtils.bh(200),
              // Space for input section (footer) on all screen sizes
              bottom: ResponsiveUtils.bh(200),
              child: FadeTransition(
                opacity: _contentFadeAnimation,
                child: SlideTransition(
                  position: _contentSlideAnimation,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(35)),
                      child: Container(
                        width: ResponsiveUtils.dp(375),
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height - ResponsiveUtils.bh(380), // Account for top and bottom spacing
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1), // Transparent background
                          borderRadius: BorderRadius.circular(ResponsiveUtils.r(35)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.spacingM + ResponsiveUtils.dp(4),
                            vertical: ResponsiveUtils.spacingM - ResponsiveUtils.dp(6),
                          ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildLoadingIndicator();
                  }
                              return _buildMessageBubble(_messages[index], index);
                },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Footer with tags and text area
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacingM,
                    vertical: ResponsiveUtils.dp(8),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: ResponsiveUtils.dp(16),
                        offset: Offset(0, -ResponsiveUtils.dp(4)),
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
                            SizedBox(width: ResponsiveUtils.dp(8)),
                            _buildTag('What is Leo club?'),
                            SizedBox(width: ResponsiveUtils.dp(8)),
                            _buildTag('FAQs'),
                          ],
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.dp(8)),

                      // Text input area with attractive design
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.dp(12),
                          vertical: ResponsiveUtils.dp(6),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(ResponsiveUtils.r(25)),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Type your message here...',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: ResponsiveUtils.bodyMedium,
                                    fontWeight: FontWeight.normal,
                                    color: const Color(0xFF888888),
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveUtils.dp(4),
                                    vertical: ResponsiveUtils.dp(6),
                                  ),
                                ),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: ResponsiveUtils.bodyMedium,
                                  color: Colors.black,
                                ),
                                maxLines: 3,
                                minLines: 1,
                                textCapitalization: TextCapitalization.sentences,
                                onSubmitted: _sendMessage,
                              ),
                            ),
                            SizedBox(width: ResponsiveUtils.dp(8)),
                            GestureDetector(
                              onTap: () => _sendMessage(_messageController.text),
                              child: Container(
                                width: ResponsiveUtils.dp(40),
                                height: ResponsiveUtils.dp(40),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFF8F7902),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(ResponsiveUtils.r(24)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700).withOpacity(0.3),
                                      blurRadius: ResponsiveUtils.dp(8),
                                      offset: Offset(0, ResponsiveUtils.dp(2)),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: ResponsiveUtils.iconSize,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int messageIndex) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final profilePhoto = user?.profilePhoto;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: message.isBot 
                ? Offset(-30 * (1 - value), 0) 
                : Offset(30 * (1 - value), 0),
            child: Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            message.isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if (message.isBot) ...[
                      // Bot message with bubble tail pointing down-left
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                      width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Message bubble with tail
                                    ClipPath(
                                      clipper: _BubbleClipper(tailDirection: TailDirection.downLeft),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                                          color: const Color(0xFF8F7902), // Golden-brown color
                                          borderRadius: BorderRadius.circular(16),
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
                                            const SizedBox(height: 4),
                                            // Timestamp
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
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Like and Unlike buttons below the bubble - aligned to right side of bubble
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(width: 44), // Spacer to align with bubble (avatar + spacing)
                              Flexible(
                                child: Container(),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_messageFeedback[messageIndex] == 'like') {
                                          _messageFeedback[messageIndex] = null; // Toggle off
                                        } else {
                                          _messageFeedback[messageIndex] = 'like';
                                        }
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: _messageFeedback[messageIndex] == 'like'
                                            ? const Color(0xFF4CAF50) // Green when selected
                                            : const Color(0xFFFFD700), // Yellow when not selected
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.thumb_up,
                                        size: 16,
                                        color: _messageFeedback[messageIndex] == 'like'
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_messageFeedback[messageIndex] == 'dislike') {
                                          _messageFeedback[messageIndex] = null; // Toggle off
                                        } else {
                                          _messageFeedback[messageIndex] = 'dislike';
                                        }
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                      padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                        color: _messageFeedback[messageIndex] == 'dislike'
                                            ? const Color(0xFFF44336) // Red when selected
                                            : const Color(0xFFFFD700), // Yellow when not selected
                                        shape: BoxShape.circle,
                                ),
                                      child: Icon(
                                        Icons.thumb_down,
                                        size: 16,
                                        color: _messageFeedback[messageIndex] == 'dislike'
                                            ? Colors.white
                                            : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                ),
              ],
            ),
          ] else ...[
                      // User message with profile photo
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
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
                          ),
                          const SizedBox(width: 8),
                          // User profile photo
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: profilePhoto != null && profilePhoto.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: profilePhoto,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Image.asset(
                                        'assets/images/profile/avatar_artist.png',
                                        fit: BoxFit.cover,
                                      ),
                                      errorWidget: (context, url, error) => Image.asset(
                                        'assets/images/profile/avatar_artist.png',
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/images/profile/avatar_artist.png',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ],
            ),
          ],
        ],
                ),
              ),
            ),
      ),
        );
      },
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
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                width: 24,
                  height: 24,
                  fit: BoxFit.cover,
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
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.dp(16),
          vertical: ResponsiveUtils.dp(8),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F6),
          borderRadius: BorderRadius.circular(ResponsiveUtils.r(20)),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: ResponsiveUtils.bodySmall,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF444444),
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

// Removed _WappGPTLogoPainter and _WappGPTLogoSmallPainter - now using Image.asset('assets/images/logo.png')

/// Bubble Clipper - Creates a bubble shape with a tail
class _BubbleClipper extends CustomClipper<Path> {
  final TailDirection tailDirection;

  _BubbleClipper({required this.tailDirection});

  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = 16.0;
    final tailSize = 12.0;

    switch (tailDirection) {
      case TailDirection.downLeft:
        // Rounded rectangle with tail pointing down-left
        path.moveTo(radius, 0);
        path.lineTo(size.width - radius, 0);
        path.quadraticBezierTo(size.width, 0, size.width, radius);
        path.lineTo(size.width, size.height - radius);
        path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
        // Tail pointing down-left
        path.lineTo(tailSize + radius, size.height);
        path.lineTo(tailSize, size.height + tailSize);
        path.lineTo(0, size.height);
        path.quadraticBezierTo(0, size.height, 0, size.height - radius);
        path.lineTo(0, radius);
        path.quadraticBezierTo(0, 0, radius, 0);
        break;
      case TailDirection.downRight:
        path.moveTo(radius, 0);
        path.lineTo(size.width - radius, 0);
        path.quadraticBezierTo(size.width, 0, size.width, radius);
        path.lineTo(size.width, size.height - radius);
        path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
        path.lineTo(size.width - tailSize - radius, size.height);
        path.lineTo(size.width - tailSize, size.height + tailSize);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width, size.height - radius);
        path.lineTo(size.width, radius);
        path.lineTo(size.width - radius, 0);
        path.lineTo(radius, 0);
        path.quadraticBezierTo(0, 0, 0, radius);
        path.lineTo(0, size.height - radius);
        path.quadraticBezierTo(0, size.height, radius, size.height);
        path.close();
        break;
      case TailDirection.upLeft:
        path.moveTo(radius, 0);
        path.lineTo(tailSize + radius, 0);
        path.lineTo(tailSize, -tailSize);
        path.lineTo(0, 0);
        path.quadraticBezierTo(0, 0, 0, radius);
        path.lineTo(0, size.height - radius);
        path.quadraticBezierTo(0, size.height, radius, size.height);
        path.lineTo(size.width - radius, size.height);
        path.quadraticBezierTo(size.width, size.height, size.width, size.height - radius);
        path.lineTo(size.width, radius);
        path.quadraticBezierTo(size.width, 0, size.width - radius, 0);
        path.close();
        break;
      case TailDirection.upRight:
        path.moveTo(radius, 0);
        path.lineTo(size.width - radius, 0);
        path.quadraticBezierTo(size.width, 0, size.width, radius);
        path.lineTo(size.width, size.height - radius);
        path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
        path.lineTo(radius, size.height);
        path.quadraticBezierTo(0, size.height, 0, size.height - radius);
        path.lineTo(0, radius);
        path.quadraticBezierTo(0, 0, radius, 0);
        path.close();
        break;
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Bubble Tail Direction
enum TailDirection { downLeft, downRight, upLeft, upRight }

// Removed _BubbleTailPainter - now using _BubbleClipper for bubble shape with tail
