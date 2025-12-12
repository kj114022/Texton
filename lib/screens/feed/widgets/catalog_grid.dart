import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/post.dart';

/// 4chan-style catalog grid view
class CatalogGrid extends StatelessWidget {
  final List<Thread> threads;

  const CatalogGrid({super.key, required this.threads});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: threads.map((thread) {
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 32) / 3,
            child: _CatalogItem(thread: thread),
          );
        }).toList(),
      ),
    );
  }
}

class _CatalogItem extends StatelessWidget {
  final Thread thread;

  const _CatalogItem({required this.thread});

  @override
  Widget build(BuildContext context) {
    final op = thread.op;

    return GestureDetector(
      onTap: () {
        // Open thread
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image thumbnail
            AspectRatio(
              aspectRatio: 1,
              child: op.hasImage
                  ? op.primaryImage!.url.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: op.primaryImage!.url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.surfaceVariant,
                          ),
                          errorWidget: (context, url, error) => _NoImagePlaceholder(),
                        )
                      : _NoImagePlaceholder()
                  : _NoImagePlaceholder(),
            ),

            // Thread info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content preview
                  Text(
                    op.content,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Stats
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.chat_bubble,
                        color: AppColors.textTertiary,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${thread.replyCount}',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        CupertinoIcons.photo,
                        color: AppColors.textTertiary,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${thread.imageCount}',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Sticky indicator
            if (op.isSticky)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: AppColors.warning.withValues(alpha: 0.2),
                child: Center(
                  child: Icon(
                    CupertinoIcons.pin_fill,
                    color: AppColors.warning,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NoImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Icon(
          CupertinoIcons.doc_text,
          color: AppColors.textTertiary,
          size: 32,
        ),
      ),
    );
  }
}
