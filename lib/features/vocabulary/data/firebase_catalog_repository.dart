import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/lexicon/pronunciation_segment.dart';
import '../domain/catalog_word.dart';
import '../domain/topic.dart';
import '../domain/vocabulary_catalog_repository.dart';

/// Parse nội dung `topics.json` — tách riêng khỏi lời gọi Firebase Storage
/// thật để test được bằng chuỗi JSON tĩnh, không cần network/platform
/// channel.
List<Topic> parseTopicsJson(String raw) {
  final decoded = jsonDecode(raw) as List<dynamic>;
  return decoded
      .cast<Map<String, dynamic>>()
      .map(
        (json) => Topic(
          id: json['id'] as String,
          name: json['name'] as String,
          wordCount: json['wordCount'] as int,
          version: json['version'] as int,
        ),
      )
      .toList();
}

/// Parse nội dung `<topicId>.json` — xem [parseTopicsJson].
List<CatalogWord> parseTopicWordsJson(String raw) {
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  final words = decoded['words'] as List<dynamic>;
  return words
      .cast<Map<String, dynamic>>()
      .map(
        (json) => CatalogWord(
          id: json['id'] as String,
          term: json['term'] as String,
          definition: json['definition'] as String,
          phonetic: json['phonetic'] as String,
          partOfSpeech: json['partOfSpeech'] as String?,
          exampleSentence: json['exampleSentence'] as String,
          pronunciationSegments: _parseSegments(
            term: json['term'] as String,
            raw: json['pronunciationSegments'],
          ),
        ),
      )
      .toList();
}

List<PronunciationSegment> _parseSegments({
  required String term,
  required Object? raw,
}) {
  if (raw is! List) return const [];

  try {
    final segments = <PronunciationSegment>[
      for (final (index, item) in raw.indexed)
        _parseSegment(item as Map<String, dynamic>, index),
    ];
    final rangesAreOrdered = [
      for (var index = 1; index < segments.length; index++)
        segments[index - 1].end <= segments[index].start,
    ].every((isOrdered) => isOrdered);
    return rangesAreOrdered &&
            segments.every((segment) => segment.isValidFor(term))
        ? segments
        : const [];
  } on FormatException {
    return const [];
  } on TypeError {
    return const [];
  }
}

PronunciationSegment _parseSegment(Map<String, dynamic> json, int position) {
  final stress = switch (json['stress']) {
    'none' => PronunciationStress.none,
    'secondary' => PronunciationStress.secondary,
    'primary' => PronunciationStress.primary,
    _ => throw const FormatException('Invalid pronunciation segment stress.'),
  };
  final timingWeight = json['timingWeight'];
  if (timingWeight is! num) {
    throw const FormatException('Invalid pronunciation segment timingWeight.');
  }
  return PronunciationSegment(
    position: position,
    start: json['start'] as int,
    end: json['end'] as int,
    text: json['text'] as String,
    ipa: json['ipa'] as String,
    stress: stress,
    timingWeight: timingWeight.toDouble(),
  );
}

/// Đọc catalog từ vựng từ Firebase Storage — `topics.json` (metadata nhẹ,
/// index mọi chủ đề) + `<topicId>.json` (nội dung 1 chủ đề, chỉ tải khi
/// cần). Xem schema JSON trong
/// `docs/tasks/2026-07-31-vocabulary-catalog-firebase.md`.
class FirebaseCatalogRepository implements VocabularyCatalogRepository {
  FirebaseCatalogRepository({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  Future<List<Topic>> listTopics() async {
    return parseTopicsJson(await _downloadString('topics.json'));
  }

  @override
  Future<List<CatalogWord>> fetchTopicWords(String topicId) async {
    // File chi tiết luôn đặt tên `<topicId>.json` — quy ước cố định, không
    // cần lưu lại field "file" riêng trong topics.json để tra cứu.
    return parseTopicWordsJson(await _downloadString('$topicId.json'));
  }

  Future<String> _downloadString(String path) async {
    final bytes = await _storage.ref(path).getData();
    if (bytes == null) {
      throw StateError('Không tải được "$path" từ Firebase Storage.');
    }
    return utf8.decode(bytes);
  }
}
