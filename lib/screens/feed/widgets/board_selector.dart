import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/board.dart';
import '../../../providers/feed_provider.dart';

/// Board selector bottom sheet
class BoardSelector extends ConsumerWidget {
  final ValueChanged<Board> onBoardSelected;

  const BoardSelector({super.key, required this.onBoardSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boards = ref.watch(boardsProvider);
    final currentBoard = ref.watch(feedProvider).currentBoard;

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
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
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Select Board',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Board list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: boards.length,
              itemBuilder: (context, index) {
                final board = boards[index];
                final isSelected = board.id == currentBoard.id;

                return GestureDetector(
                  onTap: () => onBoardSelected(board),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? board.accentColor.withValues(alpha: 0.15)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: board.accentColor, width: 1.5)
                          : Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        // Board icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: board.accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              board.path,
                              style: TextStyle(
                                color: board.accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Board info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                board.displayName,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                board.description,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Selected indicator
                        if (isSelected)
                          Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            color: board.accentColor,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
