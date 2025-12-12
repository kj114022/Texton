import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/models/board.dart';
import '../data/models/post.dart';
import '../data/models/attachment.dart';

const _uuid = Uuid();

/// State for the feed/board system
class FeedState {
  final Board currentBoard;
  final List<Thread> threads;
  final bool isLoading;
  final String? error;
  final FeedViewMode viewMode;

  const FeedState({
    required this.currentBoard,
    this.threads = const [],
    this.isLoading = false,
    this.error,
    this.viewMode = FeedViewMode.timeline,
  });

  FeedState copyWith({
    Board? currentBoard,
    List<Thread>? threads,
    bool? isLoading,
    String? error,
    FeedViewMode? viewMode,
  }) {
    return FeedState(
      currentBoard: currentBoard ?? this.currentBoard,
      threads: threads ?? this.threads,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      viewMode: viewMode ?? this.viewMode,
    );
  }
}

enum FeedViewMode { timeline, catalog }

/// Feed notifier implementing 4chan-style thread mechanics
class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier()
      : super(FeedState(currentBoard: Board.defaultBoards.first)) {
    _loadMockData();
  }

  void _loadMockData() {
    // Create mock threads for demonstration
    final now = DateTime.now();
    final mockThreads = <Thread>[
      Thread(
        op: Post(
          id: _uuid.v4(),
          threadId: '',
          boardId: 'books',
          content: 'Just finished reading "The Pragmatic Programmer". '
              'Absolutely life-changing for any developer. '
              'What are your favorite programming books?',
          attachments: [
            Attachment(
              id: _uuid.v4(),
              url: 'https://example.com/book.jpg',
              fileName: 'pragmatic_programmer.jpg',
              mimeType: 'image/jpeg',
              sizeBytes: 256000,
            ),
          ],
          createdAt: now.subtract(const Duration(hours: 2)),
          bumpedAt: now.subtract(const Duration(minutes: 15)),
          replyCount: 23,
          imageCount: 5,
          isOp: true,
        ),
        replies: [],
      ),
      Thread(
        op: Post(
          id: _uuid.v4(),
          threadId: '',
          boardId: 'books',
          authorName: 'BookWorm',
          tripcode: '!kX92mZ',
          content: 'Sharing my entire sci-fi collection. '
              'Over 500 EPUBs, mostly classics. '
              'Download link in the file.',
          attachments: [
            Attachment(
              id: _uuid.v4(),
              url: 'https://example.com/collection.zip',
              fileName: 'scifi_collection.zip',
              mimeType: 'application/zip',
              sizeBytes: 1024 * 1024 * 150,
            ),
          ],
          createdAt: now.subtract(const Duration(hours: 5)),
          bumpedAt: now.subtract(const Duration(hours: 1)),
          replyCount: 89,
          imageCount: 12,
          isOp: true,
          isSticky: true,
        ),
        replies: [],
      ),
      Thread(
        op: Post(
          id: _uuid.v4(),
          threadId: '',
          boardId: 'books',
          content: 'Looking for recommendations on philosophy books. '
              'Already read Nietzsche and Sartre. '
              'What should I read next?',
          attachments: [],
          createdAt: now.subtract(const Duration(hours: 8)),
          bumpedAt: now.subtract(const Duration(hours: 3)),
          replyCount: 45,
          imageCount: 2,
          isOp: true,
        ),
        replies: [],
      ),
    ];

    // Sort by bump time (4chan style - most recently bumped first)
    // Sticky threads always on top
    mockThreads.sort((a, b) {
      if (a.isSticky && !b.isSticky) return -1;
      if (!a.isSticky && b.isSticky) return 1;
      return b.bumpedAt.compareTo(a.bumpedAt);
    });

    state = state.copyWith(threads: mockThreads);
  }

  void switchBoard(Board board) {
    state = state.copyWith(
      currentBoard: board,
      isLoading: true,
    );
    // In real app, fetch threads for this board
    _loadMockData();
    state = state.copyWith(isLoading: false);
  }

  void toggleViewMode() {
    state = state.copyWith(
      viewMode: state.viewMode == FeedViewMode.timeline
          ? FeedViewMode.catalog
          : FeedViewMode.timeline,
    );
  }

  /// Create a new thread (OP post)
  void createThread({
    required String content,
    List<Attachment> attachments = const [],
    String? authorName,
    String? tripcode,
  }) {
    final now = DateTime.now();
    final threadId = _uuid.v4();

    final op = Post(
      id: threadId,
      threadId: threadId,
      boardId: state.currentBoard.id,
      authorName: authorName,
      tripcode: tripcode,
      content: content,
      attachments: attachments,
      createdAt: now,
      bumpedAt: now,
      isOp: true,
    );

    final newThread = Thread(op: op);
    final threads = [newThread, ...state.threads];

    state = state.copyWith(threads: threads);
  }

  /// Reply to a thread (bumps unless saged)
  void replyToThread({
    required String threadId,
    required String content,
    List<Attachment> attachments = const [],
    List<String> replyToIds = const [],
    String? authorName,
    String? tripcode,
    bool sage = false,
  }) {
    final now = DateTime.now();
    final postId = _uuid.v4();

    final reply = Post(
      id: postId,
      threadId: threadId,
      boardId: state.currentBoard.id,
      authorName: authorName,
      tripcode: tripcode,
      content: content,
      attachments: attachments,
      replyToIds: replyToIds,
      createdAt: now,
      isSaged: sage,
    );

    final threads = state.threads.map((thread) {
      if (thread.id != threadId) return thread;

      final updatedOp = sage
          ? thread.op
          : thread.op.copyWith(bumpedAt: now);

      return Thread(
        op: updatedOp.copyWith(
          replyCount: thread.replyCount + 1,
          imageCount: thread.imageCount + (reply.hasImage ? 1 : 0),
        ),
        replies: [...thread.replies, reply],
      );
    }).toList();

    // Re-sort by bump time if not saged
    if (!sage) {
      threads.sort((a, b) {
        if (a.isSticky && !b.isSticky) return -1;
        if (!a.isSticky && b.isSticky) return 1;
        return b.bumpedAt.compareTo(a.bumpedAt);
      });
    }

    state = state.copyWith(threads: threads);
  }
}

/// Provider for feed state
final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>(
  (ref) => FeedNotifier(),
);

/// Provider for current thread being viewed
final currentThreadProvider = StateProvider<Thread?>((ref) => null);

/// Provider for available boards
final boardsProvider = Provider<List<Board>>((ref) => Board.defaultBoards);
