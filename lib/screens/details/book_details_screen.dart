import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/book_search_provider.dart';
import '../../providers/downloads_provider.dart';
import '../../data/models/book.dart';

/// Book details screen with Twitter-style profile-like layout
class BookDetailsScreen extends ConsumerWidget {
  const BookDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(selectedBookProvider);

    if (book == null) {
      return CupertinoPageScaffold(
        backgroundColor: AppColors.background,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: AppColors.surface,
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
          middle: Text(
            'Book Details',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        child: Center(
          child: Text(
            'No book selected',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: CustomScrollView(
        slivers: [
          // Navigation bar with blur effect
          CupertinoSliverNavigationBar(
            backgroundColor: AppColors.surface.withValues(alpha: 0.9),
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.5),
            ),
            largeTitle: Text(
              'Details',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _shareBook(book),
              child: Icon(CupertinoIcons.share, color: AppColors.xBlue),
            ),
          ),

          // Book header with cover
          SliverToBoxAdapter(
            child: _BookHeader(book: book),
          ),

          // Action buttons
          SliverToBoxAdapter(
            child: _ActionButtons(book: book, ref: ref),
          ),

          // Book info sections
          SliverToBoxAdapter(
            child: _BookInfoSection(book: book),
          ),
        ],
      ),
    );
  }

  void _shareBook(Book book) {
    Share.share(
      'Check out "${book.title}" by ${book.authorsDisplay}\n\n${book.downloadUrl}',
      subject: book.title,
    );
  }
}

class _BookHeader extends StatelessWidget {
  final Book book;

  const _BookHeader({required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.xBlue.withValues(alpha: 0.15),
            AppColors.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Book cover with shadow
          Container(
            width: 140,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.xBlue.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: book.imageUrl != null && book.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: book.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _PlaceholderCover(),
                    errorWidget: (context, url, error) => _PlaceholderCover(),
                  )
                : _PlaceholderCover(),
          ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),

          const SizedBox(height: 20),

          // Title
          Text(
            book.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 8),

          // Authors
          Text(
            'by ${book.authorsDisplay}',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.xBlue,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 16),

          // Metadata chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _MetadataChip(
                icon: CupertinoIcons.doc_text,
                label: book.format.displayName,
                color: _formatColor(book.format.extension),
              ),
              if (book.size != null && book.size!.isNotEmpty)
                _MetadataChip(
                  icon: CupertinoIcons.arrow_down_circle,
                  label: book.size!,
                ),
              _MetadataChip(
                icon: CupertinoIcons.building_2_fill,
                label: book.source,
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Color _formatColor(String extension) {
    switch (extension) {
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
}

class _PlaceholderCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          CupertinoIcons.book,
          color: AppColors.textTertiary,
          size: 48,
        ),
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetadataChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Book book;
  final WidgetRef ref;

  const _ActionButtons({required this.book, required this.ref});

  @override
  Widget build(BuildContext context) {
    final downloadsState = ref.watch(downloadsProvider);
    final isDownloading = downloadsState.activeDownloads.containsKey(book.id);
    final progress = downloadsState.activeDownloads[book.id] ?? 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Download button
          Expanded(
            child: CupertinoButton(
              color: AppColors.xBlue,
              borderRadius: BorderRadius.circular(24),
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: isDownloading
                  ? null
                  : () {
                      ref.read(downloadsProvider.notifier).downloadBook(book);
                    },
              child: isDownloading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CupertinoActivityIndicator(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.cloud_download,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Download',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // Bookmark button
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: CupertinoButton(
              padding: const EdgeInsets.all(14),
              onPressed: () {
                // TODO: Implement bookmark
              },
              child: Icon(
                CupertinoIcons.bookmark,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms);
  }
}

class _BookInfoSection extends StatelessWidget {
  final Book book;

  const _BookInfoSection({required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description section
          if (book.description != null && book.description!.isNotEmpty) ...[
            _SectionHeader(title: 'About this book'),
            const SizedBox(height: 12),
            Text(
              book.description!,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Details card
          _SectionHeader(title: 'Details'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                if (book.publisher != null && book.publisher!.isNotEmpty)
                  _DetailRow(label: 'Publisher', value: book.publisher!),
                if (book.year != null && book.year!.isNotEmpty)
                  _DetailRow(label: 'Year', value: book.year!),
                if (book.language != null && book.language!.isNotEmpty)
                  _DetailRow(label: 'Language', value: book.language!),
                if (book.isbn != null && book.isbn!.isNotEmpty)
                  _DetailRow(label: 'ISBN', value: book.isbn!),
                _DetailRow(label: 'Format', value: book.format.displayName),
                _DetailRow(label: 'Source', value: book.source, isLast: true),
              ],
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: AppColors.divider, width: 0.5),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
