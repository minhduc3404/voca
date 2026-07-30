class StudyCard {
  const StudyCard({
    required this.id,
    required this.term,
    required this.definition,
    required this.language,
  });

  final int id;
  final String term;
  final String definition;
  final String language;
}
