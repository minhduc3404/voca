# Analysis — thay `flutter_tts` bằng `sherpa_onnx` (Phase A)

Tham chiếu: `docs/tasks/2026-08-03-tts-sherpa-onnx-replacement.md`.

Ghi lại các quyết định kỹ thuật phát sinh trong lúc implement Phase A (không
đổi domain contract, chỉ ảnh hưởng `data/`), cùng lý do và deviation so với
hành vi `flutter_tts` cũ.

## 1. Audio session iOS: `audioplayers` (AudioContext) thay vì `audio_session`

`flutter_tts` cũ tự quản lý audio session qua `setIosAudioCategory` (xem
`lib/features/study/data/tts_service.dart:12-21`). Khi chuyển sang phát WAV
bằng `audioplayers`, có hai lựa chọn: dùng package `audio_session` riêng để
cấu hình `AVAudioSession` thủ công, hoặc dùng API `AudioContext` tích hợp sẵn
trong `audioplayers`.

Chọn **`audioplayers` `AudioContext`/`AudioContextIOS`** (xem
`SherpaOnnxTtsService` constructor, `sherpa_onnx_tts_service.dart:32-39`):
category `playback` + option `mixWithOthers`. Lý do: `audioplayers` tự áp
dụng context này lên session mỗi lần play, không cần đồng bộ thủ công với
`audio_session` (nguy cơ hai package cùng set category race nhau). Dependency
`audio_session: ^0.2.4` đã bị xoá khỏi `pubspec.yaml` vì không còn dùng.

## 2. Bỏ `defaultToSpeaker` / `voicePrompt` — deviation so với `flutter_tts`

Cấu hình cũ dùng thêm `IosTextToSpeechAudioCategoryOptions.defaultToSpeaker`
và `IosTextToSpeechAudioMode.voicePrompt`. API `AudioContextIOS` của
`audioplayers` không có tương đương cho hai option này (`AVAudioSessionOptions`
chỉ expose `mixWithOthers`, `duckOthers`, `allowBluetooth`, ... không có
`defaultToSpeaker`; không có khái niệm audio mode như `voicePrompt`).

**Deviation chấp nhận được**: trên iOS, category `playback` mặc định đã phát
qua loa ngoài (không route vào receiver) khi không có route khác (tai nghe/
Bluetooth) được chọn — hành vi thực tế không đổi cho use case học từ vựng
(phát trong loa ngoài, không phải cuộc gọi). `voicePrompt` mode chủ yếu ảnh
hưởng ducking khi có Bluetooth A2DP; không kiểm chứng được khác biệt trong
phạm vi Phase A. Nếu phát sinh regression thực tế (báo cáo từ user dùng tai
nghe Bluetooth), cần contract riêng để đánh giá lại — không tự ý thêm
`audio_session` để bù chỉ vì lý thuyết.

## 3. Model: `vits-vctk-int8` thay vì Piper

Task contract ban đầu đề xuất Piper (`en_US-amy-low` hoặc tương đương) vì
nhẹ. Piper trên sherpa-onnx **yêu cầu kèm thư mục `espeak-ng-data/`** (bảng
phoneme cho grapheme-to-phoneme) — không thể ship dưới dạng model file đơn,
bắt buộc phân phối cả một thư mục con nhiều file nhỏ. Điều này làm phức tạp
`TtsModelManager` (phải verify/giải nén nhiều path hơn) và tăng rủi ro thiếu
file khi tải lại.

Chọn **`vits-vctk` bản `int8`** (`vits-vctk.int8.onnx`, 39.8 MB so với 121.3
MB bản gốc): không cần `espeak-ng-data` (VITS tự có tokenizer + lexicon nội
bộ qua `tokens.txt` + `lexicon.txt`), 109 giọng (mở đường chọn giọng ở Phase
B), model file đơn — khớp thiết kế `TtsModelManager` hiện tại (một
`archivePath` gốc, ba file con: model/tokens/lexicon).

