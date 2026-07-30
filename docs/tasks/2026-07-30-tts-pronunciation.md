# Task Contract — Phát âm (TTS) cho thẻ từ vựng

Điền theo `docs/templates/task-contract.md` (PLAN.md §14.3).

---

## Mục tiêu

Người dùng bấm nút loa trên mặt trước thẻ (`WordCard`) để nghe phát âm tiếng Anh của `term` qua text-to-speech.

## Phạm vi file

- **EDIT**: `pubspec.yaml` (+`flutter_tts`), `lib/features/study/presentation/widgets/word_card.dart` (thêm nút loa + callback `onSpeak`), `lib/features/study/presentation/memo_screen.dart` (wiring `onSpeak`), `lib/features/study/application/providers.dart` (+`ttsServiceProvider`)
- **NEW**: `lib/features/study/data/tts_service.dart` (`TtsService` interface + `FlutterTtsService` implement bằng package `flutter_tts`)
- Không đụng `domain/`, `session_controller.dart`, schema, hay bất kỳ approval zone nào.

## Đầu ra mong đợi

Nút loa trên `WordCard`, bấm vào phát âm `term` bằng tiếng Anh (`en-US`). Test verify wiring (callback được gọi đúng), không test được audio thật (sandbox không có loa/thiết bị âm thanh).

## Ràng buộc kiến trúc

- `TtsService` là interface trong `data/` (giống pattern `ProgressRepository`) để test override được, không phụ thuộc trực tiếp `FlutterTtsService` thật trong widget test (tương tự lý do phải override `progressRepositoryProvider` ở Phase 2 — plugin cần platform channel không có trong `flutter test`).
- `word_card.dart` **không** import `flutter_riverpod` hay data trực tiếp — nhận `onSpeak: VoidCallback` từ parent, giống pattern `ControlBar` đã có (widget "dumb", không tự biết TTS tồn tại).
- `application/providers.dart` là nơi duy nhất khởi tạo `FlutterTtsService`.

## Tiêu chí hoàn tất

- `dart analyze` sạch, `flutter test` pass (test wiring qua fake `TtsService`).
- Không phá import boundary hiện có (`import_lint` vẫn pass).
- `WordCard`/`ControlBar` vẫn đúng "dumb widget" pattern.

---

## Definition of Ready — đã tick

- [x] Requirement rõ: 1 nút, 1 hành động (speak term).
- [x] Miền ảnh hưởng: chỉ `features/study/` (presentation + data mới + 1 dòng application).
- [x] Không có approval zone nào bị chạm.

## Hoàn tất — 2026-07-30

`flutter_tts: ^4.2.5`, `TtsService`/`FlutterTtsService`, nút loa trên `WordCard` mặt trước, wiring qua `ttsServiceProvider`. `dart analyze` sạch, `flutter test` **25/25 pass** (2 test mới: bấm nút loa gọi `onSpeak` không lật thẻ; bấm vào thẻ lật bình thường). **Chưa verify được audio thật** — sandbox không có thiết bị âm thanh, chỉ verify wiring qua callback/fake, không verify chất lượng giọng đọc thật trên thiết bị.
- [x] Dependency: `flutter_tts` — package mới, cần thêm vào pubspec.
- [x] Tiêu chí hoàn tất đo được (test wiring, analyze sạch).
