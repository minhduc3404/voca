import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/features/vocabulary/data/firebase_catalog_repository.dart';

// Nội dung THẬT fetch trực tiếp từ bucket Firebase Storage của app lúc
// implement (voca-370e1.firebasestorage.app, 2026-07-31) — verify parse
// đúng với dữ liệu production thật, không phải mock tự bịa.
const _realTopicsJson = '''
[
  { "id": "travel", "name": "Du lịch", "wordCount": 120, "version": 1, "file": "travel.json" },
  { "id": "oxford-3000", "name": "Oxford 3000", "wordCount": 3000, "version": 1, "file": "oxford-3000.json" }
]
''';

const _realTravelJson = '''
{
  "topicId": "travel",
  "version": 1,
  "words": [
    {
      "id": "travel-001",
      "term": "itinerary",
      "definition": "lịch trình",
      "phonetic": "/aɪˈtɪn.ə.rer.i/",
      "partOfSpeech": "noun",
      "exampleSentence": "Our itinerary includes three cities in five days."
    },
    {
      "id": "travel-002",
      "term": "passport",
      "definition": "hộ chiếu",
      "phonetic": "/ˈpæs.pɔːrt/",
      "partOfSpeech": "noun",
      "exampleSentence": "Don't forget to bring your passport to the airport."
    }
  ]
}
''';

void main() {
  test('parseTopicsJson đọc đúng dữ liệu thật từ topics.json', () {
    final topics = parseTopicsJson(_realTopicsJson);

    expect(topics, hasLength(2));
    expect(topics[0].id, 'travel');
    expect(topics[0].name, 'Du lịch');
    expect(topics[0].wordCount, 120);
    expect(topics[0].version, 1);
    expect(topics[1].id, 'oxford-3000');
    expect(topics[1].wordCount, 3000);
  });

  test('parseTopicWordsJson đọc đúng dữ liệu thật từ travel.json', () {
    final words = parseTopicWordsJson(_realTravelJson);

    expect(words, hasLength(2));
    expect(words[0].id, 'travel-001');
    expect(words[0].term, 'itinerary');
    expect(words[0].definition, 'lịch trình');
    expect(words[0].phonetic, '/aɪˈtɪn.ə.rer.i/');
    expect(words[0].partOfSpeech, 'noun');
    expect(
      words[0].exampleSentence,
      'Our itinerary includes three cities in five days.',
    );
  });

  test('parseTopicWordsJson xử lý được partOfSpeech null', () {
    const json = '''
    { "topicId": "t", "version": 1, "words": [
      { "id": "t-1", "term": "x", "definition": "y", "phonetic": "/x/",
        "partOfSpeech": null, "exampleSentence": "z" }
    ] }
    ''';

    final words = parseTopicWordsJson(json);

    expect(words.single.partOfSpeech, isNull);
  });
}
