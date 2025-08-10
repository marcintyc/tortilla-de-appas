import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../data/content_loader.dart';
import '../models/lesson.dart';
import '../state/app_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Lesson>> _future;

  @override
  void initState() {
    super.initState();
    _future = ContentLoader.loadLessons();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola! Let\'s learn Spanish',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your level and start your path. Free and PRO lessons available.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final level in CefrLevel.values)
                      ChoiceChip(
                        selected: appState.selectedLevel == level,
                        label: Text(level.label),
                        onSelected: (_) => appState.setLevel(level),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/learn'),
                  child: const Text('Go to Learning Path'),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Free lessons for you',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ),
        FutureBuilder<List<Lesson>>(
          future: _future,
          builder: (context, snapshot) {
            final lessons = (snapshot.data ?? [])
                .where((l) => !l.isPaid && (appState.selectedLevel?.label == null || l.level == appState.selectedLevel!.label))
                .toList();
            if (lessons.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No free lessons for this filter yet. Try another level.'),
                ),
              );
            }
            return SliverList.builder(
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _LessonCard(lesson: lesson),
                );
              },
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson});
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final completed = appState.progress[lesson.id]?.completed == true;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF4D4D), Color(0xFFFF8C00)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lesson.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      Text('Level ${lesson.level}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(completed ? Icons.check_circle : Icons.radio_button_unchecked, color: completed ? Colors.green : Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Text(lesson.description),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.tonal(
                  onPressed: () {
                    appState.markLessonCompleted(lesson.id, !completed);
                  },
                  child: Text(completed ? 'Mark as not done' : 'Mark as done'),
                ),
                const SizedBox(width: 8),
                TextButton(onPressed: () => context.go('/learn'), child: const Text('View path')),
              ],
            )
          ],
        ),
      ),
    );
  }
}