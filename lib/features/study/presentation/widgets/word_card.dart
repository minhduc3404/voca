import 'package:flutter/material.dart';

import 'package:voca_app/app/theme/app_icon.dart';
import 'package:voca_app/app/theme/app_theme.dart';
import 'package:voca_app/core/lexicon/pronunciation_segment.dart';

import '../../domain/study_card.dart';

/// Widget thuần: chỉ render range/segment state do application điều phối.
class WordCard extends StatelessWidget {
  const WordCard({
    required this.card,
    required this.onSpeak,
    this.activeWordStart,
    this.activeWordEnd,
    this.activeSegmentPosition,
    super.key,
  });

  final StudyCard card;
  final VoidCallback onSpeak;
  final int? activeWordStart;
  final int? activeWordEnd;
  final int? activeSegmentPosition;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                card.partOfSpeech == null
                    ? card.phonetic
                    : '${card.phonetic} · ${card.partOfSpeech}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  letterSpacing: .5,
                  color: AppColors.phonetic,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                key: const Key('word-card-speak-button'),
                icon: AppIcon('volume-up', size: 18, color: AppColors.phonetic),
                visualDensity: VisualDensity.compact,
                tooltip: 'Nghe phát âm',
                onPressed: onSpeak,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _TermSegments(
            term: card.term,
            segments: card.pronunciationSegments,
            activeWordStart: activeWordStart,
            activeWordEnd: activeWordEnd,
            activeSegmentPosition: activeSegmentPosition,
            style: textTheme.displaySmall,
          ),
          const SizedBox(height: 22),
          Text(
            card.definition,
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              '"${card.exampleSentence}"',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 15,
                height: 1.5,
                color: AppColors.textFainter,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _TermSegments extends StatelessWidget {
  const _TermSegments({
    required this.term,
    required this.segments,
    required this.activeWordStart,
    required this.activeWordEnd,
    required this.activeSegmentPosition,
    required this.style,
  });

  final String term;
  final List<PronunciationSegment> segments;
  final int? activeWordStart;
  final int? activeWordEnd;
  final int? activeSegmentPosition;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (activeWordStart == null || activeWordEnd == null) {
      return Text(term, style: style, textAlign: TextAlign.center);
    }

    final boundaries = <int>{0, term.length, activeWordStart!, activeWordEnd!};
    for (final segment in segments) {
      boundaries
        ..add(segment.start)
        ..add(segment.end);
    }
    final sorted = boundaries.toList()..sort();
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var index = 0; index < sorted.length - 1; index++)
          _TermSpan(
            key: Key('word-card-term-${sorted[index]}-${sorted[index + 1]}'),
            text: term.substring(sorted[index], sorted[index + 1]),
            isActive: _isActive(sorted[index], sorted[index + 1]),
            style: style,
          ),
      ],
    );
  }

  bool _isActive(int start, int end) {
    PronunciationSegment? segment;
    for (final candidate in segments) {
      if (candidate.start == start && candidate.end == end) {
        segment = candidate;
        break;
      }
    }
    if (activeSegmentPosition != null) {
      return segment?.position == activeSegmentPosition;
    }
    return start < activeWordEnd! && end > activeWordStart!;
  }
}

class _TermSpan extends StatelessWidget {
  const _TermSpan({
    required this.text,
    required this.isActive,
    required this.style,
    super.key,
  });

  final String text;
  final bool isActive;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1.08 : 1,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        style: isActive
            ? (style ?? const TextStyle()).copyWith(color: AppColors.accent)
            : style ?? const TextStyle(),
        child: Text(text),
      ),
    );
  }
}
