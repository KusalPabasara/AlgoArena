import 'package:flutter/material.dart';
import '../../data/models/post.dart';
import '../../data/models/user.dart';
import '../../data/repositories/post_repository.dart';

/// Comment Dialog Widget
/// 
/// A draggable bottom sheet for viewing and adding comments
/// Features:
/// - Draggable scrollable sheet
/// - Keyboard-aware input field
/// - Instant comment display with backend persistence
/// - Real-time comment count updates
class CommentDialogWidget extends StatefulWidget {
  final Post post;
  final User? currentUser;
  final Function(Map<String, dynamic>)? onCommentAdded;

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
  final FocusNode _focusNode = FocusNode();
  final PostRepository _postRepository = PostRepository();
  
  // Simple list - comments stay here once added, never removed unless error
  List<Map<String, dynamic>> _comments = [];
  int _commentsCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeComments();
  }

  void _initializeComments() {
    // Load from backend post
    final backendComments = widget.post.comments.map((comment) {
      return {
        'id': '${comment.userId}_${comment.createdAt.millisecondsSinceEpoch}',
        'text': comment.text,
        'authorName': comment.userName,
        'authorId': comment.userId,
        'timestamp': comment.createdAt,
      };
    }).toList();
    
    // Combine and sort (newest first)
    _comments = backendComments;
    _commentsCount = _comments.length;
    _sortComments();
  }

  void _sortComments() {
    _comments.sort((a, b) {
      final timeA = (a['timestamp'] as DateTime).millisecondsSinceEpoch;
      final timeB = (b['timestamp'] as DateTime).millisecondsSinceEpoch;
      return timeB.compareTo(timeA); // Newest first
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    // Create a unique ID for this comment
    final commentId = '${widget.currentUser?.id ?? 'user'}_${now.millisecondsSinceEpoch}';
    
    // Create new comment object
    final newComment = {
      'id': commentId,
      'text': text,
      'authorName': widget.currentUser?.fullName ?? 'You',
      'authorId': widget.currentUser?.id ?? '',
      'timestamp': now,
    };

    // Add to UI immediately (at top)
    setState(() {
      _comments.insert(0, newComment);
      _commentsCount = _comments.length;
    });

    // Update parent count immediately
    widget.onCommentAdded?.call(newComment);

    // Clear input
    _commentController.clear();
    _focusNode.unfocus();

    // Save to backend (async - comment already visible)
    _postRepository.addComment(widget.post.id, text).then((savedComment) {
      // Update with saved data (in case backend returns different ID)
      if (mounted) {
        setState(() {
          // Find our comment and update it
          final index = _comments.indexWhere((c) => c['id'] == commentId);
          if (index != -1) {
            // Update with saved comment data
            _comments[index] = {
              'id': '${savedComment.userId}_${savedComment.createdAt.millisecondsSinceEpoch}',
              'text': savedComment.text,
              'authorName': savedComment.userName,
              'authorId': savedComment.userId,
              'timestamp': savedComment.createdAt,
            };
            _sortComments();
          }
        });
      }
    }).catchError((e) {
      // Only remove on error
      if (mounted) {
        setState(() {
          _comments.removeWhere((c) => c['id'] == commentId);
          _commentsCount = _comments.length;
        });
        widget.onCommentAdded?.call({'_remove': true});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
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
                      'Comments (${_commentsCount})',
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
                child: _comments.isEmpty
                    ? const Center(
                        child: Text(
                          'No comments yet.\nBe the first to comment!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return _buildCommentItem(
                            userName: comment['authorName'] ?? 'Unknown',
                            userPhoto: null, // Can be added if needed
                            text: comment['text'] ?? '',
                            createdAt: comment['timestamp'] as DateTime,
                          );
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[300],
            backgroundImage: userPhoto != null ? NetworkImage(userPhoto) : null,
            child: userPhoto == null
                ? Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.grey,
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
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black87,
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
