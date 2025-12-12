import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../screens/details/book_details_screen.dart';
import '../screens/convert/convert_screen.dart';
import '../screens/downloads/downloads_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/main_scaffold.dart';

/// Application router configuration using go_router
final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
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
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/convert',
              name: 'convert',
              builder: (context, state) => const ConvertScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/downloads',
              name: 'downloads',
              builder: (context, state) => const DownloadsScreen(),
            ),
          ],
        ),
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
