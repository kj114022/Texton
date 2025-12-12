import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';

/// Trending topic chips like Twitter's explore section
class TrendingChips extends StatelessWidget {
  final ValueChanged<String> onChipTap;

  const TrendingChips({
    super.key,
    required this.onChipTap,
  });

  static const _trendingTopics = [
    ('fiction', 'Fiction'),
    ('science', 'Science'),
    ('programming', 'Programming'),
    ('history', 'History'),
    ('philosophy', 'Philosophy'),
    ('business', 'Business'),
    ('psychology', 'Psychology'),
    ('self-help', 'Self-Help'),
    ('biography', 'Biography'),
    ('fantasy', 'Fantasy'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.xBlue.withValues(alpha: 0.2),
                  AppColors.xBlueDark.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.xBlue.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.book_fill,
                      color: AppColors.xBlue,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Welcome to Texton',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Search millions of books across multiple libraries. Download in PDF, EPUB, MOBI, or AZW3 formats.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.2, end: 0),

          const SizedBox(height: 28),

          // Trending section
          Row(
            children: [
              Icon(
                CupertinoIcons.flame_fill,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Trending Topics',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _trendingTopics.asMap().entries.map((entry) {
              final index = entry.key;
              final topic = entry.value;
              return _TrendingChip(
                label: topic.$2,
                query: topic.$1,
                onTap: () => onChipTap(topic.$1),
              ).animate().fadeIn(delay: Duration(milliseconds: 100 + index * 50));
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Quick stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: CupertinoIcons.collections,
                  label: 'Sources',
                  value: '3+',
                ),
                _StatDivider(),
                _StatItem(
                  icon: CupertinoIcons.doc_text,
                  label: 'Formats',
                  value: '4',
                ),
                _StatDivider(),
                _StatItem(
                  icon: CupertinoIcons.cloud_download,
                  label: 'Free',
                  value: '100%',
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

class _TrendingChip extends StatelessWidget {
  final String label;
  final String query;
  final VoidCallback onTap;

  const _TrendingChip({
    required this.label,
    required this.query,
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
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.xBlue, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 50,
      color: AppColors.divider,
    );
  }
}
