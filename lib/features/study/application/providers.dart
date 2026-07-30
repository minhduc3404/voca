import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fake_progress_repository.dart';
import '../domain/progress_repository.dart';

/// Điểm nối duy nhất giữa application và implementation cụ thể của
/// [ProgressRepository]. Phase 2 chỉ cần sửa file này sang
/// `DriftProgressRepository` — xem PLAN-PHASE-1-2.md.
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return FakeProgressRepository();
});
