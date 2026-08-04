# Task Contract — Reading: dán đoạn văn, tap từ, dịch & lưu vào bộ học

Điền theo `docs/templates/task-contract.md` (PLAN.md §14.3).

Tham khảo wireframe: `Ideas/ChatGPT Image Aug 4, 2026, 04_42_27 PM.png` (6 màn: entry point,
input, paragraph neutral, word tapped, bottom sheet chưa lưu, bottom sheet đã lưu + feedback).

> **Quyết định đã chốt trong quá trình phân tích (không re-litigate):**
> - Nguồn dịch: **`google_mlkit_translation`** (on-device, miễn phí, không giới hạn lượt — khác
>   Google Cloud Translation API trả phí). Chỉ trả về text dịch, KHÔNG có IPA/audio/metadata.
> - IPA cho từ tự thêm: **để rỗng** (chấp nhận khuyết điểm này). Không chặn tính năng nghe —
>   `WordCard`/TTS phát trên `card.term`, không phụ thuộc `phonetic`.
> - **Home giữ nguyên như hiện tại** (KHÔNG đổi sang layout wireframe 01 — không thêm
>   streak/goal-ring/bottom-nav mới). Chỉ thêm 1 card "My Work" vào khu vực chủ đề đang có.
> - "My Work" là bộ sưu tập từ tự thêm (catalogId IS NULL — đúng thiết kế "từ nhập tay" đã có
>   sẵn trong schema từ trước), KHÔNG ép vào domain `Topic`/`downloadTopic` (không có gì để
>   "tải về"/"version" — sai ngữ nghĩa). Tap "My Work" → màn liệt kê riêng + nút mở Reading.
> - Không cache kết quả dịch, không lemmatization, không phân biệt entry point khác ngoài
>   "My Work" (KHÔNG thêm icon Reading riêng trên AppBar Home).

## Mục tiêu

Thêm luồng: dán đoạn văn tiếng Anh → mỗi từ tappable → tap 1 từ hiện bottom sheet dịch nghĩa
(ML Kit on-device EN→VI) → lưu vào `VocabularyTable` (due ngay, học được trong `MemoScreen`
như từ thường). Truy cập qua card "My Work" mới trên Home (không đổi Home hiện có) → màn
"My Work" (liệt kê từ tự thêm) → nút mở Reading.

Đo được:
- Dán đoạn văn, tap 1 từ, thấy nghĩa dịch, bấm lưu → từ xuất hiện trong `getManualWords()` và
  trong phiên học tiếp theo (`SessionController.dueCards`).
- Tap lại từ đã lưu (hoặc từ trùng đã có sẵn trong bộ học từ nguồn khác) → bottom sheet hiện
  đúng trạng thái "Đã lưu" + nút "Remove", không tạo dòng trùng.
- Home không có regression: layout/behavior hiện tại giữ nguyên, chỉ thêm 1 card.

## Phạm vi file

### Domain (thuần, test được — approval zone: domain contract, CLAUDE.md §9)

- **NEW** `lib/features/reading/domain/paragraph_tokenizer.dart` — `TextRun{text, isWord, start, end}`,
  `List<TextRun> tokenize(String paragraph)`. Thuần Dart, không phụ thuộc Flutter/package.
- **NEW** `lib/features/reading/domain/word_lookup_repository.dart` — `WordLookupResult{term, translation}`;
  `abstract class WordLookupRepository { Future<WordLookupResult?> lookup(String term); }`.
- **NEW** `lib/features/vocabulary/domain/manual_word_entry.dart` — `ManualWordEntry{id, term, definition}`
  (hiển thị màn "My Work").
