# Task Contract — Thay flutter_tts bằng sherpa_onnx (offline TTS + word timing precompute)

Trạng thái: **đề xuất — chờ duyệt**. Analysis: `docs/analysis/sherpa-onnx-replacement.md`.

Quyết định đã chốt với người dùng (2026-08-03):
1. Word timing: **silence detection trên samples + cache** (không dùng heuristics ký tự, không dùng ASR alignment).
2. ~~Model phân phối: tải từ Firebase Storage khi cần~~ — **đổi quyết định
   (2026-08-04)**: tải từ **GitHub Releases** (HTTP, `dart:io HttpClient`),
   không dùng Firebase Storage cho model TTS nữa. Lý do: gói Firebase hiện
   tại (Spark/free) giới hạn 1GB/ngày egress, không scale; xem
   `docs/analysis/sherpa-onnx-replacement.md` §4. Vẫn không bundle model vào
   assets.
3. Web fallback: **giữ `FlutterTtsService` cho web**, dùng `sherpa_onnx` trên mobile.

---

## Mục tiêu

1. Thay system TTS (`flutter_tts` — giọng phụ thuộc thiết bị, timing chỉ biết được lúc play) bằng
   **sherpa_onnx offline**: model ONNX deterministic, giống nhau trên mọi thiết bị, offline 100%.
2. Chuyển highlight timing từ "đo duration lúc play rồi cache cho lần sau" sang
   **precompute**: `generate(text) → silence-detection → word/syllable timestamps → play` —
   timing đúng ngay lượt đầu, deterministic (cùng model + text + speed → cùng samples).
3. Model TTS tải theo yêu cầu từ **Firebase Storage**; không bundle model vào app binary.
4. **Web giữ nguyên** hành vi hiện tại qua `flutter_tts` (sherpa_onnx không hỗ trợ web).
5. Nền tảng có sẵn model Việt Nam (`vi_VN-vais1000-medium`) — đặt nền để feature tiếng Việt
   không phụ thuộc giọng hệ thống (ngoài phạm vi task này; chỉ chọn model en trước).

## Phạm vi file

**Phase A — engine & playback (task này):**
- **NEW** `lib/features/study/data/tts/sherpa_onnx_tts_service.dart` — impl mobile:
  `initBindings()`, copy model từ disk (đã tải) → init `OfflineTts`, `generate()` → silence detection
  → `TtsWordRange` list → phát event qua `audioplayers` → word-boundary events theo lịch precomputed.
- **NEW** `lib/features/study/data/tts/tts_silence_segmenter.dart` — tách từ bằng silence detection
  trên `Float32List samples` + `sampleRate`; trả `List<TtsWordRange>` (offset UTF-16 tính theo tỷ lệ
  thời gian trên tổng audio — xem ràng buộc).
- **NEW** `lib/features/study/data/tts/tts_model_manager.dart` — quản lý model đã tải trên disk
  (đường dẫn, version, checksum, dọn dẹp), gọi `firebase_storage` để tải khi chưa có.
- **NEW** `lib/features/study/data/tts/tts_models.dart` — catalog model (id, tên, lang, sid,
  firebase path, kích thước, license) — giá trị hằng, không logic.
- **EDIT** `lib/features/study/data/tts_service.dart` — giữ `FlutterTtsService` (web fallback),
  thêm `FactoryTtsService` (chọn impl theo `kIsWeb`/platform) hoặc để provider quyết định.
- **EDIT** `lib/features/study/application/providers.dart` — `ttsServiceProvider` chọn impl theo
  platform; provider cho `TtsModelManager`.
- **EDIT** `pubspec.yaml` — thêm `sherpa_onnx: ^1.13.4`, `audioplayers: ^6.x`; giữ `flutter_tts`
  (chỉ web). Xoá khỏi Android/iOS build nếu chỉ mobile dùng sherpa — flutter_tts vẫn cần cho web.
- **EDIT** `ios/Podfile` / platform config nếu cần (sherpa_onnx_ios podspec `platform :ios, '13.0'`
  — project đã `IPHONEOS_DEPLOYMENT_TARGET 13.0`, kiểm tra không vỡ).
- **EDIT** test data layer: unit test silence segmenter, model manager (fake storage), factory.

**Phase B — highlight precompute (task sau, contract riêng):**
- `TtsHighlightController` bỏ stopwatch/cache-miss estimate; consume word ranges precomputed.
- Bỏ/đổi key `TtsWordTimingCacheTable` (nếu giữ cache timing → đổi key thành model+text+speed).
- Settings screen: voice → model + `sid`, speed range 0.5–3.0.

**Ngoài phạm vi task này:** thay đổi `TtsService` domain contract (giữ nguyên trong Phase A),
feature tiếng Việt, xoá Drift timing cache, UI settings mới.

## Đầu ra mong đợi

