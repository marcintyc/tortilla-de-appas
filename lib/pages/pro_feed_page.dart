import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../data/content_loader.dart';
import '../models/feed_post.dart';
import '../state/app_state.dart';

class ProFeedPage extends StatefulWidget {
  const ProFeedPage({super.key});

  @override
  State<ProFeedPage> createState() => _ProFeedPageState();
}

class _ProFeedPageState extends State<ProFeedPage> {
  late Future<List<FeedPost>> _seedFuture;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _seedFuture = ContentLoader.loadFeed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month-1]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isPro = appState.isSubscribed;

    return FutureBuilder<List<FeedPost>>(
      future: _seedFuture,
      builder: (context, snapshot) {
        final seed = snapshot.data ?? [];
        final posts = [
          ...appState.userFeedPosts,
          ...seed,
        ];
        return Column(
          children: [
            if (isPro) _Composer(controller: _controller),
            if (!isPro)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Join the community', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        const Text('Ask questions, share progress, and get feedback from your teacher.'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pushNamed('/paywall'),
                          child: const Text('Go PRO'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final liked = appState.likedPostIds.contains(post.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PostCard(
                      post: post,
                      liked: liked,
                      timeLabel: _formatTime(post.timestampIso),
                      onLike: () => appState.toggleLike(post.id),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Composer extends StatefulWidget {
  const _Composer({required this.controller});
  final TextEditingController controller;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  bool _canPost = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
  }

  void _update() {
    setState(() => _canPost = widget.controller.text.trim().isNotEmpty);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: widget.controller,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Ask a question or share an update…',
                  border: InputBorder.none,
                ),
              ),
              Row(
                children: [
                  const Spacer(),
                  FilledButton(
                    onPressed: _canPost
                        ? () {
                            final text = widget.controller.text.trim();
                            widget.controller.clear();
                            appState.addUserPost(text);
                          }
                        : null,
                    child: const Text('Post'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.liked,
    required this.timeLabel,
    required this.onLike,
  });

  final FeedPost post;
  final bool liked;
  final String timeLabel;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final color = post.isTeacher ? Colors.deepOrange : Colors.grey.shade700;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: post.isTeacher ? Colors.orange : Colors.grey.shade300,
                  child: Icon(post.isTeacher ? Icons.star : Icons.person, size: 18, color: post.isTeacher ? Colors.white : Colors.black87),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Text(post.author, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
                      const SizedBox(width: 6),
                      Text('· $timeLabel', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.content),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.red : null),
                  onPressed: onLike,
                ),
                const SizedBox(width: 4),
                Text(liked ? 'You and others like this' : 'Like'),
              ],
            )
          ],
        ),
      ),
    );
  }
}