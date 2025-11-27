class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhoto;
  final String content;
  final List<String> images;
  final List<String> likes;
  final List<Comment> comments;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhoto,
    required this.content,
    required this.images,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] ?? json['id'] ?? '',
      authorId: json['author']?['_id'] ?? json['author'] ?? '',
      authorName: json['author']?['fullName'] ?? 'Unknown User',
      authorPhoto: json['author']?['profilePhoto'],
      content: json['content'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      likes: List<String>.from(json['likes'] ?? []),
      comments: (json['comments'] as List?)
              ?.map((c) => Comment.fromJson(c))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'author': authorId,
      'content': content,
      'images': images,
      'likes': likes,
      'comments': comments.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }

  int get likesCount => likes.length;
  int get commentsCount => comments.length;
}

class Comment {
  final String userId;
  final String userName;
  final String? userPhoto;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userId: json['user']?['_id'] ?? json['user'] ?? '',
      userName: json['user']?['fullName'] ?? 'Unknown User',
      userPhoto: json['user']?['profilePhoto'],
      text: json['text'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

