import 'package:audiobook_app/ui/audiobooks_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/audiobook.dart';
import '../../ui/audiobook_screen.dart';
import 'app_routes.dart';

final GlobalKey<NavigatorState> rootNavigator = GlobalKey(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: rootNavigator,
  initialLocation: AppRoutes.audiobooks.path,
  routes: [
    GoRoute(
      path: AppRoutes.audiobooks.path,
      name: AppRoutes.audiobooks.name,
      pageBuilder: (context, state) => NoTransitionPage(
        child: const AudiobooksScreen(),
        key: state.pageKey,
        name: state.name,
      ),
      routes: [
        GoRoute(
          path: AppRoutes.audiobook.path,
          name: AppRoutes.audiobook.name,
          pageBuilder: (context, state) => NoTransitionPage(
            child: AudiobookScreen(
              audiobook: state.extra as Audiobook,
              initialIndex: num.parse(state.pathParameters['index'] ?? '0').toInt(),
            ),
            key: state.pageKey,
            name: state.name,
          ),
        ),
      ],
    ),
  ],
);
