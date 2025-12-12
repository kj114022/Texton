import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/downloads_provider.dart';

/// Downloads/Library screen showing downloaded books
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsState = ref.watch(downloadsProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: AppColors.surface.withValues(alpha: 0.95),
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.5),
            ),
            largeTitle: Text(
              'Library',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => ref.read(downloadsProvider.notifier).refresh(),
              child: Icon(CupertinoIcons.refresh, color: AppColors.xBlue),
            ),
          ),

          // Active downloads
          if (downloadsState.activeDownloads.isNotEmpty)
            SliverToBoxAdapter(
              child: _ActiveDownloadsSection(
                activeDownloads: downloadsState.activeDownloads,
              ),
            ),

          // Downloaded files
          if (downloadsState.downloads.isEmpty)
            SliverFillRemaining(child: _EmptyState())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final download = downloadsState.downloads[index];
                  return _DownloadedBookCard(
                    download: download,
                    onDelete: () => _confirmDelete(context, ref, download),
                    onShare: () => _shareFile(download),
                    onOpen: () => _openFile(download),
                  ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
                },
                childCount: downloadsState.downloads.length,
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, DownloadedBook download) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${download.title}"?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              ref.read(downloadsProvider.notifier).deleteDownload(download);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _shareFile(DownloadedBook download) {
    Share.shareXFiles(
      [XFile(download.filePath)],
      text: download.title,
    );
  }

  void _openFile(DownloadedBook download) {
    // TODO: Open file with system viewer
  }
}

class _ActiveDownloadsSection extends StatelessWidget {
  final Map<String, double> activeDownloads;

  const _ActiveDownloadsSection({required this.activeDownloads});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.xBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.xBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.cloud_download,
                color: AppColors.xBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Downloading (${activeDownloads.length})',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...activeDownloads.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: entry.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.xBlue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(entry.value * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.xBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DownloadedBookCard extends StatelessWidget {
  final DownloadedBook download;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onOpen;

  const _DownloadedBookCard({
    required this.download,
    required this.onDelete,
    required this.onShare,
    required this.onOpen,
  });

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
      child: Row(
        children: [
          // File icon
          Container(
            width: 50,
            height: 60,
            decoration: BoxDecoration(
              color: _formatColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                download.format,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _formatColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  download.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      download.fileSizeDisplay,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(download.downloadedAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onShare,
                child: Icon(
                  CupertinoIcons.share,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onDelete,
                child: Icon(
                  CupertinoIcons.trash,
                  color: AppColors.error,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color get _formatColor {
    switch (download.format.toUpperCase()) {
      case 'PDF':
        return AppColors.pdfBadge;
      case 'EPUB':
        return AppColors.epubBadge;
      case 'MOBI':
        return AppColors.mobiBadge;
      case 'AZW3':
        return AppColors.azw3Badge;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
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
            CupertinoIcons.folder_open,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Your library is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Downloaded books will appear here',
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