## 4. Phân phối model: GitHub Releases thay vì Firebase Storage — đổi quyết định

Quyết định ban đầu trong task contract (§2, chốt 2026-08-03) là tải model từ
Firebase Storage. Sau khi implement, phát hiện hai vấn đề chặn dùng thật:

1. **Gói Firebase hiện tại là Spark (free)**: giới hạn 1 GB/ngày egress cho
   Storage — với model ~145 MB (tarball gốc k2-fsa, gồm cả bản fp32 không
   dùng), chỉ ~6-7 lượt tải/ngày trước khi hết quota miễn phí; không scale
   được khi có nhiều user cài app. Nâng lên Blaze (trả theo dùng) là lựa chọn
   khác nhưng người dùng chủ động không muốn phụ thuộc chi phí phát sinh.
2. **Archive gốc lãng phí ~2/3 dung lượng**: tarball k2-fsa đóng gói cả
   `vits-vctk.onnx` (fp32, 121 MB, không dùng) lẫn `vits-vctk.int8.onnx`
   (39.8 MB, model thật sự dùng) — vì `modelRelPath` trong `tts_models.dart`
   chỉ trỏ tới bản int8.

**Quyết định mới** (chốt với user, 2026-08-04): đóng gói lại archive chỉ gồm
`vits-vctk.int8.onnx` + `tokens.txt` + `lexicon.txt` (giữ nguyên prefix thư
mục `vits-vctk/` — không cần sửa `TtsModelManager._extract`), nén còn
**~35 MB** (so với ~145 MB gốc). Host file này trên **GitHub Releases** của
chính repo (`minhduc3404/voca`) — asset của Release được phục vụ qua CDN của
GitHub (Fastly/`objects.githubusercontent.com`), miễn phí và không giới hạn
bandwidth thực tế cho repo, không thêm vendor/hạ tầng cloud mới.

Thay đổi code kèm theo:
- `TtsModelSpec.firebasePath` → `TtsModelSpec.downloadUrl` (URL HTTP đầy đủ
  tới GitHub Release asset) — field chỉ là data, domain contract không đổi.
- `TtsModelManager.downloadArchive`: bỏ `firebase_storage`, dùng
  `dart:io HttpClient` GET trực tiếp tới `downloadUrl`, stream vào file +
  báo progress qua `Content-Length`. `firebase_storage` package **vẫn giữ**
  trong `pubspec.yaml` vì feature khác (`FirebaseCatalogRepository` — catalog
  từ vựng) vẫn dùng.
- `pubspec.yaml`: không thêm dependency mới (dùng `dart:io` sẵn có, không cần
  `http`/`dio`).

### Trạng thái phân phối

- Nguồn gốc model: `https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-vctk.tar.bz2`
  (license: VCTK CC BY 4.0 cho voice, MIT cho code — xem `tts_models.dart`).
- Archive đã đóng gói lại (chỉ int8 + tokens + lexicon), SHA-256 đã điền vào
  `TtsModelSpec.sha256`:
  `b8776e2a23a4d78764b452410b8747ee66610ab2a0fba8a2308c84a5c5176cfc`.
- `TtsModelSpec.downloadUrl` giả định Release tag `tts-models-v1`, asset
  `vits-vctk-int8.tar.bz2`:
  `https://github.com/minhduc3404/voca/releases/download/tts-models-v1/vits-vctk-int8.tar.bz2`.
- **Việc tạo GitHub Release + upload asset chưa thực hiện được từ agent** —
  không có tool tạo Release/upload asset trong bộ công cụ GitHub MCP hiện có
  (chỉ có `list_releases`/`get_release_by_tag`, không có `create_release`).
  Cần người có quyền trên repo tạo Release tag `tts-models-v1`, upload file
  `vits-vctk-int8.tar.bz2` (đã chuẩn bị sẵn, đã verify checksum khớp) làm
  asset — giữ đúng tag + tên file như trên, hoặc báo lại tag/tên khác để cập
  nhật `downloadUrl` cho khớp.
