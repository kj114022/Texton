import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_theme.dart';

/// Twitter-style search header with rounded search field
class SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  const SearchHeader({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: CupertinoSearchTextField(
        controller: controller,
        placeholder: 'Search books, authors, or topics...',
        backgroundColor: AppColors.surfaceVariant,
        style: TextStyle(color: AppColors.textPrimary),
        placeholderStyle: TextStyle(color: AppColors.textTertiary),
        prefixIcon: Icon(
          CupertinoIcons.search,
          color: AppColors.textSecondary,
        ),
        suffixIcon: Icon(
          CupertinoIcons.xmark_circle_fill,
          color: AppColors.textSecondary,
        ),
        onSubmitted: onSearch,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
