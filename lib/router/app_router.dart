import 'package:go_router/go_router.dart';

import '../screens/feed/feed_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/details/book_details_screen.dart';
import '../screens/convert/convert_screen.dart';
import '../screens/downloads/downloads_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/main_scaffold.dart';

/// Application router configuration using go_router
final appRouter = GoRouter(
  initialLocation: '/feed',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Feed tab (4chan-style board)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/feed',
              name: 'feed',
              builder: (context, state) => const FeedScreen(),
            ),
          ],
        ),
        // Search tab (book search)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'details',
                  name: 'details',
                  builder: (context, state) => const BookDetailsScreen(),
                ),
              ],
            ),
          ],
        ),
        // Convert tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/convert',
              name: 'convert',
              builder: (context, state) => const ConvertScreen(),
            ),
          ],
        ),
        // Library tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/downloads',
              name: 'downloads',
              builder: (context, state) => const DownloadsScreen(),
            ),
          ],
        ),
        // Settings tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
