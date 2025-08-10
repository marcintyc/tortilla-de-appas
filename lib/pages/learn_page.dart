import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/content_loader.dart';
import '../models/lesson.dart';
import '../state/app_state.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  late Future<List<Lesson>> _future;

  @override
  void initState() {
    super.initState();
    _future = ContentLoader.loadLessons();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final selected = appState.selectedLevel?.label;

    return FutureBuilder<List<Lesson>>(
      future: _future,
      builder: (context, snapshot) {
        final all = snapshot.data ?? [];
        final perLevel = <String, List<Lesson>>{};
        for (final l in all) {
          (perLevel[l.level] ??= []).add(l);
        }
        final levels = ['A1', 'A2', 'B1', 'B2'];
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
          children: [
            Row(
              children: [
                Text('Learning Path', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                DropdownButton<String>(
                  value: selected ?? 'A1',
                  onChanged: (v) {
                    final level = switch (v) {
                      'A1' => CefrLevel.a1,
                      'A2' => CefrLevel.a2,
                      'B1' => CefrLevel.b1,
                      'B2' => CefrLevel.b2,
                      _ => CefrLevel.a1,
                    };
                    appState.setLevel(level);
                  },
                  items: [for (final l in levels) DropdownMenuItem(value: l, child: Text(l))],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Follow your tailored track. Free lessons included; PRO unlocks the full path.'),
            const SizedBox(height: 16),
            for (final level in levels)
              _LevelSection(
                title: 'Level $level',
                lessons: (perLevel[level] ?? [])..sort((a, b) => a.id.compareTo(b.id)),
              ),
          ],
        );
      },
    );
  }
}

class _LevelSection extends StatelessWidget {
  const _LevelSection({required this.title, required this.lessons});
  final String title;
  final List<Lesson> lessons;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        ),
        for (final lesson in lessons)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                if (lesson.isPaid && !appState.isSubscribed) {
                  context.push('/paywall');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Open lesson: ${lesson.title}')),
                  );
                }
              },
              child: _LessonTile(lesson: lesson),
            ),
          ),
      ],
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson});
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final completed = appState.progress[lesson.id]?.completed == true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade100),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF6A00), Color(0xFFFFD200)]),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lesson.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (lesson.isPaid)
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
                const SizedBox(height: 4),
                Text(lesson.description, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(completed ? Icons.check_circle : Icons.arrow_forward_ios, color: completed ? Colors.green : Colors.grey, size: 20),
        ],
      ),
    );
  }
}