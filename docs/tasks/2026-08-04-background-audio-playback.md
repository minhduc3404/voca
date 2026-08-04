# Task Contract — Phát TTS nền + điều khiển lock screen

Điền theo `docs/templates/task-contract.md` (PLAN.md §14.3). **Nháp — chờ duyệt**, chưa implement.

---

## Bối cảnh

Luồng ôn tập rảnh tay hiện tại (`memo_screen.dart`, `_SessionBodyState`) chỉ chạy khi app đang hiển thị: toàn bộ auto-speak/auto-advance dựa trên `Timer`/`AnimationController` của widget — khi app xuống nền hoặc khóa màn hình, các Timer này dừng theo lifecycle của Flutter, và không có notification/media control nào hiển thị. Yêu cầu: nghe từ vựng tiếp tục chạy khi tắt màn hình/thu nhỏ app, có điều khiển trên lock screen/notification (giống nghe nhạc/podcast).

**Quyết định đã chốt qua trao đổi (2026-08-04):**
- Khi nền/khóa máy: **tiếp tục tự động chuyển thẻ hết cả session**, không dừng lại chờ mở app.
- Điều khiển lock screen: **Play/Pause + Next/Previous**.

## Mục tiêu

Thêm khả năng phát TTS chạy nền (Android foreground service / iOS background audio) cho đúng 1 luồng: ôn tập rảnh tay hiện có trong `MemoScreen`. Có media control thật trên lock screen/notification: Play/Pause, Next, Previous.

## Phạm vi file

- **pubspec.yaml**: thêm `audio_service` (kéo theo `audio_session`).
- **NEW** `lib/features/study/data/study_audio_handler.dart` — implement `BaseAudioHandler` (audio_service). Quản lý queue = các thẻ đến hạn của session hiện tại (`MediaItem.id` = `card.id` dạng chuỗi, `title` = `card.term`). `play()` gọi `TtsService.speak()`; khi đọc xong (dựa vào `awaitSpeakCompletion(true)` trên `flutter_tts` để `speak()` Future chỉ hoàn tất khi đọc xong) → tự động submit rating + chuyển bài kế (xem "Hành vi SRS khi nền" dưới).
- **EDIT** `lib/features/study/data/tts_service.dart` — thêm `Future<void> stop()` vào interface + implement (`_tts.stop()`), cần cho Pause/skip ngắt đọc giữa chừng.
- **NEW** `lib/features/study/application/background_playback_controller.dart` — `Notifier` cầu nối `SessionController` (nguồn thẻ + nơi thật sự gọi `submitAnswer`) với `StudyAudioHandler` (nơi phát + hiện lock screen). Không đặt business logic SRS ở đây — chỉ điều phối gọi.
- **EDIT** `lib/features/study/application/providers.dart` — thêm provider cho `AudioHandler`/`BackgroundPlaybackController`.
- **EDIT** `lib/features/study/presentation/memo_screen.dart` — khi user bật "chế độ nghe nền" (nút mới, hoặc tự bật khi rời app — cần quyết định UX cụ thể lúc code), chuyển điều khiển auto-advance từ Timer nội bộ hiện tại sang gọi `BackgroundPlaybackController`. **Không xóa** luồng foreground hiện có nếu người dùng ở lại trong app — audio_service vẫn là nguồn phát duy nhất kể cả khi app đang mở, tránh chạy 2 nguồn phát song song.
- **Android**: `android/app/src/main/AndroidManifest.xml` — thêm permission `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, `POST_NOTIFICATIONS` (Android 13+, cần runtime request), khai báo `<service>` cho audio_service theo hướng dẫn plugin.
- **iOS**: `ios/Runner/Info.plist` — thêm `UIBackgroundModes: [audio]`.

## Đầu ra mong đợi

- Bấm nghe 1 thẻ → khóa màn hình → app vẫn tiếp tục tự đọc + tự chuyển thẻ, submit rating vào DB đúng như đang mở app.
- Lock screen/notification hiện tên từ đang đọc, có nút Play/Pause/Next/Previous hoạt động thật.
- Mở lại app → `MemoScreen` phản ánh đúng thẻ hiện tại (đồng bộ 2 chiều với audio_service, không lệch state).

## Hành vi SRS khi chạy nền (cần user xác nhận lại — chưa chốt hẳn)

Vì mỗi lần "chuyển thẻ" trong session hiện tại **đồng thời submit 1 rating thật vào SRS** (`SessionController.submitAnswer`), không phải chỉ là duyệt qua 1 danh sách tĩnh:

- Hết thời gian đọc mà không có thao tác gì → submit **Again** (giữ nguyên hành vi timeout hiện có ở foreground).
- Bấm **Next** trên lock screen → coi như bấm "Đã nhớ" → submit **Good**, sang thẻ kế.
- Bấm **Previous** trên lock screen → **không** rollback rating đã submit (không có cơ chế "hủy SRS" trong domain hiện tại) — chỉ đọc lại thẻ đang hiện tại từ đầu. Nếu bạn cần "quay lại thẻ trước đó thật sự", đây là thay đổi domain contract riêng (approval zone), ngoài phạm vi task này.

## Ràng buộc kiến trúc

- `data/` là nơi duy nhất import `audio_service`/`flutter_tts` — `application/` và `presentation/` không import trực tiếp (đúng pattern đã dùng cho TTS/wakelock).
- Không đổi domain `study/` (`SrsScheduler`, `WordProgress`, `StudyRating`) — chỉ đổi *nơi gọi* `submitAnswer`, không đổi *cách tính* rating.
- `BackgroundPlaybackController` (application) không chứa logic phát âm/audio session — chỉ điều phối giữa `SessionController` và `StudyAudioHandler`.
- Thay đổi `AndroidManifest.xml`/`Info.plist` là cấu hình nền tảng dùng chung — theo tinh thần §9 "quyết định ảnh hưởng nhiều feature", cần bạn duyệt trước khi merge dù không phải domain/schema/navigation/l10n theo nghĩa hẹp.

## Tiêu chí hoàn tất

- `dart analyze` sạch, `flutter test` pass (test `StudyAudioHandler` logic chuyển bài/submit rating bằng fake `TtsService`+fake `ProgressRepository`, không cần platform channel thật).
- Build APK qua CI (đã có sẵn workflow) vẫn pass với dependency mới.
- **Verify thật trên thiết bị** (không làm được trong sandbox — cần bạn tự cài APK từ Release và test khóa màn hình thật): tự đọc tiếp khi khóa máy, lock screen hiện đúng control, Next/Previous/Pause hoạt động.

---

## Definition of Ready — CHƯA tick, đang chờ

- [ ] Bạn xác nhận hành vi SRS khi nền (mục "Hành vi SRS khi chạy nền" ở trên) — đặc biệt là Next = Good, timeout = Again.
- [ ] Bạn xác nhận UX bật "chế độ nghe nền": tự động luôn bật (audio_service luôn là nguồn phát, kể cả khi app đang mở), hay có 1 nút bật/tắt riêng?
- [ ] Chấp nhận: tính năng này khiến app dùng thêm pin (foreground service chạy liên tục khi đang phát) — đã cân nhắc đánh đổi.
- [ ] Chấp nhận việc cần khai báo `UIBackgroundModes: audio` trên iOS — có thể ảnh hưởng review App Store sau này nếu app không dùng đúng mục đích audio thật sự (ở đây dùng đúng mục đích nên rủi ro thấp, nhưng nêu để bạn biết).
