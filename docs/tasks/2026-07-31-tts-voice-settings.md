# Task Contract — Điều chỉnh tốc độ đọc + chọn giọng TTS

Điền theo `docs/templates/task-contract.md` (PLAN.md §14.3).

---

## Mục tiêu

Người dùng vào màn cài đặt TTS, chỉnh tốc độ đọc (slider) và chọn giọng đọc tiếng Anh cụ thể (nếu thiết bị có nhiều giọng en-*). Lựa chọn được lưu lại (`shared_preferences`, chỉ là cấu hình UI nhẹ — không phải dữ liệu domain) và áp dụng ngay cho lần phát âm tiếp theo, kể cả sau khi tắt/mở lại app.

## Phạm vi file

- **EDIT**: `lib/features/study/data/tts_service.dart` (+`TtsVoice`, +`getVoices`/`setVoice`/`setSpeechRate` vào `TtsService`), `lib/features/study/application/providers.dart` (+`ttsSettingsRepositoryProvider`, +`availableVoicesProvider`), `lib/features/study/presentation/memo_screen.dart` (nút mở màn cài đặt TTS), `pubspec.yaml` (đã có `shared_preferences`, không cần thêm dependency mới)
- **NEW**: `lib/features/study/data/tts_settings_repository.dart` (`TtsSettings` value class + `TtsSettingsRepository` interface + `SharedPreferencesTtsSettingsRepository`), `lib/features/study/application/tts_settings_controller.dart` (`AsyncNotifier<TtsSettings>`, load/save + áp dụng vào `TtsService`), `lib/features/study/presentation/tts_settings_screen.dart`
- Không đụng `domain/`, không đụng Drift schema/migration, không thêm ARB key mới (giữ nguyên convention hiện tại: chuỗi UI tiếng Việt hardcode trong widget, chỉ `appTitle` đi qua `AppLocalizations`).

## Đầu ra mong đợi

- Icon cài đặt trên AppBar `MemoScreen` → mở `TtsSettingsScreen`.
- Slider tốc độ đọc (0.25–1.0, theo range của `flutter_tts`), danh sách giọng tiếng Anh (`locale` bắt đầu bằng `en`) lấy từ `getVoices()`, chọn 1 giọng bằng `RadioListTile`.
- Đổi giá trị → áp dụng ngay cho `TtsService` + lưu `shared_preferences`; mở lại app đọc lại đúng lựa chọn cũ.

## Ràng buộc kiến trúc

- `TtsVoice`/`TtsSettings` là model của `data/` — presentation không import trực tiếp (`late final ... = ref.read(...)` để suy type, giống pattern đã dùng cho `WakelockService`), luôn đi qua `application/providers.dart`.
- `TtsSettingsRepository` bọc `shared_preferences` trong `data/` (đúng CLAUDE.md §4 — cấu hình UI nhẹ, không phải dữ liệu domain).
- `TtsSettingsController` (application) không chứa logic UI, chỉ điều phối load/save + gọi `TtsService`.
- Điều hướng dùng `Navigator.push`/`pop` (baseline hiện tại, không thêm `go_router`).

## Tiêu chí hoàn tất

- `dart analyze` sạch, `flutter test` pass — cập nhật `_FakeTtsService` (thêm no-op cho method mới) + fake mới cho `TtsSettingsRepository`, test cho `TtsSettingsController` (load/save/apply) và `TtsSettingsScreen` (đổi slider/chọn giọng gọi đúng controller).
- Không phá `import_lint`.
- Không verify được giọng đọc thật (sandbox không có audio) — chỉ verify wiring/logic.

---

## Definition of Ready — đã tick

- [x] Requirement rõ: slider tốc độ + chọn giọng, lưu persist qua `shared_preferences`.
- [x] Miền ảnh hưởng: chỉ `features/study/` (data mới, application mới, presentation mới + wiring).
- [x] Không có approval zone nào bị chạm (không đổi domain, không đổi Drift schema, không thêm navigation cấp app mới ngoài 1 `Navigator.push`, không thêm ARB key chung).

## Hoàn tất — 2026-07-31

`TtsVoice`/`TtsSettings` + `TtsSettingsRepository`/`SharedPreferencesTtsSettingsRepository` (`data/`), `TtsSettingsController` (`application/`), `TtsSettingsScreen` (`presentation/`, mở qua icon `settings_voice` trên AppBar `MemoScreen`). `dart analyze` sạch, `flutter test` **38/38 pass** (7 test mới: repository load/save, controller build/update, screen đổi slider/chọn giọng).

**Bug phát hiện + fix trong lúc verify bằng browser thật (không chỉ tin `flutter test`)**: `await tts.setSpeechRate(...)` trong `TtsSettingsController.build()` treo vô hạn khi chạy web thật (platform channel `flutter_tts` không resolve trong Chromium headless của sandbox) — làm màn cài đặt kẹt loading mãi. Fix: coi việc áp dụng cấu hình vào `TtsService` là side-effect ra plugin ngoài, không `await` nó trong đường tải dữ liệu (`unawaited`, cùng nguyên tắc "fire-and-forget" đã áp dụng cho `speak()` ở `memo_screen.dart`) — `build()` chỉ chờ đọc `shared_preferences` (nhanh, đáng tin), không chờ engine TTS. Đồng thời thêm `.timeout(5s)` cho `availableVoicesProvider` vì `getVoices()` cũng là gọi ra plugin/engine ngoài không đảm bảo phản hồi trên mọi thiết bị.

**Giới hạn verify còn lại**: browser headless trong sandbox có hiện tượng WebGL/engine tự restart liên tục (không liên quan tới logic app — đã cô lập bằng script Dart thuần xác nhận `.timeout()` hoạt động đúng), nên không chụp được ảnh màn `TtsSettingsScreen` ở trạng thái cuối đáng tin cậy trong môi trường này. Đã verify chắc chắn qua: `dart analyze`, toàn bộ `flutter test` (bao gồm test giả lập đúng hành vi timeout/fire-and-forget), và xác nhận độc lập cơ chế `Future.timeout()` bằng script Dart riêng. Chưa verify được giọng đọc thật + UI thật trên thiết bị/trình duyệt thật.
