# Task Contract — Giữ màn hình sáng khi đang ôn tập (wakelock)

Điền theo `docs/templates/task-contract.md` (PLAN.md §14.3).

---

## Mục tiêu

Bug: màn hình ôn tập là "rảnh tay" (không cần chạm trong tối đa 10s/thẻ, tự động TTS + tự chuyển thẻ). Sau một thời gian không có thao tác chạm, Android coi là idle và tự dim/tắt màn hình theo timeout hệ thống, dù app vẫn đang chạy timer/TTS bên trong — phá hỏng đúng mục đích hands-free. Cần giữ màn hình sáng trong lúc đang ở phiên ôn tập (còn thẻ), tắt wakelock khi ôn xong hoặc rời màn hình.

## Phạm vi file

- **EDIT**: `pubspec.yaml` (+`wakelock_plus`), `lib/features/study/application/providers.dart` (+`wakelockServiceProvider`), `lib/features/study/presentation/memo_screen.dart` (bật/tắt wakelock theo trạng thái phiên)
- **NEW**: `lib/features/study/data/wakelock_service.dart` (`WakelockService` interface + `WakelockPlusService` implement bằng package `wakelock_plus`)
- Không đụng `domain/`, `session_controller.dart`, schema, hay bất kỳ approval zone nào.

## Đầu ra mong đợi

Khi `_SessionBody` đang hiện thẻ (`!isCompleted`), màn hình không tự dim/tắt theo timeout OS. Khi ôn xong (`isCompleted`) hoặc rời màn hình, wakelock tắt — không giữ sáng màn hình vĩnh viễn ngoài lúc cần.

## Ràng buộc kiến trúc

- `WakelockService` là interface trong `data/` (giống pattern `TtsService`) để test override được — plugin cần platform channel không có trong `flutter test`.
- `application/providers.dart` là nơi duy nhất khởi tạo `WakelockPlusService`.
- `memo_screen.dart` gọi qua provider, không import `package:wakelock_plus` trực tiếp.

## Tiêu chí hoàn tất

- `dart analyze` sạch, `flutter test` pass (test wiring qua fake `WakelockService`: enable khi có thẻ, disable khi hoàn tất/dispose).
- Không phá import boundary hiện có (`import_lint` vẫn pass).

---

## Definition of Ready — đã tick

- [x] Requirement rõ: bật wakelock khi còn thẻ, tắt khi hết thẻ/rời màn hình.
- [x] Miền ảnh hưởng: chỉ `features/study/` (presentation + data mới + 1 dòng application).
- [x] Không có approval zone nào bị chạm.

## Hoàn tất — 2026-07-31

`wakelock_plus: ^1.3.2` (resolve 1.7.0), `WakelockService`/`WakelockPlusService`, wiring qua `wakelockServiceProvider`. `_SessionBodyState` bật wakelock khi còn thẻ (`initState`/`didUpdateWidget`), tắt khi hoàn tất hoặc `dispose`. Presentation không import `data/wakelock_service.dart` trực tiếp — field suy ra type qua `late final _wakelockService = ref.read(wakelockServiceProvider)`, giữ đúng ranh giới layer (giống cách `ttsServiceProvider` được dùng, chỉ gọi qua provider chứ không spell type). `dart analyze` sạch, `flutter test` **31/31 pass** (test mới: wakelock bật khi còn thẻ, tắt khi ôn xong). Android dùng `FLAG_KEEP_SCREEN_ON` nội bộ trong plugin, không cần khai báo permission trong `AndroidManifest.xml`. **Chưa verify được trên thiết bị Android thật** — sandbox không build được APK (không có Android SDK), chỉ verify wiring/logic qua widget test.
