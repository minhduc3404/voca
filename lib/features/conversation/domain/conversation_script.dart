import 'dart:convert';

/// Một từ vựng mục tiêu của script — hiện trong warm-up và summary.
class TargetVocabItem {
  const TargetVocabItem({required this.term, required this.senseVi});

  final String term;
  final String senseVi;

  factory TargetVocabItem.fromJson(Map<String, dynamic> json) {
    return TargetVocabItem(
      term: json['term'] as String,
      senseVi: json['senseVi'] as String,
    );
  }
}

/// Một lượt trong script — cả `speaker: app` lẫn `speaker: user` đều là câu
/// thoại cố định, tự phát TTS theo role khi được focus (không còn chọn câu).
class ConversationTurn {
  const ConversationTurn({
    required this.id,
    required this.speaker,
    required this.text,
    required this.textVi,
  });

  final String id;

  /// `"app"` hoặc `"user"` — theo schema script.
  final String speaker;

  /// `true` = turn do app nói (TTS), `false` = turn do vai người dùng nói.
  bool get isAppTurn => speaker == 'app';

  final String text;
  final String textVi;

  factory ConversationTurn.fromJson(Map<String, dynamic> json) {
    return ConversationTurn(
      id: json['id'] as String,
      speaker: json['speaker'] as String,
      text: json['text'] as String,
      textVi: json['textVi'] as String,
    );
  }
}

/// Vai trò (app / người dùng) trong script — hiển thị tên ở màn play.
class ScriptRole {
  const ScriptRole({required this.name, required this.nameVi});

  final String name;
  final String nameVi;

  factory ScriptRole.fromJson(Map<String, dynamic> json) {
    return ScriptRole(
      name: json['name'] as String,
      nameVi: json['nameVi'] as String,
    );
  }
}

/// Kịch bản hội thoại — dữ liệu nội dung thuần, parse từ JSON.
///
/// Chuỗi `text`/`textVi` NẰM TRONG script (không phải l10n keys).
/// Word timing KHÔNG lưu ở đây — tính bằng pipeline TTS hiện có.
class ConversationScript {
  const ConversationScript({
    required this.schemaVersion,
    required this.id,
    required this.title,
    required this.titleVi,
    required this.description,
    required this.descriptionVi,
    required this.difficulty,
    required this.tags,
    required this.estimatedMinutes,
    required this.appRole,
    required this.userRole,
    required this.targetVocab,
    required this.turns,
  });

  final int schemaVersion;
  final String id;
  final String title;
  final String titleVi;
  final String description;
  final String descriptionVi;

  /// `beginner` | `intermediate` | `advanced`.
  final String difficulty;
  final List<String> tags;
  final int estimatedMinutes;

  final ScriptRole appRole;
  final ScriptRole userRole;
  final List<TargetVocabItem> targetVocab;
  final List<ConversationTurn> turns;

  factory ConversationScript.fromJson(Map<String, dynamic> json) {
    final roles = json['roles'] as Map<String, dynamic>;
    return ConversationScript(
      schemaVersion: json['schemaVersion'] as int,
      id: json['id'] as String,
      title: json['title'] as String,
      titleVi: json['titleVi'] as String,
      description: json['description'] as String? ?? '',
      descriptionVi: json['descriptionVi'] as String? ?? '',
      difficulty: json['difficulty'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      estimatedMinutes: json['estimatedMinutes'] as int,
      appRole: ScriptRole.fromJson(roles['app'] as Map<String, dynamic>),
      userRole: ScriptRole.fromJson(roles['user'] as Map<String, dynamic>),
      targetVocab: (json['targetVocab'] as List<dynamic>)
          .map((e) => TargetVocabItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      turns: (json['turns'] as List<dynamic>)
          .map((e) => ConversationTurn.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory ConversationScript.fromJsonString(String source) {
    return ConversationScript.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }

  /// Các `targetVocab` xuất hiện trong `turn.text` — dùng cho panel "từ khó"
  /// của câu đang focus trên màn play.
  List<TargetVocabItem> vocabForTurn(ConversationTurn turn) {
    final lowerText = turn.text.toLowerCase();
    return targetVocab
        .where((vocab) => lowerText.contains(vocab.term.toLowerCase()))
        .toList();
  }
}