- Mobile (Android/iOS) phát âm qua sherpa_onnx + audioplayers, không đụng system TTS.
- `playbackEvents` phát `wordBoundary` theo timestamps đã tính từ samples trước khi play —
  highlight đúng ngay lượt đầu, không cần "đo rồi mới đúng".
- Web vẫn dùng flutter_tts như cũ (không đổi hành vi, test web hiện có vẫn pass).
- Model en nhỏ (Piper `en_US-amy-low` hoặc tương đương) tải từ Firebase Storage, có caching
  theo version + checksum, xử lý lỗi mạng/retry, state loading hiển thị.
- `free()` native engine đúng lifecycle; không leak.
- Unit test: silence segmenter (samples giả lập → range đúng), model manager (fake storage),
  factory chọn impl theo platform.
- `dart analyze`, `flutter test`, `flutter build apk --debug` và iOS build pass.

## Ràng buộc kiến trúc

- **Giữ nguyên dependency direction** `presentation → application → domain ← data`. `TtsService`
  domain contract **không đổi trong task này** — mọi thay đổi contract là approval zone, cần
  contract Phase B riêng.
- `sherpa_onnx`, `audioplayers`, `firebase_storage` chỉ được dùng trong `data/`; presentation/
  application không import trực tiếp.
- Playback audio session iOS (playback + mixWithOthers + defaultToSpeaker, hiện set ở
  `tts_service.dart:12-21`) **phải được replicate** qua `audioplayers`/`audio_session` — không được
  mất hành vi phát đè khi app khác phát nhạc.
- Silence detection: threshold + min gap xác định rõ, config hằng ở data layer; không nhét
  heuristic timing vào application/domain. Nếu detect thất bại (silence quá ít) → fallback chia
  đều theo số token ký tự (không phải "đo lúc play"), vẫn deterministic.
- Offset UTF-16 của `TtsWordRange` phải khớp `PronunciationSegment.start/end` (xem
  `docs/tasks/2026-08-02-tts-pronunciation-segments-and-remove-seed.md`). Vì silence detection
  không cho biết từ nào tương ứng chữ nào, mapping word index → offset chữ dùng tokenizer nhẹ
  (tách theo whitespace/punctuation) — đúng cho tiếng Anh; sai lệch với tiếng Việt sẽ xử ở phase vi.
- Model license phải ghi rõ trong catalog (`docs/`); Piper MIT, code Apache-2.0 — kiểm tra từng model
  trước khi thêm vào catalog.
- Web: không thêm sherpa_onnx vào web build; `FactoryTtsService` phải fallback an toàn.
- Không bundle model vào assets; không tải model tự động khi chưa có yêu cầu từ user.

## Tiêu chí hoàn tất

- [ ] Mobile phát âm sherpa_onnx thật trên Android/iOS (build + chạy thử), web flutter_tts còn nguyên.
- [ ] `playbackEvents` phát word boundary precomputed trước khi play; highlight WordCard đúng từ
      đầu, không cần cache miss estimate.
- [ ] Silence segmenter có unit test với samples giả lập (word rõ ràng, liền nhau, silence ít).
- [ ] Model manager có test với fake storage: tải mới, có sẵn, lỗi mạng, checksum sai.
- [ ] Không import trái tầng: grep xác nhận `sherpa_onnx`/`audioplayers` chỉ trong `data/`.
- [ ] `dart analyze` sạch, `flutter test` pass toàn bộ (kể cả test web/hiện có), build Android debug
      và iOS pass.
- [ ] ADR ghi quyết định thay engine TTS (approval zone: domain contract + external dependency).
- [ ] Task contract Phase B (highlight precompute) được viết trước khi bắt đầu Phase B.

## Definition of Ready (§14.4) — phải tick hết trước khi bắt đầu

- [x] Requirement đã rõ: 3 quyết định chốt ở trên.
- [x] Miền ảnh hưởng đã xác định: data/tts mới, provider, pubspec, test; presentation/application
      giữ nguyên trong Phase A.
- [x] Contract đầu vào/đầu ra có thể kiểm chứng: `TtsService` không đổi; samples → ranges có unit test.
- [x] Phụ thuộc bên ngoài đã biết: sherpa_onnx 1.13.4, audioplayers 6.x, model Firebase cần upload
      trước, iOS 13.0+.
- [x] Tiêu chí hoàn tất có thể test được.
- [ ] **Chờ duyệt** — domain contract không đổi nhưng thêm external dependency lớn (sherpa_onnx +
      model) và chạm approval zone (persistence không đổi, nhưng thêm hạ tầng model download).

## Definition of Done (§14.5) — phải tick hết trước khi merge

- [ ] Code đúng kiến trúc
- [ ] Test liên quan đã có và qua
- [ ] Không phá dependency direction
- [ ] Không thêm folder/file rỗng
- [ ] Không tạo import vòng hoặc import trái tầng
- [ ] Tài liệu/ADR cần thiết đã cập nhật