- **EDIT** `lib/features/vocabulary/domain/topic_library_repository.dart` — thêm:
  - `Future<int?> findVocabIdByTerm(String term)` — tìm theo term không phân biệt hoa/thường,
    dùng để biết 1 từ đã có trong bộ học chưa (bất kể nguồn nào, không chỉ từ tự thêm).
  - `Future<int> addManualWord({required term, required definition, required phonetic, partOfSpeech, required exampleSentence})`
    — ghi `catalogId: null, topicId: null` (đúng thiết kế sẵn có).
  - `Future<void> removeManualWord(int vocabId)`.
  - `Future<List<ManualWordEntry>> getManualWords()` — lọc `catalogId IS NULL`.

### Data

- **NEW** `lib/features/reading/data/ml_kit_word_lookup_repository.dart` — impl
  `google_mlkit_translation`; tự kiểm tra/tải model EN→VI on-device lần đầu, dedup lời gọi
  đồng thời (pattern `_inFlight` giống `TtsModelManager` — tránh tải model 2 lần song song).
- **EDIT** `lib/features/vocabulary/data/drift_topic_library_repository.dart` — implement 4
  method mới ở trên.
- **EDIT** `pubspec.yaml` — thêm `google_mlkit_translation`.

### Application

- **NEW** `lib/features/reading/application/providers.dart` — `wordLookupRepositoryProvider`.
- **NEW** `lib/features/reading/application/reading_controller.dart` — state: `rawText`,
  `runs: List<TextRun>`, từ đang chọn, `lookupResult` (loading/data/error), `alreadySaved: bool`,
  `saving: bool`. Method: `setText`, `analyze()` (tokenize), `tapWord(TextRun)` (lookup +
  `findVocabIdByTerm` song song), `save()`, `remove()`, `clear()`. Notifier chỉ điều phối, gọi
  use case qua repository — không chứa logic dịch/tokenize (đã ở domain/data).
- **NEW** `lib/features/vocabulary/application/my_work_controller.dart` — `AsyncNotifier<List<ManualWordEntry>>`
  đọc `getManualWords()`; `reload()`.

### Presentation

- **NEW** `lib/features/reading/presentation/reading_screen.dart` — 1 screen, state-driven theo
  wireframe: input → paragraph render (tap để chọn từ, highlight từ đã lưu bằng underline nhẹ
  màu accent) → bottom sheet dịch (2 biến thể: chưa lưu / đã lưu). **Dòng IPA trong bottom sheet
  phải tự ẩn khi rỗng** (không hiện `//` trống) — khác với mockup wireframe (mockup có IPA,
  thực tế v1 không có nguồn IPA cho từ ad-hoc).
- **NEW** `lib/features/vocabulary/presentation/my_work_screen.dart` — liệt kê `ManualWordEntry`
  (tái dùng visual pattern list-row của `TopicListScreen`, không cần wireframe riêng), nút/FAB
  mở `ReadingScreen`.
- **EDIT** `lib/features/study/presentation/home_screen.dart` — trong `_HomeBody`, thêm 1 item
  vào đầu `GridView` hiện có (itemCount +1, index 0 = card "My Work"): widget riêng
  `_MyWorkCard` (style giống `_TopicCard`: icon, tên "My Work", số từ từ
  `ref.watch(myWorkControllerProvider).value?.length ?? 0`) — **không** tái dùng `Topic`/
  `_TopicCard` trực tiếp (sai ngữ nghĩa "tải về"/"version"). Tap → push `MyWorkScreen`. Không
  đổi phần còn lại của Home (không thêm AppBar icon Reading riêng, không đổi bottom nav/streak).

### Test

- **NEW** `test/features/reading/domain/paragraph_tokenizer_test.dart` — dấu câu, số, khoảng
  trắng kép, apostrophe ("don't"), unicode.
- **EDIT** `test/features/vocabulary/data/drift_topic_library_repository_test.dart` — thêm case
  `addManualWord`/`removeManualWord`/`getManualWords`/`findVocabIdByTerm`.
- **NEW** `test/features/reading/application/reading_controller_test.dart` — fake
  `WordLookupRepository` + fake `TopicLibraryRepository`: tokenize, tap → lookup, save → gọi
  đúng repository, tap từ đã tồn tại → `alreadySaved = true` không gọi `addManualWord`.
