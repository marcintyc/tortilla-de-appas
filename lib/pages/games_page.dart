import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final fcRaw = await rootBundle.loadString('assets/content/flashcards.json');
    final quizRaw = await rootBundle.loadString('assets/content/quiz.json');
    return {
      'flashcards': jsonDecode(fcRaw),
      'quiz': jsonDecode(quizRaw),
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
          children: [
            Text('Games', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Practice with flashcards and quick quizzes.'),
            const SizedBox(height: 16),
            _Flashcards(cards: (data['flashcards'] as List).cast<Map<String, dynamic>>()),
            const SizedBox(height: 16),
            _Quiz(questions: (data['quiz'] as List).cast<Map<String, dynamic>>()),
          ],
        );
      },
    );
  }
}

class _Flashcards extends StatefulWidget {
  const _Flashcards({required this.cards});
  final List<Map<String, dynamic>> cards;
  @override
  State<_Flashcards> createState() => _FlashcardsState();
}

class _FlashcardsState extends State<_Flashcards> {
  int _index = 0;
  bool _showBack = false;

  void _next() {
    setState(() {
      _index = (_index + 1) % widget.cards.length;
      _showBack = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.cards[_index];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.style_outlined),
                SizedBox(width: 8),
                Text('Flashcards', style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _showBack = !_showBack),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _showBack ? card['back'] as String : card['front'] as String,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(onPressed: () => setState(() => _showBack = !_showBack), icon: const Icon(Icons.flip), label: const Text('Flip')),
                const Spacer(),
                FilledButton.icon(onPressed: _next, icon: const Icon(Icons.navigate_next), label: const Text('Next')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Quiz extends StatefulWidget {
  const _Quiz({required this.questions});
  final List<Map<String, dynamic>> questions;
  @override
  State<_Quiz> createState() => _QuizState();
}

class _QuizState extends State<_Quiz> {
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _submitted = false;

  void _submit() {
    setState(() {
      _submitted = true;
      final q = widget.questions[_index];
      if (_selected == (q['answer'] as int)) _score++;
    });
  }

  void _next() {
    setState(() {
      _index = (_index + 1) % widget.questions.length;
      _selected = null;
      _submitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[_index];
    final opts = (q['options'] as List).cast<String>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.quiz_outlined),
                SizedBox(width: 8),
                Text('Quiz', style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            Text(q['question'] as String, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (var i = 0; i < opts.length; i++)
              RadioListTile<int>(
                value: i,
                groupValue: _selected,
                onChanged: _submitted ? null : (v) => setState(() => _selected = v),
                title: Text(opts[i]),
              ),
            Row(
              children: [
                if (!_submitted)
                  FilledButton(onPressed: _selected == null ? null : _submit, child: const Text('Submit'))
                else ...[
                  if (_selected == q['answer']) const Text('Correct!', style: TextStyle(color: Colors.green)) else const Text('Try again', style: TextStyle(color: Colors.red)),
                  const Spacer(),
                  FilledButton.tonal(onPressed: _next, child: const Text('Next')),
                ]
              ],
            ),
            const SizedBox(height: 8),
            Text('Score: $_score')
          ],
        ),
      ),
    );
  }
}