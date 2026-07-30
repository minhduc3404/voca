class StudyCard {
  const StudyCard({
    required this.id,
    required this.term,
    required this.definition,
    required this.language,
    required this.phonetic,
    required this.partOfSpeech,
    required this.exampleSentence,
  });

  final int id;
  final String term;
  final String definition;
  final String language;
  final String phonetic;
  final String partOfSpeech;
  final String exampleSentence;
}
