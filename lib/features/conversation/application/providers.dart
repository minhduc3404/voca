import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_script_repository.dart';
import '../domain/conversation_script.dart';
import '../domain/script_repository.dart';
import 'conversation_list_controller.dart';
import 'script_player_controller.dart';

/// MVP: script từ mock. Tương lai: repository tải từ Firebase Storage —
/// chỉ sửa provider này, không đụng domain/presentation.
final scriptRepositoryProvider = Provider<ScriptRepository>((ref) {
  return MockScriptRepository();
});

/// Danh sách script — màn `ConversationScreen` (danh mục Giao tiếp).
final conversationListControllerProvider =
    AsyncNotifierProvider<ConversationListController, List<ConversationScript>>(
      ConversationListController.new,
    );

/// Script player — state machine turn cho màn play. Auto-dispose khi rời màn.
final scriptPlayerControllerProvider =
    NotifierProvider<ScriptPlayerController, ScriptPlayState>(
      ScriptPlayerController.new,
    );
