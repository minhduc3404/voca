# Task Contract — TTS phát nền + điều khiển trên lock screen

Trạng thái: **đã duyệt qua trao đổi trực tiếp với chủ dự án (2026-08-04) — đã triển khai, CHƯA verify
trên thiết bị thật** (môi trường hiện tại không có `flutter`/`dart` binary lẫn thiết bị có audio).

## Mục tiêu

Khi người dùng nghe TTS (từ vựng ở `study` hoặc hội thoại ở `conversation`) và tắt màn hình / chuyển
app xuống nền, audio **tiếp tục phát** thay vì bị hệ điều hành cắt ngang, và **hiện điều khiển
play/pause/stop trên lock screen** (Android media notification / iOS Now Playing).

Quyết định phạm vi (chốt qua hỏi đáp trực tiếp):
- **Phạm vi:** áp dụng cho cả `study` (đọc từ vựng) lẫn `conversation` (hội thoại) — dùng chung 1 hạ
  tầng vì cả hai đã cùng dùng `TtsService` qua `study_providers.ttsServiceProvider`.
- **Cách làm:** thêm dependency `audio_service` (chuẩn Flutter cho background audio + lock-screen
  media session), thay vì tự viết native code tay.

## Hiện trạng trước khi làm (phân tích)

- `SherpaOnnxTtsService` (`study/data/tts/`) phát qua `audioplayers`, không có background mode nào
  được khai báo: `AndroidManifest.xml` không có `FOREGROUND_SERVICE`, `Info.plist` không có
  `UIBackgroundModes`. `audioplayers` cũng không tích hợp `MPNowPlayingInfoCenter`/`MediaSession`.
  → OS treo tiến trình khi tắt màn hình, TTS bị cắt ngang, không có gì trên lock screen.

## Kiến trúc giải pháp

`TtsAudioHandler` (`study/data/tts/tts_audio_handler.dart`) là lớp **duy nhất** biết về
`audio_service` trong toàn app — `extends BaseAudioHandler implements TtsService`:
- Bọc (decorator) `TtsService` thật (`SherpaOnnxTtsService`) qua [attachInner] — mọi lệnh
  `speak/getVoices/setVoice/...` forward xuống inner nguyên vẹn.
- `speak()` đẩy `MediaItem`/`PlaybackState` để OS hiện notification/lock-screen.
- Lệnh từ lock screen (`play/pause/stop`) forward xuống `inner.resume()/pause()/stop()` (3 method MỚI
  thêm vào contract `TtsService`, default no-op cho impl không hỗ trợ — vd `FlutterTtsService` web).
- Lắng nghe `inner.playbackEvents` (completed/cancelled/error) để cập nhật `playbackState` về
  idle/not-playing.

Vòng đời 2 giai đoạn (bắt buộc vì `AudioService.init()` phải chạy TRƯỚC `runApp()`, còn impl TTS thật
cần DB/model manager lấy qua Riverpod nên chỉ tạo được sau khi có `ProviderContainer`):
1. `bootstrap()` gọi `AudioService.init(builder: TtsAudioHandler.new, ...)` trước `runApp()` (không
   chạy trên web) → có handler rỗng, override vào `audioHandlerProvider`.
2. `ttsServiceProvider` (application) tạo impl TTS thật qua `FactoryTtsService` như cũ, rồi
   `handler.attachInner(service)` nếu có handler (mobile) — trả `handler` thay vì `service` trực tiếp.
   Trên web, `audioHandlerProvider` là `null` → `ttsServiceProvider` trả `service` thẳng như trước
   (không đổi hành vi web).

**Presentation/application (study + conversation) không đổi gì** — vẫn chỉ biết `TtsService`, không
biết `audio_service` tồn tại. Đúng dependency direction (data biết audio_service, application/domain
không biết).

## Phạm vi file

**NEW:**
- `lib/features/study/data/tts/tts_audio_handler.dart`
- `test/features/study/data/tts_audio_handler_test.dart`
- File contract này.

**EDIT:**
- `lib/features/study/domain/tts_service.dart` — thêm `stop()`/`pause()`/`resume()` (default no-op).
- `lib/features/study/data/tts/sherpa_onnx_tts_service.dart` — `stop()` thành `@override`, thêm impl
  `pause()`/`resume()` qua `_player.pause()/resume()`.
- `lib/features/study/application/providers.dart` — thêm `audioHandlerProvider`, wire vào
  `ttsServiceProvider`.
