# Task Contract — Conversation: chuyển sang transcript nghe hiểu (bỏ chọn câu)

Trạng thái: **đã duyệt qua trao đổi trực tiếp với chủ dự án (2026-08-04) — triển khai ngay**.
Bối cảnh: `docs/tasks/2026-08-04-conversation-mvp-script-player.md` (luồng cũ: chọn câu trả lời) đang
không phù hợp người học — xem phân tích trong chat cùng ngày (tab "Luyện nói" nhưng không có sản xuất
ngôn ngữ thật, mọi lựa chọn đều "đúng", metric "đã dùng từ" không phản ánh gì).

## Mục tiêu

Redesign `ConversationPlayScreen` từ mô hình "app nói → user bấm chọn 1 trong các câu gợi ý" sang
mô hình **transcript nghe hiểu**: mở màn thấy được toàn bộ hội thoại (không còn cảm giác "chưa hình
dung được cuộc hội thoại full"), câu đang focus tự phát TTS + highlight từ, điều hướng bằng cuộn/chạm
chọn câu (freehand) **hoặc** nút Next/Previous. Bottom panel hiện các từ khó (`targetVocab`) xuất hiện
trong câu đang focus. Không còn ASR/chọn câu — mục tiêu MVP giai đoạn này là **nghe được đoạn hội thoại**.

Quyết định phạm vi (chốt qua hỏi đáp trực tiếp — không đổi mà không hỏi lại):
- Turn "user" (trước là chọn câu) → bỏ hẳn cơ chế chọn; turn nào cũng tự phát TTS theo role, không cần
  thao tác chọn.
- `ConversationScreen` (danh sách script) và `WarmUpScreen` — **giữ nguyên**, không đổi.
- Điều hướng câu thoại trên transcript: **cả hai** — cuộn/chạm chọn câu tự do, và nút Next/Previous.
- `ConversationSummaryScreen` — **giữ**, nhưng bỏ metric "đã dùng X/Y từ" (không còn ý nghĩa vì không
  còn chọn câu), đổi thành ôn lại toàn bộ `targetVocab` của script.

## Phạm vi file

**EDIT — `lib/features/conversation/`:**
- `domain/conversation_script.dart` — bỏ `ScriptChoice`, bỏ field `choices` khỏi `ConversationTurn`;
  thêm method thuần `ConversationScript.vocabForTurn(turn)` (match `targetVocab.term` xuất hiện trong
  `turn.text`, dùng cho bottom panel "từ khó").
- `data/mock_script_repository.dart` — bỏ mảng `choices` khỏi JSON mock (nội dung `text`/`textVi` giữ
  nguyên, không đổi nội dung script).
- `application/script_player_controller.dart` — thay state machine "advance theo index tuyến tính +
  chọn choice" bằng "focus theo index" (`start`, `focusTurn(index)`, `next`, `previous`, `reset`); bỏ
  `usedTargetWords`, `ActiveTurn.selectedChoice`.
- `presentation/conversation_play_screen.dart` — rewrite: `ListView` transcript đầy đủ (bubble theo
  role, câu focus có highlight TTS + bản dịch), bottom bar (từ khó theo câu focus + Next/Previous +
  CTA "Xem tổng kết" khi tới câu cuối).
- `presentation/conversation_summary_screen.dart` — bỏ param `usedTargetWords`, hiện toàn bộ
  `targetVocab` của script (ôn lại, không phải "đã dùng").

**KHÔNG đụng:** `conversation_screen.dart`, `warmup_screen.dart`, `application/providers.dart`,
`application/tts_turn_highlight_controller.dart`, `domain/script_repository.dart`, mọi thứ ngoài
`features/conversation/`.

**Test — cập nhật theo API mới:**
- `test/features/conversation/domain/conversation_script_test.dart`
- `test/features/conversation/application/script_player_controller_test.dart`
- `test/features/conversation/pure_dart_verify.dart`

## Đầu ra mong đợi

- Mở script → thấy toàn bộ hội thoại dạng transcript ngay lập tức (không phải hé lộ từng câu).
- Câu focus (mặc định câu đầu khi mở màn) tự phát TTS + highlight từ + hiện bản dịch.
- Chạm 1 câu bất kỳ trong transcript → câu đó thành focus, tự phát lại. Next/Previous di chuyển focus
  tuần tự, tự cuộn tới câu đó.
- Bottom panel hiện đúng các `targetVocab` xuất hiện trong câu đang focus (rỗng thì ẩn panel).
- Tới câu cuối → CTA "Xem tổng kết" → `ConversationSummaryScreen` liệt kê toàn bộ `targetVocab` (không
  còn "đã dùng X/Y").
- Unit test domain (`vocabForTurn`) + application (state machine focus/next/previous) pass.

## Ràng buộc kiến trúc

- **Dependency direction (CLAUDE.md §1):** `presentation → application → domain`. `vocabForTurn` là
  method thuần trên `ConversationScript` (domain) — không import Flutter/Riverpod trong domain.
  `ScriptPlayerController` (`application/`) tiếp tục là `Notifier`, chỉ orchestration (focus index),
  không chứa logic match từ khó (logic đó ở domain).
- **Riverpod 3:** giữ `Notifier` pattern hiện có, không đổi sang legacy `StateNotifier`.
- **Domain contract (approval zone §9):** thay đổi `ConversationTurn`/bỏ `ScriptChoice` là thay đổi
  domain contract — đã được chủ dự án duyệt trực tiếp qua trao đổi (không phải AI tự quyết).
- **l10n:** giữ nguyên pattern hiện tại của feature (chuỗi chrome UI hardcode tiếng Việt trong code vì
  `gen_l10n` chưa chạy được trong môi trường — ghi chú sẵn trong task contract MVP trước); không thêm
  key ARB mới trong task này để nhất quán với phần code hiện có.
- **Icon (ADR-009):** chỉ dùng icon đã vendor sẵn (`skip-next`, `skip-prev`, `volume-up`, `book-open`,
  `check-circle`) — không thêm icon mới.
- **No barrel rộng; no folder/file rỗng.**

## Tiêu chí hoàn tất

- [ ] `flutter analyze` sạch (không warning mới do thay đổi này). *(Chưa chạy được — môi trường hiện
      tại không có `flutter`/`dart` binary. Cần verify khi có máy chạy được.)*
- [x] Test domain + application conversation cập nhật theo API mới (`vocabForTurn`,
      `focusTurn`/`next`/`previous`). *(Chưa chạy được vì thiếu flutter engine — đã review logic thủ
      công + cập nhật `pure_dart_verify.dart` song song, nhưng bản thân `pure_dart_verify.dart` cũng
      cần `dart run` để verify, hiện chưa chạy được trong môi trường này.)*
- [x] Không còn tham chiếu `ScriptChoice`/`usedTargetWords`/`selectedChoice`/`ActiveTurn`/`.choices`
      trong codebase (`grep` xác nhận sạch).
- [x] Import không vi phạm dependency direction (domain `vocabForTurn` thuần, không import
      Flutter/Riverpod; application `ScriptPlayerController` chỉ orchestration index).
- [x] `ConversationScreen`/`WarmUpScreen` không đổi (chỉ `ConversationPlayScreen` +
      `ConversationSummaryScreen` + domain/application liên quan đổi).
- [ ] Chạy thử end-to-end trên device/emulator: mở script → thấy transcript đầy đủ → chạm câu bất kỳ
      + Next/Previous đều phát TTS + highlight đúng câu → tới cuối → tổng kết. *(Cần người dùng verify
      trên máy có Flutter.)*

---

## Definition of Ready (§14.4)
- [x] Requirement đã rõ (chốt qua 4 câu hỏi trực tiếp với chủ dự án)
- [x] Miền ảnh hưởng đã xác định (chỉ `features/conversation/`, không đụng study/vocabulary)
- [x] Contract đầu vào/đầu ra có thể kiểm chứng (state machine focus-index + `vocabForTurn`)
- [x] Phụ thuộc bên ngoài đã biết (TtsService qua provider có sẵn, không đổi)
- [x] Tiêu chí hoàn tất có thể test được

## Definition of Done (§14.5)
- [ ] Code đúng kiến trúc
- [ ] Test liên quan đã có và qua
- [ ] Không phá dependency direction
- [ ] Không thêm folder/file rỗng
- [ ] Không tạo import vòng hoặc import trái tầng
- [ ] Tài liệu/ADR cần thiết đã cập nhật (contract này)
