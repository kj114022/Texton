import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/book.dart';

/// Twitter-style book card with cover, title, and actions
class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            _BookCover(imageUrl: book.imageUrl),
            const SizedBox(width: 14),

            // Book info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    book.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Authors
                  Text(
                    book.authorsDisplay,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Metadata row
                  Row(
                    children: [
                      _FormatBadge(format: book.format),
                      if (book.size != null && book.size!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          book.size!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        book.source,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    children: [
                      _ActionButton(
                        icon: CupertinoIcons.eye,
                        onTap: onTap,
                      ),
                      const SizedBox(width: 24),
                      _ActionButton(
                        icon: CupertinoIcons.cloud_download,
                        onTap: onDownload,
                        color: AppColors.xBlue,
                      ),
                      const SizedBox(width: 24),
                      _ActionButton(
                        icon: CupertinoIcons.share,
                        onTap: () {
                          // TODO: Implement share
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  final String? imageUrl;

  const _BookCover({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.background.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => _PlaceholderCover(),
              errorWidget: (context, url, error) => _PlaceholderCover(),
            )
          : _PlaceholderCover(),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceElevated,
      child: Center(
        child: Icon(
          CupertinoIcons.book,
          color: AppColors.textTertiary,
          size: 32,
        ),
      ),
    );
  }
}

class _FormatBadge extends StatelessWidget {
  final dynamic format;

  const _FormatBadge({required this.format});

  Color get _badgeColor {
    switch (format.extension) {
      case 'pdf':
        return AppColors.pdfBadge;
      case 'epub':
        return AppColors.epubBadge;
      case 'mobi':
        return AppColors.mobiBadge;
      case 'azw3':
        return AppColors.azw3Badge;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _badgeColor, width: 1),
      ),
      child: Text(
        format.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _badgeColor,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 20,
          color: color ?? AppColors.textSecondary,
        ),
      ),
    );
  }
}
