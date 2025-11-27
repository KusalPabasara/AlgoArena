import 'package:flutter/material.dart';
import '../../data/models/post.dart';
import '../../data/models/user.dart';
import '../../services/like_comment_manager.dart';
import 'comment_dialog.dart';

/// Post Like and Comment Widget
/// 
/// A widget that displays like and comment buttons with counts
/// Features:
/// - Gold heart icon when liked, outline when not
/// - Instant UI updates (no backend delay)
/// - Comment button opens draggable comment sheet
class PostLikeCommentWidget extends StatefulWidget {
  final Post post;
  final User? currentUser;
  final VoidCallback? onLikeChanged;

  const PostLikeCommentWidget({
    super.key,
    required this.post,
    this.currentUser,
    this.onLikeChanged,
  });

  @override
  State<PostLikeCommentWidget> createState() => _PostLikeCommentWidgetState();
}

class _PostLikeCommentWidgetState extends State<PostLikeCommentWidget>
    with SingleTickerProviderStateMixin {
  final LikeCommentManager _likeManager = LikeCommentManager();
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _heartScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _handleLike() {
    // Animate heart
    _heartController.forward().then((_) => _heartController.reverse());
    
    // Toggle like state
    _likeManager.handleLike(widget.post, widget.currentUser);
    
    // Update UI
    setState(() {});
    
    // Notify parent if needed
    widget.onLikeChanged?.call();
  }

  void _openCommentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentDialogWidget(
        post: widget.post,
        currentUser: widget.currentUser,
        onCommentAdded: () {
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = _likeManager.isPostLiked(widget.post, widget.currentUser);
    final likesCount = _likeManager.getPostLikesCount(widget.post);
    final commentsCount = _likeManager.getPostCommentsCount(widget.post);

    return Row(
      children: [
        // Like button
        GestureDetector(
          onTap: _handleLike,
          child: Row(
            children: [
              ScaleTransition(
                scale: _heartScale,
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? const Color(0xFFDAA520) : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                likesCount.toString(),
                style: TextStyle(
                  color: isLiked ? const Color(0xFFDAA520) : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 24),
        
        // Comment button
        GestureDetector(
          onTap: _openCommentDialog,
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: Colors.grey[600],
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                commentsCount.toString(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Share button
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Share feature coming soon!'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Icon(
            Icons.share_outlined,
            color: Colors.grey[600],
            size: 22,
          ),
        ),
      ],
    );
  }
}
