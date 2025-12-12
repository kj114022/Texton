import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/board.dart';
import '../../providers/feed_provider.dart';
import 'widgets/thread_card.dart';
import 'widgets/catalog_grid.dart';
import 'widgets/board_selector.dart';

/// Feed screen with 4chan mechanics and Twitter visuals
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: CustomScrollView(
        slivers: [
          // Navigation bar with board selector and view toggle
          CupertinoSliverNavigationBar(
            backgroundColor: AppColors.surface.withValues(alpha: 0.95),
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.5),
            ),
            largeTitle: GestureDetector(
              onTap: () => _showBoardSelector(context, ref),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '/${feedState.currentBoard.shortName}/',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    CupertinoIcons.chevron_down,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => ref.read(feedProvider.notifier).toggleViewMode(),
                  child: Icon(
                    feedState.viewMode == FeedViewMode.timeline
                        ? CupertinoIcons.square_grid_2x2
                        : CupertinoIcons.list_bullet,
                    color: AppColors.primary,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _showComposeSheet(context, ref),
                  child: Icon(
                    CupertinoIcons.plus_circle_fill,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Board info header
          SliverToBoxAdapter(
            child: _BoardHeader(board: feedState.currentBoard),
          ),

          // Thread list or catalog grid
          if (feedState.isLoading)
            const SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator()),
            )
          else if (feedState.threads.isEmpty)
            SliverFillRemaining(child: _EmptyState())
          else if (feedState.viewMode == FeedViewMode.catalog)
            SliverToBoxAdapter(
              child: CatalogGrid(threads: feedState.threads),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final thread = feedState.threads[index];
                  return ThreadCard(
                    thread: thread,
                    onTap: () => _openThread(context, ref, thread),
                  ).animate().fadeIn(
                    delay: Duration(milliseconds: 50 * index),
                  );
                },
                childCount: feedState.threads.length,
              ),
            ),
        ],
      ),
    );
  }

  void _showBoardSelector(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => BoardSelector(
        onBoardSelected: (board) {
          ref.read(feedProvider.notifier).switchBoard(board);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showComposeSheet(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _ComposeSheet(),
    );
  }

  void _openThread(BuildContext context, WidgetRef ref, thread) {
    ref.read(currentThreadProvider.notifier).state = thread;
    // Navigate to thread detail
  }
}

class _BoardHeader extends StatelessWidget {
  final Board board;

  const _BoardHeader({required this.board});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: board.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  board.path,
                  style: TextStyle(
                    color: board.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                board.displayName,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            board.description,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.chat_bubble_2,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No threads yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to start a thread',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposeSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends ConsumerState<_ComposeSheet> {
  final _contentController = TextEditingController();
  final _nameController = TextEditingController();
  bool _useAnonymous = true;

  @override
  void dispose() {
    _contentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const Spacer(),
                Text(
                  'New Thread',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const Spacer(),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  onPressed: _canPost ? _createThread : null,
                  child: Text(
                    'Post',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Board indicator
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.folder,
                  color: feedState.currentBoard.accentColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Posting to ${feedState.currentBoard.path}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Anonymous toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Post as Anonymous',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                CupertinoSwitch(
                  value: _useAnonymous,
                  activeTrackColor: AppColors.primary,
                  onChanged: (value) => setState(() => _useAnonymous = value),
                ),
              ],
            ),
          ),

          if (!_useAnonymous) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoTextField(
                controller: _nameController,
                placeholder: 'Name (optional tripcode: name#secret)',
                placeholderStyle: TextStyle(color: AppColors.textTertiary),
                style: TextStyle(color: AppColors.textPrimary),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Content input
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoTextField(
                controller: _contentController,
                placeholder: 'What\'s on your mind, Anon?',
                placeholderStyle: TextStyle(color: AppColors.textTertiary),
                style: TextStyle(color: AppColors.textPrimary),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(12),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),

          // Attachment bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                _AttachButton(
                  icon: CupertinoIcons.photo,
                  label: 'Image',
                  onTap: () {},
                ),
                const SizedBox(width: 16),
                _AttachButton(
                  icon: CupertinoIcons.doc,
                  label: 'File',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _canPost => _contentController.text.trim().isNotEmpty;

  void _createThread() {
    ref.read(feedProvider.notifier).createThread(
      content: _contentController.text.trim(),
      authorName: _useAnonymous ? null : _nameController.text.trim(),
    );
    Navigator.pop(context);
  }
}

class _AttachButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AttachButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
