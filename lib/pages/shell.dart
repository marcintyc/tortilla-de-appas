import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../state/app_state.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  static const _destinations = [
    _Dest(label: 'Home', icon: Icons.home_outlined, route: '/'),
    _Dest(label: 'Learn', icon: Icons.school_outlined, route: '/learn'),
    _Dest(label: 'Feed', icon: Icons.forum_outlined, route: '/feed'),
    _Dest(label: 'Videos', icon: Icons.ondemand_video_outlined, route: '/videos'),
    _Dest(label: 'Settings', icon: Icons.settings_outlined, route: '/settings'),
  ];

  int _indexForLocation(String location) {
    final idx = _destinations.indexWhere((d) => location == d.route);
    return idx >= 0 ? idx : 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF395E), Color(0xFFFF8A00), Color(0xFFFFD166)],
            stops: [0.0, 0.6, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Habla',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                    ),
                    const _ProBadge(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(icon: Icon(d.icon), label: d.label),
        ],
        onDestinationSelected: (index) {
          final dest = _destinations[index];
          if (dest.route == '/feed' && !context.read<AppState>().isSubscribed) {
            context.go('/paywall');
            return;
          }
          if (dest.route != location) context.go(dest.route);
        },
      ),
    );
  }
}

class _Dest {
  const _Dest({required this.label, required this.icon, required this.route});
  final String label;
  final IconData icon;
  final String route;
}

class _ProBadge extends StatelessWidget {
  const _ProBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.flash_on, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text('PRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}