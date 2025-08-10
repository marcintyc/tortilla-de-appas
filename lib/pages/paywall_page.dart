import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Go PRO')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unlock the full Spanish journey', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const _Benefit(text: 'Full A1–B2 path with all lessons'),
            const _Benefit(text: 'Weekly teacher video news'),
            const _Benefit(text: 'Progress tracking and review sets'),
            const _Benefit(text: 'Support from the creator'),
            const Spacer(),
            FilledButton(
              onPressed: () {
                appState.toggleSubscription(true);
                Navigator.of(context).maybePop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PRO activated (mock)')));
              },
              child: const Text('Subscribe (mock)'),
            ),
            const SizedBox(height: 8),
            Text('Note: On web (GitHub Pages) this is a demo toggle. Integrate Stripe/IAP for production.', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}