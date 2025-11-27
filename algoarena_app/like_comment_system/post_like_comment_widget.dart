import 'package:flutter/material.dart';
import 'post_model.dart';
import 'user_model.dart';

/// Post Like and Comment System Widget
/// 
/// Features:
/// - Frontend-only like system (no backend calls)
/// - Frontend-only comment system (no backend calls)
/// - Instant UI updates
/// - Comment dialog with keyboard handling
/// - Like icon changes color when liked (gold)
/// - Comment count updates instantly
class PostLikeCommentWidget extends StatelessWidget {
  final Post post;
  final User? currentUser;
  final bool isLiked;
  final int likesCount;
  final int commentsCount;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const PostLikeCommentWidget({
    super.key,
    required this.post,
    this.currentUser,
    required this.isLiked,
    required this.likesCount,
    required this.commentsCount,
    required this.onLike,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Post actions - Like, Comment, Share, Bookmark
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Like
              GestureDetector(
                onTap: onLike,
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  isLiked 
                      ? Icons.favorite 
                      : Icons.favorite_border,
                  size: 24,
                  color: isLiked 
                      ? const Color(0xFFFFD700) // Gold color
                      : Colors.black,
                ),
              ),
              const SizedBox(width: 16),
              // Comment
              GestureDetector(
                onTap: onComment,
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 24,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 16),
              // Share
              GestureDetector(
                onTap: () {},
                child: Transform.rotate(
                  angle: -0.5,
                  child: const Icon(
                    Icons.send_outlined,
                    size: 22,
                    color: Colors.black,
                  ),
                ),
              ),
              const Spacer(),
              // Bookmark
              GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.bookmark_border,
                  size: 24,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        // Likes count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$likesCount likes',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        // Comments count
        if (commentsCount > 0)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: onComment,
                child: Text(
                  'View all $commentsCount comments',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

