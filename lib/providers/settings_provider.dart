import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

/// Settings state for app preferences
class SettingsState {
  final bool isDarkMode;
  final bool isNsfwEnabled;
  final List<String> searchHistory;

  const SettingsState({
    this.isDarkMode = true,
    this.isNsfwEnabled = false,
    this.searchHistory = const [],
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? isNsfwEnabled,
    List<String>? searchHistory,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isNsfwEnabled: isNsfwEnabled ?? this.isNsfwEnabled,
      searchHistory: searchHistory ?? this.searchHistory,
    );
  }
}

/// Settings notifier for managing app preferences
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final isDarkMode = prefs.getBool(AppConstants.keyDarkMode) ?? true;
    final isNsfwEnabled = prefs.getBool(AppConstants.keyNsfwEnabled) ?? false;
    final searchHistory =
        prefs.getStringList(AppConstants.keySearchHistory) ?? [];

    state = SettingsState(
      isDarkMode: isDarkMode,
      isNsfwEnabled: isNsfwEnabled,
      searchHistory: searchHistory,
    );
  }

  Future<void> toggleDarkMode() async {
    final newValue = !state.isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDarkMode, newValue);
    state = state.copyWith(isDarkMode: newValue);
  }

  Future<void> toggleNsfw() async {
    final newValue = !state.isNsfwEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyNsfwEnabled, newValue);
    state = state.copyWith(isNsfwEnabled: newValue);
  }

  Future<void> addToSearchHistory(String query) async {
    if (query.trim().isEmpty) return;

    final history = List<String>.from(state.searchHistory);
    history.remove(query); // Remove if exists
    history.insert(0, query); // Add at beginning

    // Keep only last 20 searches
    if (history.length > 20) {
      history.removeLast();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.keySearchHistory, history);
    state = state.copyWith(searchHistory: history);
  }

  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.keySearchHistory, []);
    state = state.copyWith(searchHistory: []);
  }
}

/// Provider for settings state
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
