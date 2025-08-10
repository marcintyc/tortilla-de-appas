import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'pages/shell.dart';
import 'pages/home_page.dart';
import 'pages/learn_page.dart';
import 'pages/video_news_page.dart';
import 'pages/settings_page.dart';
import 'pages/paywall_page.dart';
import 'pages/pro_feed_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.restoreFromStorage();

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/learn',
            name: 'learn',
            builder: (context, state) => const LearnPage(),
          ),
          GoRoute(
            path: '/feed',
            name: 'feed',
            builder: (context, state) => const ProFeedPage(),
          ),
          GoRoute(
            path: '/videos',
            name: 'videos',
            builder: (context, state) => const VideoNewsPage(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/paywall',
        name: 'paywall',
        builder: (context, state) => const PaywallPage(),
      ),
    ],
  );

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: HablaApp(router: router),
    ),
  );
}

class HablaApp extends StatelessWidget {
  const HablaApp({super.key, required this.router});
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.buildTheme();
    return MaterialApp.router(
      title: 'Habla – Learn Spanish',
      theme: theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}