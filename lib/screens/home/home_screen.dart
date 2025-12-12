import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/book_search_provider.dart';
import '../../providers/downloads_provider.dart';
import '../../data/models/book_format.dart';
import 'widgets/book_card.dart';
import 'widgets/search_header.dart';
import 'widgets/trending_chips.dart';
import 'widgets/shimmer_loading.dart';

/// Home screen with Twitter-style search and book feed
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(bookSearchProvider.notifier).search(query);
    }
  }

  void _onTrendingTap(String query) {
    _searchController.text = query;
    _onSearch(query);
  }

  void _onBookTap(book) {
    ref.read(selectedBookProvider.notifier).state = book;
    context.goNamed('details');
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(bookSearchProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Twitter-style navigation bar
          CupertinoSliverNavigationBar(
            backgroundColor: AppColors.surface.withValues(alpha: 0.95),
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.5),
            ),
            largeTitle: Text(
              'Texton',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showFilterSheet(context),
              child: Icon(
                CupertinoIcons.slider_horizontal_3,
                color: AppColors.xBlue,
              ),
            ),
          ),

          // Search header
          SliverToBoxAdapter(
            child: SearchHeader(
              controller: _searchController,
              onSearch: _onSearch,
            ),
          ),

          // Content based on state
          if (searchState.isLoading)
            const SliverToBoxAdapter(child: ShimmerLoading())
          else if (searchState.error != null)
            SliverToBoxAdapter(child: _buildErrorState(searchState.error!))
          else if (searchState.filteredBooks.isEmpty &&
              searchState.currentQuery == null)
            SliverToBoxAdapter(
              child: TrendingChips(onChipTap: _onTrendingTap),
            )
          else if (searchState.filteredBooks.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState())
          else
            _buildBooksList(searchState.filteredBooks),
        ],
      ),
    );
  }

  Widget _buildBooksList(List books) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final book = books[index];
          return BookCard(
            book: book,
            onTap: () => _onBookTap(book),
            onDownload: () => _downloadBook(book),
          ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
        },
        childCount: books.length,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.book,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No books found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton(
            color: AppColors.xBlue,
            borderRadius: BorderRadius.circular(20),
            onPressed: () {
              if (ref.read(bookSearchProvider).currentQuery != null) {
                ref.read(bookSearchProvider.notifier).search(
                      ref.read(bookSearchProvider).currentQuery!,
                    );
              }
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _FilterSheet(),
    );
  }

  void _downloadBook(book) {
    ref.read(downloadsProvider.notifier).downloadBook(book);
  }
}

class _FilterSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(bookSearchProvider);

    return Container(
      height: 300,
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Filter by Format',
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: BookFormat.values.map((format) {
                final isSelected =
                    searchState.appliedFilters.contains(format);
                return _FilterRow(
                  title: format.displayName,
                  isSelected: isSelected,
                  onChanged: (_) {
                    ref.read(bookSearchProvider.notifier).toggleFilter(format);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String title;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const _FilterRow({
    required this.title,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: AppColors.xBlue, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const Spacer(),
          CupertinoSwitch(
            value: isSelected,
            activeTrackColor: AppColors.xBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