- **NEW** `test/features/vocabulary/application/my_work_controller_test.dart` — fake repository.
- **NEW** `test/features/reading/presentation/reading_screen_test.dart` — input → paragraph
  render → tap từ → bottom sheet (fake controller/provider override, theo pattern widget test
  hiện có).
- **EDIT** `test/features/study/presentation/home_screen_test.dart` — card "My Work" render +
  điều hướng, không phá test grid chủ đề hiện có.
- **NEW** `test/features/vocabulary/presentation/my_work_screen_test.dart`.

`ml_kit_word_lookup_repository.dart` không unit test trực tiếp (gọi plugin channel thật, giống
`FlutterTtsService`/`sherpa_onnx_tts_runtime_native.dart` hiện tại cũng không unit test) — chỉ
test qua fake ở tầng application.

## Đầu ra mong đợi

- Build chạy Android + iOS; `flutter analyze` sạch.
- Toàn bộ test mới + test cũ pass (`flutter test`).
- Test thủ công trên thiết bị: dán đoạn văn thật, tap từ, dịch (lần đầu có thể chờ tải model
  ML Kit), lưu, thấy trong "My Work" và trong phiên học tiếp theo.
- Home không regression (grid chủ đề, "Tiếp tục học", nút TTS Test giữ nguyên).

## Ràng buộc kiến trúc

- `presentation → application → domain ← data` giữ nguyên. `reading/domain` không import
  Flutter/`google_mlkit_translation`; package đó chỉ trong `reading/data`.
- `HomeScreen`/`MyWorkScreen`/`ReadingScreen` không import `data/` trực tiếp — qua
  provider/controller.
- Không đổi semantics `TopicLibraryRepository.importTopic` hiện có (chỉ thêm method mới).
- Không đổi `Navigator.push/pop` baseline (CLAUDE.md §5) — điều hướng mới chỉ là thêm push,
  không đổi cấu trúc app-level.
- `lib/features/reading/` là feature mới, chưa đủ 2 feature dùng chung nên không có gì lên
  `core/` từ đây.

## V1 KHÔNG làm (ghi rõ tránh hiểu nhầm phạm vi)

- Cache kết quả dịch (mỗi tap gọi ML Kit runtime — miễn phí, chấp nhận được).
- Lemmatization (tap từ dạng nào lưu dạng đó, vd "running" lưu nguyên "running").
- IPA/phonetic cho từ tự thêm (để rỗng).
- Chọn/kéo nhiều từ liền nhau (chỉ tap 1 từ/lần).
- Warm-up model ML Kit lúc mở app (tải lazy lần đầu dùng Reading, khác với TTS vốn ở luồng
  học chính — Reading là tính năng phụ, không cần chặn thời gian mở app).

## Definition of Ready (§14.4)

- [x] Requirement đã rõ (đo được — xem Mục tiêu)
- [x] Miền ảnh hưởng đã xác định (`reading/` mới + `vocabulary/` mở rộng + `study/home_screen.dart` sửa nhỏ)
- [x] Approval zone: domain contract (`WordLookupRepository` mới + `TopicLibraryRepository`
  thêm 4 method) — đã duyệt qua trao đổi trong task contract này
- [x] Phụ thuộc bên ngoài: thêm package `google_mlkit_translation` (miễn phí, on-device) — đã
  duyệt
- [x] Tiêu chí hoàn tất có thể test được

## Definition of Done (§14.5)

- [ ] Code đúng kiến trúc (`flutter analyze` sạch, import_lint không báo trái tầng)
- [ ] Test liên quan đã có và pass (`flutter test`)
- [ ] Không phá dependency direction
- [ ] Không thêm folder/file rỗng
- [ ] Không tạo import vòng hoặc import trái tầng
- [ ] ADR/tài liệu cần thiết đã cập nhật (task contract này)
