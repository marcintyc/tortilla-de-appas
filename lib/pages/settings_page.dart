import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../state/app_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isLoggedIn = appState.isLoggedIn;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ListTile(
          title: Text(isLoggedIn ? 'Signed in as ${appState.userName}' : 'Not signed in'),
          subtitle: Text(isLoggedIn ? (appState.userRole == UserRole.teacher ? 'Role: Teacher' : 'Role: Student') : 'Sign in to personalize'),
          trailing: isLoggedIn
              ? TextButton(
                  onPressed: () => appState.signOut(),
                  child: const Text('Sign out'),
                )
              : FilledButton(
                  onPressed: () => context.push('/login'),
                  child: const Text('Sign in'),
                ),
        ),
        if (isLoggedIn)
          SwitchListTile(
            value: appState.userRole == UserRole.teacher,
            title: const Text('I am the teacher (creator)'),
            subtitle: const Text('Enable teacher features like highlighted posts/comments'),
            onChanged: (v) => appState.signIn(
              name: appState.userName ?? 'You',
              role: v ? UserRole.teacher : UserRole.student,
            ),
          ),
        const Divider(height: 32),
        SwitchListTile(
          value: appState.isSubscribed,
          title: const Text('PRO subscription (mock toggle)'),
          subtitle: const Text('Enables paid lessons, videos and community feed composer'),
          onChanged: (v) => appState.toggleSubscription(v),
        ),
        const Divider(height: 32),
        ListTile(
          title: const Text('Reset progress'),
          subtitle: const Text('Marks all lessons as not completed'),
          trailing: const Icon(Icons.restore),
          onTap: () => appState.resetProgress(),
        ),
      ],
    );
  }
}