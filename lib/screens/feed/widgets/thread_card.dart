import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/post.dart';

/// Twitter-styled thread card with 4chan info display
class ThreadCard extends StatelessWidget {
  final Thread thread;
  final VoidCallback onTap;

  const ThreadCard({
    super.key,
    required this.thread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final op = thread.op;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Header: Author info and post ID
            Row(
              children: [
                // Anonymous avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      op.displayName[0].toUpperCase(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            op.displayName,
                            style: TextStyle(
                              color: op.authorName != null
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          if (op.tripcode != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              op.tripcode!,
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            op.displayId,
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            ' · ',
                            style: TextStyle(color: AppColors.textTertiary),
                          ),
                          Text(
                            op.timeAgo,
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Sticky/locked badges
                if (op.isSticky)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.pin_fill,
                          color: AppColors.warning,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sticky',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Content text
            Text(
              op.content,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),

            // Image preview
            if (op.hasImage) ...[
              const SizedBox(height: 12),
              _ImagePreview(attachment: op.primaryImage!),
            ],

            // File attachment preview
            if (op.hasFile && !op.hasImage) ...[
              const SizedBox(height: 12),
              _FilePreview(attachment: op.attachments.first),
            ],

            const SizedBox(height: 12),

            // Stats row (4chan style)
            Row(
              children: [
                _StatBadge(
                  icon: CupertinoIcons.chat_bubble,
                  value: thread.replyCount,
                  label: 'replies',
                ),
                const SizedBox(width: 16),
                _StatBadge(
                  icon: CupertinoIcons.photo,
                  value: thread.imageCount,
                  label: 'images',
                ),
                const Spacer(),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final dynamic attachment;

  const _ImagePreview({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: attachment.url.startsWith('http')
          ? CachedNetworkImage(
              imageUrl: attachment.url,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                height: 200,
                color: AppColors.surfaceVariant,
                child: Center(
                  child: CupertinoActivityIndicator(color: AppColors.primary),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: AppColors.surfaceVariant,
                child: Center(
                  child: Icon(
                    CupertinoIcons.photo,
                    color: AppColors.textTertiary,
                    size: 48,
                  ),
                ),
              ),
            )
          : Container(
              height: 200,
              color: AppColors.surfaceVariant,
              child: Center(
                child: Icon(
                  CupertinoIcons.photo,
                  color: AppColors.textTertiary,
                  size: 48,
                ),
              ),
            ),
    );
  }
}

class _FilePreview extends StatelessWidget {
  final dynamic attachment;

  const _FilePreview({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                attachment.extension,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  attachment.sizeDisplay,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.cloud_download,
            color: AppColors.primary,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 16),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
