import 'package:flutter/material.dart';

import '../../domain/study_card.dart';

/// Hiển thị mặt trước (term + phiên âm + từ loại + nút loa) / mặt sau
/// (definition + câu ví dụ) của thẻ học, chạm để lật.
class WordCard extends StatefulWidget {
  const WordCard({required this.card, required this.onSpeak, super.key});

  final StudyCard card;

  /// Gọi khi bấm nút loa — không phụ thuộc TTS trực tiếp, giống pattern
  /// [ControlBar] (widget "dumb", caller quyết định hành vi thật).
  final VoidCallback onSpeak;

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  bool _showDefinition = false;

  @override
  void didUpdateWidget(covariant WordCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.id != widget.card.id) {
      setState(() => _showDefinition = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => setState(() => _showDefinition = !_showDefinition),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: _showDefinition
                ? _CardBack(card: widget.card, textTheme: textTheme)
                : _CardFront(
                    card: widget.card,
                    textTheme: textTheme,
                    onSpeak: widget.onSpeak,
                  ),
          ),
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({
    required this.card,
    required this.textTheme,
    required this.onSpeak,
  });

  final StudyCard card;
  final TextTheme textTheme;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          card.term,
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              card.partOfSpeech == null
                  ? card.phonetic
                  : '${card.phonetic} · ${card.partOfSpeech}',
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up, size: 20),
              tooltip: 'Nghe phát âm',
              onPressed: onSpeak,
            ),
          ],
        ),
      ],
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.card, required this.textTheme});

  final StudyCard card;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          card.definition,
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          card.exampleSentence,
          style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
