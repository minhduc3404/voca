import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/conversation_script.dart';
import 'providers.dart';

/// Danh sách script cho màn danh mục Giao tiếp.
class ConversationListController extends AsyncNotifier<List<ConversationScript>> {
  @override
  Future<List<ConversationScript>> build() async {
    final repository = ref.watch(scriptRepositoryProvider);
    return repository.fetchScripts();
  }

  /// Nạp lại — dùng cho nút retry khi lỗi.
  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }
}
