import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/settings_provider.dart';

/// Settings screen with Twitter-style settings list
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

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
              'Settings',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App info header
                  _buildAppHeader(),
                  const SizedBox(height: 24),

                  // Display settings
                  _SectionHeader(title: 'Display'),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    children: [
                      _SettingsRow(
                        icon: CupertinoIcons.moon_fill,
                        iconColor: AppColors.xBlue,
                        title: 'Dark Mode',
                        trailing: CupertinoSwitch(
                          value: settings.isDarkMode,
                          activeTrackColor: AppColors.xBlue,
                          onChanged: (_) => ref
                              .read(settingsProvider.notifier)
                              .toggleDarkMode(),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 24),

                  // Content settings
                  _SectionHeader(title: 'Content'),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    children: [
                      _SettingsRow(
                        icon: CupertinoIcons.eye_slash_fill,
                        iconColor: AppColors.warning,
                        title: 'Show NSFW Content',
                        subtitle: 'Display adult content in search results',
                        trailing: CupertinoSwitch(
                          value: settings.isNsfwEnabled,
                          activeTrackColor: AppColors.xBlue,
                          onChanged: (_) =>
                              ref.read(settingsProvider.notifier).toggleNsfw(),
                        ),
                      ),
                      _SettingsRow(
                        icon: CupertinoIcons.clock,
                        iconColor: AppColors.textSecondary,
                        title: 'Search History',
                        subtitle: '${settings.searchHistory.length} saved searches',
                        trailing: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: settings.searchHistory.isEmpty
                              ? null
                              : () {
                                  _confirmClearHistory(context, ref);
                                },
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              color: settings.searchHistory.isEmpty
                                  ? AppColors.textTertiary
                                  : AppColors.error,
                            ),
                          ),
                        ),
                        isLast: true,
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 24),

                  // About section
                  _SectionHeader(title: 'About'),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    children: [
                      _SettingsRow(
                        icon: CupertinoIcons.info_circle_fill,
                        iconColor: AppColors.success,
                        title: 'Version',
                        trailing: Text(
                          AppConstants.appVersion,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      _SettingsRow(
                        icon: CupertinoIcons.globe,
                        iconColor: AppColors.epubBadge,
                        title: 'GitHub',
                        trailing: Icon(
                          CupertinoIcons.chevron_right,
                          color: AppColors.textTertiary,
                          size: 18,
                        ),
                        onTap: () =>
                            _launchUrl('https://github.com/kj114022/Texton'),
                      ),
                      _SettingsRow(
                        icon: CupertinoIcons.doc_text_fill,
                        iconColor: AppColors.mobiBadge,
                        title: 'Licenses',
                        trailing: Icon(
                          CupertinoIcons.chevron_right,
                          color: AppColors.textTertiary,
                          size: 18,
                        ),
                        onTap: () => _showLicenses(context),
                        isLast: true,
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 32),

                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Made with love',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.heart_fill,
                              color: AppColors.pdfBadge,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Texton ${AppConstants.appVersion}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.xBlue.withValues(alpha: 0.15),
            AppColors.surface,
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.xBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.book_fill,
                color: AppColors.textPrimary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'eBook Downloader & Converter',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  void _confirmClearHistory(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear Search History'),
        content: const Text('This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              ref.read(settingsProvider.notifier).clearSearchHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showLicenses(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
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
                    'Open Source Licenses',
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
                children: [
                  _LicenseItem(
                    name: 'Flutter',
                    license: 'BSD-3-Clause',
                  ),
                  _LicenseItem(
                    name: 'Riverpod',
                    license: 'MIT',
                  ),
                  _LicenseItem(
                    name: 'go_router',
                    license: 'BSD-3-Clause',
                  ),
                  _LicenseItem(
                    name: 'Dio',
                    license: 'MIT',
                  ),
                  _LicenseItem(
                    name: 'cached_network_image',
                    license: 'MIT',
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool isLast;

  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: AppColors.divider, width: 0.5),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _LicenseItem extends StatelessWidget {
  final String name;
  final String license;

  const _LicenseItem({required this.name, required this.license});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              license,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
