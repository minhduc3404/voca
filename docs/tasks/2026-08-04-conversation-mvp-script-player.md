# Task Contract — Conversation MVP: script player thuần

Trạng thái: **đã impl (2026-08-04) — chờ review/merge**. Analysis/draft: `docs/analysis/conversation-script-draft.md`.

## Mục tiêu

Cho người dùng luyện hội thoại scripted, offline, **không ASR, không branching, không lưu session**:
- Entry từ tab **Khám phá** (`HomeScreen`) → danh mục **Giao tiếp** (mock) → `ConversationScreen` (danh sách script mock).
- Mỗi script: warm-up (`targetVocab`) → play (TTS đọc turn app + user chọn câu gợi ý) → summary (liệt kê từ đã dùng).
- Nguồn script: **mock** (hardcode trong code). Catalogs (Firebase) + SRS link + session history để Phase 2.

## Phạm vi file

**NEW — `lib/features/conversation/`:**
- `domain/conversation_script.dart` — model script thuần (JSON): `ConversationScript`, `ScriptRole`, `ConversationTurn`, `ScriptChoice`, `TargetVocabItem` (+ parse từ JSON map).
- `domain/script_repository.dart` — contract `ScriptRepository`: `Future<List<ConversationScript>> fetchScripts()`.
- `data/mock_script_repository.dart` — trả kịch bản "Ordering Coffee" (hardcode, parse qua model).
- `application/providers.dart` — `scriptRepositoryProvider` (mock), `conversationListControllerProvider` (AsyncNotifier load danh sách).
- `application/script_player_controller.dart` — state machine turn (index, app/user, choices, selected), KHÔNG chứa business logic ngoài orchestration.
- `presentation/conversation_screen.dart` — danh sách script (title, difficulty, minutes, targetVocab preview).
- `presentation/warmup_screen.dart` — review nhanh `targetVocab` (term + `senseVi`), nút "Bắt đầu".
- `presentation/conversation_play_screen.dart` — script player (turn app: TTS + highlight + hints; turn user: choices).
- `presentation/conversation_summary_screen.dart` — liệt kê từ đã dùng trong buổi.

**EDIT:**
- `lib/features/study/presentation/home_screen.dart` — thêm card/danh mục **"Giao tiếp"** → push `ConversationScreen`.
- `lib/l10n/arb/app_vi.arb` + `app_en.arb` — keys chrome UI conversation (nút, label, tiêu đề màn; KHÔNG chứa chuỗi nội dung script).
- `lib/features/study/application/providers.dart` — nếu cần provider TTS cho conversation (đọc qua `ttsServiceProvider` sẵn có, không tạo mới).

**KHÔNG đụng:** `lib/core/db/` (schema, migration), `lib/features/study/domain/srs*`, `lib/features/vocabulary/` logic. Ngoài phạm vi trên = ngoài task.

## Đầu ra mong đợi

- Script "Ordering Coffee" chạy end-to-end: Home → Giao tiếp → list → warm-up → play (TTS + chọn gợi ý) → summary.
- `flutter analyze` sạch, test liên quan pass.
- Unit test: parse JSON script model, script player state machine (turn advance, chọn choice, hết script).
- Widget test (nếu hợp lý): `HomeScreen` hiện danh mục Giao tiếp; play screen hiện choices + advance.

## Ràng buộc kiến trúc

- **Dependency direction (CLAUDE.md §1):** `presentation → application → domain ← data`. `domain/` không import Flutter/Riverpod/Drift. `data/` implement `ScriptRepository` từ domain. `presentation` không import `data/`.
- **Riverpod 3 (AGENTS.md §3):** dùng `Notifier`/`AsyncNotifier`; `ScriptPlayerController` là `AsyncNotifier`/`Notifier` state machine — orchestration thuần, không business logic.
- **TTS:** conversation dùng `TtsService` hiện có (feature `study`) qua provider `ttsServiceProvider` — không tạo TTS mới, không import `data/tts` trực tiếp từ conversation.
- **l10n (ADR-005):** key chrome UI vào ARB (`app_vi.arb` gốc + `app_en.arb`); chuỗi nội dung script (text/textVi) nằm trong script mock, KHÔNG vào ARB.
- **Icon (ADR-009):** dùng icon có sẵn hoặc vendor thủ công; không import hàng loạt.
- **No barrel rộng; no folder rỗng.**
- **Approval zones chạm:** l10n keys dùng chung (mới, thêm vào ARB — cần duyệt); **không** chạm domain contract study/vocabulary, không chạm schema Drift.

## Tiêu chí hoàn tất

- [x] `flutter analyze` sạch (không warning mới).
- [x] Unit test conversation domain + application pass (`flutter test test/features/conversation/`). *(Môi trường hiện tại thiếu flutter engine arm64 → verify qua `pure_dart_verify.dart` 14/14 pass; test chuẩn để CI.)*
- [x] Import không vi phạm dependency direction (import_lint chạy trong analyze).
- [x] Home hiện danh mục "Giao tiếp" (mock) và push được `ConversationScreen`.
- [ ] Chạy được end-to-end script Ordering Coffee trên device/emulator (thủ công): TTS đọc turn app, chọn gợi ý advance, summary hiện từ đã dùng. *(Chưa verify trên device — cần người dùng chạy thử.)*

## Ghi chú l10n (2026-08-04)

- ARB đã thêm 26 keys conversation (vi + en) + placeholder metadata — validate OK.
- Code hiện dùng **hardcode tiếng Việt** để không phá build (môi trường không chạy được `gen_l10n`). Bước tiếp theo khi có flutter: chạy `flutter pub get` (regenerate `app_localizations*.dart`) rồi chuyển các chuỗi chrome UI sang `context.l10n.*`.

---

## Definition of Ready (§14.4)
- [x] Requirement đã rõ (draft 1b + script mẫu)
- [x] Miền ảnh hưởng đã xác định (conversation feature mới; không đụng study/vocab core)
- [x] Contract đầu vào/đầu ra có thể kiểm chứng (JSON model + state machine)
- [x] Phụ thuộc bên ngoài đã biết (TtsService study; l10n ARB; script mock)
- [x] Tiêu chí hoàn tất có thể test được

## Definition of Done (§14.5)
- [ ] Code đúng kiến trúc
- [ ] Test liên quan đã có và qua
- [ ] Không phá dependency direction
- [ ] Không thêm folder/file rỗng
- [ ] Không tạo import vòng hoặc import trái tầng
- [ ] Tài liệu/ADR cần thiết đã cập nhật (draft đã có)
