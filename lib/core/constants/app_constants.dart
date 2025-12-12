/// Application-wide constants
class AppConstants {
  AppConstants._();

  static const String appName = 'Texton';
  static const String appVersion = '1.0.0';

  // API endpoints for book sources
  static const String annasArchiveBaseUrl = 'https://annas-archive.org';
  static const String libgenBaseUrl = 'https://libgen.rs';

  // File size limits
  static const int maxFileSizeMb = 50;

  // Timing constants
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackbarDuration = Duration(seconds: 3);

  // UI constants
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 24.0;
  static const double inputBorderRadius = 20.0;
  static const double bottomNavHeight = 83.0;

  // Pagination
  static const int searchResultsLimit = 50;

  // Shared preferences keys
  static const String keyDarkMode = 'dark_mode';
  static const String keyNsfwEnabled = 'nsfw_enabled';
  static const String keySearchHistory = 'search_history';
}

/// NSFW keywords for content filtering
class NsfwFilter {
  NsfwFilter._();

  static const List<String> keywords = [
    'erotica',
    'xxx',
    'adult',
    'sex',
    'porn',
    'nude',
    'naked',
    'fetish',
    'erotic',
  ];

  static bool containsNsfw(String text) {
    final lowerText = text.toLowerCase();
    return keywords.any((keyword) => lowerText.contains(keyword));
  }
}
