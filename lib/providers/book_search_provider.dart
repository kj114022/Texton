import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/book.dart';
import '../data/models/book_format.dart';
import '../data/sources/annas_archive_source.dart';
import '../data/sources/libgen_source.dart';
import '../core/constants/app_constants.dart';

/// State for book search functionality
class BookSearchState {
  final List<Book> books;
  final List<Book> filteredBooks;
  final Set<BookFormat> appliedFilters;
  final bool isLoading;
  final String? error;
  final String? currentQuery;

  const BookSearchState({
    this.books = const [],
    this.filteredBooks = const [],
    this.appliedFilters = const {
      BookFormat.pdf,
      BookFormat.epub,
      BookFormat.mobi,
      BookFormat.azw3,
    },
    this.isLoading = false,
    this.error,
    this.currentQuery,
  });

  BookSearchState copyWith({
    List<Book>? books,
    List<Book>? filteredBooks,
    Set<BookFormat>? appliedFilters,
    bool? isLoading,
    String? error,
    String? currentQuery,
  }) {
    return BookSearchState(
      books: books ?? this.books,
      filteredBooks: filteredBooks ?? this.filteredBooks,
      appliedFilters: appliedFilters ?? this.appliedFilters,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentQuery: currentQuery ?? this.currentQuery,
    );
  }
}

/// Book search notifier for managing search state and operations
class BookSearchNotifier extends StateNotifier<BookSearchState> {
  BookSearchNotifier() : super(const BookSearchState());

  final _annasArchive = AnnasArchiveSource();
  final _libgen = LibgenSource();

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      currentQuery: query,
    );

    try {
      // Search from multiple sources in parallel
      final results = await Future.wait([
        _annasArchive.search(query).catchError((_) => <Book>[]),
        _libgen.search(query).catchError((_) => <Book>[]),
      ]);

      // Combine and deduplicate results
      final allBooks = <Book>[];
      final seenIds = <String>{};

      for (final sourceBooks in results) {
        for (final book in sourceBooks) {
          final uniqueId = '${book.source}-${book.id}';
          if (!seenIds.contains(uniqueId)) {
            seenIds.add(uniqueId);
            allBooks.add(book);
          }
        }
      }

      // Apply NSFW filter
      final prefs = await SharedPreferences.getInstance();
      final allowNsfw = prefs.getBool(AppConstants.keyNsfwEnabled) ?? false;

      final filteredForNsfw = allowNsfw
          ? allBooks
          : allBooks
              .where((book) => !NsfwFilter.containsNsfw(book.title))
              .toList();

      state = state.copyWith(
        books: filteredForNsfw,
        isLoading: false,
      );

      _applyFormatFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to search books: ${e.toString()}',
      );
    }
  }

  void toggleFilter(BookFormat format) {
    final currentFilters = Set<BookFormat>.from(state.appliedFilters);

    if (currentFilters.contains(format)) {
      currentFilters.remove(format);
    } else {
      currentFilters.add(format);
    }

    state = state.copyWith(appliedFilters: currentFilters);
    _applyFormatFilters();
  }

  void _applyFormatFilters() {
    final filtered = state.books
        .where((book) => state.appliedFilters.contains(book.format))
        .toList();

    state = state.copyWith(filteredBooks: filtered);
  }

  void clearSearch() {
    state = const BookSearchState();
  }
}

/// Provider for book search state and operations
final bookSearchProvider =
    StateNotifierProvider<BookSearchNotifier, BookSearchState>(
  (ref) => BookSearchNotifier(),
);

/// Selected book provider for details screen
final selectedBookProvider = StateProvider<Book?>((ref) => null);
