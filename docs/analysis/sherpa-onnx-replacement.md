# Analysis — thay `flutter_tts` bằng `sherpa_onnx` (Phase A)

Tham chiếu: `docs/tasks/2026-08-03-tts-sherpa-onnx-replacement.md`.

Ghi lại 3 quyết định kỹ thuật phát sinh trong lúc implement Phase A (không đổi
domain contract, chỉ ảnh hưởng `data/`), cùng lý do và deviation so với hành
vi `flutter_tts` cũ.

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

Trade-off: file phân phối (`tar.bz2`) vẫn chứa cả bản full-precision lẫn
bản `int8` (nguồn phát hành k2-fsa không tách riêng) — tải về nặng hơn cần
thiết (~152 MB nén so với ~40 MB nếu tách riêng), nhưng đổi lại giữ đúng
format tarball gốc, không cần code build/re-pack archive riêng (rủi ro sai
lệch checksum/nguồn gốc). Có thể tối ưu ở phase sau nếu dung lượng tải trở
thành vấn đề thực tế.

## Phân phối model — trạng thái Firebase Storage

- Nguồn gốc: `https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-vctk.tar.bz2`
  (license: xem `tts_models.dart` — VCTK CC BY 4.0 cho voice, MIT cho code).
- Đích: Firebase Storage path `tts/vits-vctk.tar.bz2` (project `voca-370e1`,
  bucket `voca-370e1.firebasestorage.app`), khớp `TtsModelSpec.firebasePath`
  trong `tts_models.dart`.
- SHA-256 của file gốc (không sửa đổi) đã điền vào
  `TtsModelSpec.sha256`:
  `4f0a02db66914b3760b144cebc004e65dd4d1aeef43379f2b058849e74002490`.
- **Việc upload lên Firebase Storage chưa thực hiện được từ môi trường
  sandbox này** — không có credential ghi (service account / Firebase CLI
  login) trong container. Cần người có quyền Storage Admin trên project
  `voca-370e1` upload thủ công file `vits-vctk.tar.bz2` (đã tải sẵn, đã
  verify checksum khớp) vào path `tts/vits-vctk.tar.bz2`, giữ nguyên byte
  gốc — nếu file khác byte, checksum trong `tts_models.dart` sẽ sai và
  `TtsModelManager.ensureModel` sẽ ném `StateError` khi verify.
