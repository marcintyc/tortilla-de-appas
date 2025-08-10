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

enum _FeedFilter { all, students, teacher }

class _ProFeedPageState extends State<ProFeedPage> {
  late Future<List<FeedPost>> _seedFuture;
  final TextEditingController _controller = TextEditingController();
  _FeedFilter _filter = _FeedFilter.all;

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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isPro = appState.isSubscribed;
    final isLoggedIn = appState.isLoggedIn;

    return FutureBuilder<List<FeedPost>>(
      future: _seedFuture,
      builder: (context, snapshot) {
        final seed = snapshot.data ?? [];
        var posts = [
          ...appState.userFeedPosts,
          ...seed,
        ];
        posts = switch (_filter) {
          _FeedFilter.all => posts,
          _FeedFilter.students => posts.where((p) => !p.isTeacher).toList(),
          _FeedFilter.teacher => posts.where((p) => p.isTeacher).toList(),
        };

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  ChoiceChip(
                    selected: _filter == _FeedFilter.all,
                    label: const Text('All'),
                    onSelected: (_) => setState(() => _filter = _FeedFilter.all),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    selected: _filter == _FeedFilter.students,
                    label: const Text('Students'),
                    onSelected: (_) => setState(() => _filter = _FeedFilter.students),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    selected: _filter == _FeedFilter.teacher,
                    label: const Text('Teacher'),
                    onSelected: (_) => setState(() => _filter = _FeedFilter.teacher),
                  ),
                  const Spacer(),
                  if (!isLoggedIn)
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/login'),
                      child: const Text('Sign in'),
                    ),
                ],
              ),
            ),
            if (isPro && isLoggedIn) _Composer(controller: _controller),
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
                  final comments = appState.commentsFor(post.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PostCard(
                      post: post,
                      liked: liked,
                      comments: comments,
                      onLike: () => appState.toggleLike(post.id),
                      onComment: isLoggedIn
                          ? (text) => appState.addComment(postId: post.id, content: text)
                          : null,
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

class _PostCard extends StatefulWidget {
  const _PostCard({
    required this.post,
    required this.liked,
    required this.comments,
    required this.onLike,
    required this.onComment,
  });

  final FeedPost post;
  final bool liked;
  final List comments;
  final VoidCallback onLike;
  final void Function(String text)? onComment;

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _showComments = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final liked = widget.liked;
    final comments = widget.comments;

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
                  onPressed: widget.onLike,
                ),
                const SizedBox(width: 4),
                Text(liked ? 'You and others like this' : 'Like'),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => setState(() => _showComments = !_showComments),
                  icon: const Icon(Icons.mode_comment_outlined, size: 18),
                  label: Text('Comments (${comments.length})'),
                ),
              ],
            ),
            if (_showComments) ...[
              const Divider(),
              for (final c in comments)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: c.isTeacher ? Colors.orange : Colors.grey.shade300,
                        child: Icon(c.isTeacher ? Icons.star : Icons.person, size: 16, color: c.isTeacher ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.author, style: TextStyle(fontWeight: FontWeight.w600, color: c.isTeacher ? Colors.deepOrange : null)),
                            Text(c.content),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.onComment != null)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(hintText: 'Write a comment…'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        final text = _commentController.text.trim();
                        if (text.isEmpty) return;
                        _commentController.clear();
                        widget.onComment!(text);
                        setState(() {});
                      },
                    )
                  ],
                )
            ]
          ],
        ),
      ),
    );
  }
}