import 'package:flutter/material.dart';
import '../../data/models/post.dart';
import '../../data/models/user.dart';
import '../../services/like_comment_manager.dart';

/// Comment Dialog Widget
/// 
/// A draggable bottom sheet for viewing and adding comments
/// Features:
/// - Draggable scrollable sheet
/// - Keyboard-aware input field
/// - Instant comment display (frontend only)
/// - Beautiful comment bubbles
class CommentDialogWidget extends StatefulWidget {
  final Post post;
  final User? currentUser;
  final VoidCallback? onCommentAdded;

  const CommentDialogWidget({
    super.key,
    required this.post,
    this.currentUser,
    this.onCommentAdded,
  });

  @override
  State<CommentDialogWidget> createState() => _CommentDialogWidgetState();
}

class _CommentDialogWidgetState extends State<CommentDialogWidget> {
  final TextEditingController _commentController = TextEditingController();
  final LikeCommentManager _likeManager = LikeCommentManager();
  final FocusNode _focusNode = FocusNode();
  
  List<Map<String, dynamic>> _localComments = [];

  @override
  void initState() {
    super.initState();
    _localComments = _likeManager.getLocalComments(widget.post.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final comment = {
      'userId': widget.currentUser?.id ?? 'guest',
      'userName': widget.currentUser?.fullName ?? 'Guest User',
      'userPhoto': widget.currentUser?.profilePhoto,
      'text': text,
      'createdAt': DateTime.now().toIso8601String(),
    };

    _likeManager.addComment(widget.post.id, comment);
    
    setState(() {
      _localComments = _likeManager.getLocalComments(widget.post.id);
    });
    
    _commentController.clear();
    _focusNode.unfocus();
    
    widget.onCommentAdded?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comments (${widget.post.commentsCount + _localComments.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Comments list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.post.comments.length + _localComments.length,
                  itemBuilder: (context, index) {
                    if (index < widget.post.comments.length) {
                      // Backend comments
                      final comment = widget.post.comments[index];
                      return _buildCommentItem(
                        userName: comment.userName,
                        userPhoto: comment.userPhoto,
                        text: comment.text,
                        createdAt: comment.createdAt,
                      );
                    } else {
                      // Local comments
                      final localIndex = index - widget.post.comments.length;
                      final comment = _localComments[localIndex];
                      return _buildCommentItem(
                        userName: comment['userName'] ?? 'Unknown',
                        userPhoto: comment['userPhoto'],
                        text: comment['text'] ?? '',
                        createdAt: DateTime.parse(comment['createdAt']),
                        isLocal: true,
                      );
                    }
                  },
                ),
              ),
              
              // Input field
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: bottomInset + 16,
                  top: 8,
                ),
                child: Row(
                  children: [
                    // User avatar
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFFFD700),
                      backgroundImage: widget.currentUser?.profilePhoto != null
                          ? NetworkImage(widget.currentUser!.profilePhoto!)
                          : null,
                      child: widget.currentUser?.profilePhoto == null
                          ? Text(
                              (widget.currentUser?.fullName ?? 'G')[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    
                    // Input field
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _commentController,
                          focusNode: _focusNode,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            border: InputBorder.none,
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _addComment(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Send button
                    GestureDetector(
                      onTap: _addComment,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentItem({
    required String userName,
    String? userPhoto,
    required String text,
    required DateTime createdAt,
    bool isLocal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: isLocal ? const Color(0xFFFFD700) : Colors.grey[300],
            backgroundImage: userPhoto != null ? NetworkImage(userPhoto) : null,
            child: userPhoto == null
                ? Text(
                    userName[0].toUpperCase(),
                    style: TextStyle(
                      color: isLocal ? Colors.black : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (isLocal) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Just now',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFB8860B),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(createdAt),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
