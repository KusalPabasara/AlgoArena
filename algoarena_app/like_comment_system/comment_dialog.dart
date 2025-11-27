import 'package:flutter/material.dart';
import 'colors.dart';
import 'post_model.dart';
import 'user_model.dart';

/// Comment Dialog Widget
/// 
/// Features:
/// - Draggable scrollable sheet
/// - Keyboard-aware input field
/// - Instant comment display
/// - Real-time comment updates
/// - Time formatting
class CommentDialogWidget extends StatefulWidget {
  final Post post;
  final User? currentUser;
  final List<Map<String, dynamic>> initialComments;
  final Function(Map<String, dynamic>) onCommentAdded;
  final String Function(DateTime) formatTime;

  const CommentDialogWidget({
    super.key,
    required this.post,
    this.currentUser,
    required this.initialComments,
    required this.onCommentAdded,
    required this.formatTime,
  });

  @override
  State<CommentDialogWidget> createState() => _CommentDialogWidgetState();
}

class _CommentDialogWidgetState extends State<CommentDialogWidget> {
  final TextEditingController _commentController = TextEditingController();
  late List<Map<String, dynamic>> _comments;

  @override
  void initState() {
    super.initState();
    // Combine backend comments with initial local comments
    final backendComments = widget.post.comments.map((comment) => {
      'text': comment.text,
      'authorName': comment.userName,
      'authorId': comment.userId,
      'timestamp': comment.createdAt,
    }).toList();
    _comments = [...backendComments, ...widget.initialComments];
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment(String text) {
    if (text.trim().isEmpty) return;

    final newComment = {
      'text': text.trim(),
      'authorName': widget.currentUser?.fullName ?? 'You',
      'authorId': widget.currentUser?.id ?? '',
      'timestamp': DateTime.now(),
    };

    setState(() {
      _comments.add(newComment);
    });

    // Notify parent
    widget.onCommentAdded(newComment);

    // Clear input
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
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
                          final authorName = comment['authorName'] as String;
                          final firstLetter = authorName.isNotEmpty 
                              ? authorName[0].toUpperCase() 
                              : '?';
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.grey[300],
                                  child: Text(
                                    firstLetter,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              authorName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              comment['text'] as String,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.formatTime(comment['timestamp'] as DateTime),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              // Comment input - fixed at bottom
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          onSubmitted: _addComment,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: AppColors.primary),
                        onPressed: () => _addComment(_commentController.text),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