- `lib/app/bootstrap/bootstrap.dart` — gọi `AudioService.init()` trước `runApp()`.
- `pubspec.yaml` — thêm `audio_service: ^0.18.19`.
- `android/app/src/main/AndroidManifest.xml` — permissions (`WAKE_LOCK`, `FOREGROUND_SERVICE`,
  `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, `POST_NOTIFICATIONS`) + `<service>` `AudioService` +
  `<receiver>` `MediaButtonReceiver` (theo README chính thức của package, verify qua WebFetch
  2026-08-04).
- `android/app/src/main/kotlin/com/voca/remember/MainActivity.kt` — extend
  `com.ryanheise.audioservice.AudioServiceActivity` thay vì `FlutterActivity` trơn (để chia sẻ đúng
  Flutter engine với foreground service).
- `ios/Runner/Info.plist` — thêm `UIBackgroundModes: [audio]`.

**KHÔNG đụng:** `presentation/`, `application/` của `study`/`conversation` (ngoài
`study/application/providers.dart` — chỉ thêm wiring, không đổi logic nghiệp vụ); `FlutterTtsService`
(web) không cần pause/resume thật (default no-op đã đủ, ngoài phạm vi background/lock-screen).

## Đầu ra mong đợi

- TTS (study lẫn conversation) tiếp tục phát khi tắt màn hình/chuyển app xuống nền (Android + iOS).
- Lock screen / notification hiện tiêu đề (text đang đọc, cắt ngắn 80 ký tự) + nút play/pause/stop
  hoạt động đúng.
- Web không đổi hành vi (không có audio_service, TTS vẫn phát bình thường trong foreground).
- Unit test `TtsAudioHandler` (proxy speak/play/pause/stop, cập nhật playbackState theo
  playbackEvents, truncate title, lỗi khi chưa attachInner) pass.

## Ràng buộc kiến trúc

- **Dependency direction:** `audio_service` chỉ import trong `study/data/tts/` (2 file:
  `tts_audio_handler.dart`, và gián tiếp qua `bootstrap.dart` ở tầng `app/` — không phải feature layer
  nên không vi phạm; `app/` là composition root, được phép biết chi tiết impl để wiring). `domain/`
  (`tts_service.dart`) không import `audio_service`/Flutter — chỉ thêm method thuần.
- **Riverpod 3:** `audioHandlerProvider`/`ttsServiceProvider` vẫn `Provider` (sync) — không đổi sang
  async, tránh vỡ mọi call site `ref.watch(ttsServiceProvider)` hiện có (đã khảo sát: khá nhiều nơi
  dùng sync).
- **Domain contract (approval zone §9):** thêm `stop/pause/resume` vào `TtsService` là thay đổi domain
  contract — đã duyệt qua trao đổi trực tiếp (không phải AI tự quyết).
- **Quyết định ảnh hưởng nhiều feature (approval zone §9):** hạ tầng dùng chung `study` + `conversation`
  + thêm dependency mới + sửa cấu hình native 2 platform — đã duyệt qua trao đổi trực tiếp.
- **Two-feature rule (§6, core/):** `TtsService` đã dùng chung ≥ 2 feature từ trước (task MVP
  conversation) — về nguyên tắc đủ điều kiện chuyển vào `core/`, nhưng **không** relocate trong task
  này (ngoài phạm vi yêu cầu, tránh refactor lan rộng không cần thiết). Ghi chú lại cho task sau nếu
  cần.

## Giới hạn đã biết (chấp nhận ở MVP)

- **Highlight lệch sau pause/resume:** `Timer` wordBoundary của `SherpaOnnxTtsService` lên lịch theo
  mốc tuyệt đối lúc `speak()`, không dừng/dời lại khi pause — sau 1 lần pause/resume qua lock screen,
  highlight của lượt đang phát có thể lệch khỏi audio (tự đúng lại ở lượt `speak()` kế tiếp). Chấp
  nhận được vì pause/resume chủ yếu xảy ra khi màn hình tắt (không nhìn thấy highlight).
- **`POST_NOTIFICATIONS` runtime request:** đã khai báo permission trong manifest, nhưng Android 13+
  yêu cầu xin quyền lúc runtime (không tự động có từ khai báo manifest) — nếu notification/lock-screen
  không hiện trên Android 13+, cần thêm bước request runtime permission (vd qua `permission_handler`),
  chưa có trong lần triển khai này.
- **iOS audio session:** `SherpaOnnxTtsService` tự set `AVAudioSessionCategory.playback` qua
  `audioplayers`; `audio_service`/`audio_session` cũng có thể set session — khả năng chồng lấn cấu hình
  chưa kiểm chứng được trên thiết bị thật.

## Tiêu chí hoàn tất

- [ ] `flutter pub get` chạy được (dependency `audio_service` resolve đúng). *(Chưa chạy được — môi
      trường không có flutter/dart binary.)*
- [ ] `flutter analyze` sạch. *(Chưa chạy được — như trên.)*
- [x] Unit test `TtsAudioHandler` viết đầy đủ theo các case chính (chưa chạy được vì thiếu flutter
      engine, đã review logic thủ công).
- [ ] Build Android + iOS thành công với cấu hình manifest/Info.plist mới. *(Cần verify trên máy có
      Flutter + thiết bị/emulator thật.)*
- [ ] Test thủ công trên device: phát TTS → tắt màn hình → audio tiếp tục phát → lock screen hiện
      title + nút play/pause/stop hoạt động đúng (cả Android lẫn iOS). *(Chưa verify được trong môi
      trường này.)*
- [x] Không đổi hành vi/API bề mặt cho `presentation`/`application` của `study` và `conversation`.

---

## Definition of Ready (§14.4)
- [x] Requirement đã rõ (chốt qua 2 câu hỏi trực tiếp: phạm vi + cách triển khai)
- [x] Miền ảnh hưởng đã xác định (`study/data/tts/`, `application/providers.dart`, `app/bootstrap/`,
      cấu hình native 2 platform)
- [x] Contract đầu vào/đầu ra có thể kiểm chứng (`TtsAudioHandler` proxy + playbackState)
- [x] Phụ thuộc bên ngoài đã biết (`audio_service` — verify version + cấu hình manifest qua WebFetch
      tài liệu chính thức trước khi viết code, không đoán từ trí nhớ)
- [ ] Tiêu chí hoàn tất có thể test được **trên thiết bị thật** — môi trường hiện tại không đủ điều
      kiện, cần chủ dự án tự verify

## Definition of Done (§14.5)
- [x] Code đúng kiến trúc (data biết audio_service, domain/application/presentation không biết)
- [ ] Test liên quan đã có và qua *(đã có, chưa chạy được — thiếu flutter engine)*
- [x] Không phá dependency direction
- [x] Không thêm folder/file rỗng
- [x] Không tạo import vòng hoặc import trái tầng
- [x] Tài liệu cần thiết đã cập nhật (contract này)
