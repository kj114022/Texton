import 'attachment.dart';

/// Represents a post in a thread (OP or reply)
/// Follows 4chan's philosophy: anonymous by default, time-based ordering
class Post {
  final String id;
  final String threadId;      // Same as id for OP, parent thread id for replies
  final String boardId;
  final String? authorName;   // Null = "Anonymous"
  final String? tripcode;     // Optional identity verification
  final String content;
  final List<Attachment> attachments;
  final List<String> replyToIds;  // Posts this one replies to (>>postId)
  final DateTime createdAt;
  final DateTime? bumpedAt;   // Only for OP posts, updated when thread is bumped
  final int replyCount;       // Only for OP posts
  final int imageCount;       // Only for OP posts
  final bool isOp;            // Is this the original poster?
  final bool isSaged;         // Reply without bumping
  final bool isSticky;        // Pinned to top
  final bool isLocked;        // No more replies allowed

  const Post({
    required this.id,
    required this.threadId,
    required this.boardId,
    this.authorName,
    this.tripcode,
    required this.content,
    this.attachments = const [],
    this.replyToIds = const [],
    required this.createdAt,
    this.bumpedAt,
    this.replyCount = 0,
    this.imageCount = 0,
    this.isOp = false,
    this.isSaged = false,
    this.isSticky = false,
    this.isLocked = false,
  });

  String get displayName => authorName ?? 'Anonymous';
  
  String get displayId => 'No.${id.substring(0, 8)}';

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  bool get hasImage => attachments.any((a) => a.isImage);
  bool get hasFile => attachments.isNotEmpty;

  Attachment? get primaryImage => 
      attachments.where((a) => a.isImage).firstOrNull;

  Post copyWith({
    String? id,
    String? threadId,
    String? boardId,
    String? authorName,
    String? tripcode,
    String? content,
    List<Attachment>? attachments,
    List<String>? replyToIds,
    DateTime? createdAt,
    DateTime? bumpedAt,
    int? replyCount,
    int? imageCount,
    bool? isOp,
    bool? isSaged,
    bool? isSticky,
    bool? isLocked,
  }) {
    return Post(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      boardId: boardId ?? this.boardId,
      authorName: authorName ?? this.authorName,
      tripcode: tripcode ?? this.tripcode,
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
      replyToIds: replyToIds ?? this.replyToIds,
      createdAt: createdAt ?? this.createdAt,
      bumpedAt: bumpedAt ?? this.bumpedAt,
      replyCount: replyCount ?? this.replyCount,
      imageCount: imageCount ?? this.imageCount,
      isOp: isOp ?? this.isOp,
      isSaged: isSaged ?? this.isSaged,
      isSticky: isSticky ?? this.isSticky,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

/// Represents a complete thread (OP + replies)
class Thread {
  final Post op;
  final List<Post> replies;

  const Thread({
    required this.op,
    this.replies = const [],
  });

  String get id => op.id;
  String get boardId => op.boardId;
  DateTime get bumpedAt => op.bumpedAt ?? op.createdAt;
  int get replyCount => replies.length;
  int get imageCount => replies.where((r) => r.hasImage).length + (op.hasImage ? 1 : 0);
  bool get isSticky => op.isSticky;
  bool get isLocked => op.isLocked;

  /// Get preview replies (last few replies like 4chan catalog)
  List<Post> get previewReplies {
    if (replies.length <= 3) return replies;
    return replies.sublist(replies.length - 3);
  }
}
