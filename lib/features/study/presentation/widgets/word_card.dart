import 'package:flutter/material.dart';

import '../../domain/study_card.dart';

/// Hiển thị mặt trước (term) / mặt sau (definition) của thẻ học, chạm để lật.
class WordCard extends StatefulWidget {
  const WordCard({required this.card, super.key});

  final StudyCard card;

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
    return GestureDetector(
      onTap: () => setState(() => _showDefinition = !_showDefinition),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              _showDefinition ? widget.card.definition : widget.card.term,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
