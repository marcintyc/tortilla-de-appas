import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        SwitchListTile(
          value: appState.isSubscribed,
          title: const Text('PRO subscription (mock toggle)'),
          subtitle: const Text('Enables paid lessons and videos in this demo'),
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