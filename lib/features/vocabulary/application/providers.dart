import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/drift_topic_library_repository.dart';
import '../data/firebase_catalog_repository.dart';
import '../domain/topic_library_repository.dart';
import '../domain/vocabulary_catalog_repository.dart';

final vocabularyCatalogRepositoryProvider =
    Provider<VocabularyCatalogRepository>((ref) {
      return FirebaseCatalogRepository();
    });

final topicLibraryRepositoryProvider = Provider<TopicLibraryRepository>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return DriftTopicLibraryRepository(db);
});
