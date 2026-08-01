# Task Contract — Highlight từ theo timing TTS trên `WordCard`

Điền theo `docs/templates/task-contract.md` (PLAN.md §14.3).

---

## Mục tiêu

Khi TTS đọc `term` trên `WordCard`, từ đang được đọc phải tự động highlight (đổi màu accent + animation phóng nhẹ) theo đúng tiến độ đọc thật của engine — dùng luôn điểm ngắt tự nhiên (khoảng trắng) có sẵn trong `term`, không thêm field dữ liệu/schema nào.

## Phạm vi file

- **EDIT**: `lib/features/study/data/tts_service.dart` (+`TtsWordRange`, +`wordRangeStream` trên `TtsService`/`FlutterTtsService`, dùng `flutter_tts.setProgressHandler`), `lib/features/study/presentation/widgets/word_card.dart` (+`speakingWordIndex` int? thuần, tách `term` theo khoảng trắng, render `Wrap` + `_AnimatedTermWord`), `lib/features/study/presentation/memo_screen.dart` (subscribe `wordRangeStream`, tính word index, truyền xuống `WordCard`)
- **EDIT test**: 4 fake `_FakeTtsService` (`memo_screen_test.dart`, `memo_screen_pause_speed_test.dart`, `tts_settings_screen_test.dart`, `tts_settings_controller_test.dart`) thêm override `wordRangeStream`; `word_card_test.dart` thêm test highlight.
- Không đụng `domain/`, schema Drift, hay approval zone nào (§9) — `TtsWordRange` là runtime value type trong `data/`, không phải dữ liệu bền vững.

## Đầu ra mong đợi

`WordCard` tự tách `term` thành các từ, tô sáng đúng từ đang đọc theo native word-boundary event của `flutter_tts`, có animation (scale + đổi màu, 160ms). Không cần nghe audio thật để verify — test verify wiring qua fake `TtsService` (bắn `TtsWordRange`/`null` vào stream, kiểm tra `speakingWordIndex` truyền đúng xuống `WordCard`).

## Ràng buộc kiến trúc

- `word_card.dart` **vẫn** không import `flutter_riverpod`/`data/` — chỉ nhận `int? speakingWordIndex` thuần từ parent, giữ đúng "dumb widget" pattern đã lập ở `docs/tasks/2026-07-30-tts-pronunciation.md`.
- `memo_screen.dart` không khai báo type `TtsWordRange` tường minh (tránh import `data/` vào presentation) — dùng `late final` + closure suy type ẩn, giống pattern `_wakelockService` đã có.
- `TtsWordRange` là type mới trong `data/`, không phải domain contract, không phải persistence schema — không cần approval zone.

## Tiêu chí hoàn tất

- `dart analyze` sạch, `flutter test` pass (test cũ không đổi hành vi + test mới cho highlight).
- Không phá import boundary hiện có.
- `WordCard` vẫn đúng "dumb widget" pattern.

---

## Definition of Ready — đã tick

- [x] Requirement rõ: highlight từ đang đọc theo timing TTS thật, tự động, không thêm field dữ liệu.
- [x] Miền ảnh hưởng: chỉ `features/study/` (data + presentation, không đụng domain).
- [x] Không có approval zone nào bị chạm.

## Hoàn tất — 2026-08-01

Thêm `TtsWordRange` + `wordRangeStream` (`data/tts_service.dart`, dùng `setProgressHandler`/`setCompletionHandler`/`setCancelHandler`/`setErrorHandler`). `WordCard` tách `term` theo `RegExp(r'\S+')`, render qua `Wrap` + `_AnimatedTermWord` (AnimatedScale + AnimatedDefaultTextStyle). `memo_screen.dart` subscribe stream, đối chiếu offset để suy ra word index, reset khi đổi thẻ. 4 fake `TtsService` trong test cập nhật override mới; thêm 1 test highlight cho term nhiều từ ("look forward to").
- [x] Không đụng `domain/`/schema.
- [x] `word_card.dart` không import riverpod/data.
- [ ] **Chưa chạy được `flutter analyze`/`flutter test`** — môi trường sandbox không có Flutter SDK cài sẵn; cần verify lại trên máy có SDK trước khi merge.

## Bổ sung — 2026-08-01: highlight theo âm tiết cho từ đơn

**Mục tiêu bổ sung**: hiện tại app chỉ học single word (cụm từ nhiều từ là việc tương lai). Với 1 từ, highlight cả từ cùng lúc là chưa đủ chi tiết — cần nhấn lần lượt theo từng âm tiết bên trong từ, dựa trên trọng âm có sẵn trong `card.phonetic` (IPA, vd `/ɪˈfem.ər.əl/` — dấu `.` ngăn âm tiết, `ˈ`/`ˌ` là trọng âm chính/phụ). Không thêm field domain nào — `phonetic` đã tồn tại sẵn trong `StudyCard`.

**Giới hạn đã biết (được chấp nhận có chủ đích)**: `flutter_tts` không có event ở mức âm tiết/phoneme trên bất kỳ platform nào — animation âm tiết là **ước lượng thời lượng hiển thị** (suy từ trọng âm IPA), chạy song song với event active thật ở mức từ, không đồng bộ tuyệt đối với audio thật. Việc tách chữ cái theo âm tiết cũng là xấp xỉ theo số ký tự chia đều (không có ánh xạ IPA↔chính tả chính xác).

- **EDIT**: `lib/features/study/presentation/widgets/word_card.dart` — thêm `_parseSyllableWeights`/`_splitIntoChunks` (thuần string, không phụ thuộc gì mới), `_AnimatedTermWord` chuyển sang `StatefulWidget` chạy `Timer` cycle qua từng âm tiết khi active, chỉ áp dụng khi `term` là 1 từ đơn (`_termWords.length == 1`) — cụm từ nhiều từ giữ nguyên hành vi highlight cả từ như cũ.
- **EDIT test**: `word_card_test.dart` — thêm test tách/cycle âm tiết cho "apple" (`/ˈæp.əl/` → "app"+"le") và test đảm bảo lúc không active vẫn hiện liền cả từ (không phá test cũ `find.text('apple')`).
- Không đụng `data/`, `application/`, `domain/` — thay đổi gói gọn hoàn toàn trong 1 widget presentation, dùng field `phonetic` đã có sẵn.

**Tiêu chí hoàn tất bổ sung**: từ active tách đúng số âm tiết theo dấu `.` trong `phonetic`; âm tiết mang `ˈ` giữ lâu hơn âm tiết thường; lúc không active hiện liền cả từ (không tách); cụm nhiều từ không bị ảnh hưởng.
- [x] Không đụng `domain/`/`data/`/`application/` — chỉ sửa 1 widget presentation.
- [x] `WordCard` vẫn không import riverpod/data.
- [ ] **Chưa chạy được `flutter analyze`/`flutter test`** — cần verify trên máy có Flutter SDK trước khi merge.
