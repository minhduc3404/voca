import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/drift_progress_repository.dart';
import '../domain/progress_repository.dart';

/// Điểm nối duy nhất giữa application và implementation cụ thể của
/// [ProgressRepository]. Chuyển từ `FakeProgressRepository` sang
/// `DriftProgressRepository` ở Phase 2 — chỉ sửa file này, không đụng
/// `domain/`, `session_controller.dart`, hay `presentation/`.
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftProgressRepository(db);
});
