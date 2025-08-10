import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/content_loader.dart';
import '../models/news_item.dart';
import '../state/app_state.dart';

class VideoNewsPage extends StatefulWidget {
  const VideoNewsPage({super.key});

  @override
  State<VideoNewsPage> createState() => _VideoNewsPageState();
}

class _VideoNewsPageState extends State<VideoNewsPage> {
  late Future<List<NewsItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = ContentLoader.loadNews();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return FutureBuilder<List<NewsItem>>(
      future: _future,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
          children: [
            Text('Video News by your Teacher', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text("Weekly bite-sized videos with fresh topics and real Spanish."),
            const SizedBox(height: 16),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () async {
                    if (item.isPaid && !appState.isSubscribed) {
                      context.push('/paywall');
                    } else {
                      final uri = Uri.parse(item.videoUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                  child: _NewsCard(item: item),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item});
  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF4D4D), Color(0xFFFFD200)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      Text(item.publishedAt, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (item.isPaid)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('PRO', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w800)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.summary),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: null,
                icon: const Icon(Icons.play_circle_fill),
                label: const Text('Watch'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}