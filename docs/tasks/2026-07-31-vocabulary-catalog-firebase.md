# Task Contract — Catalog từ vựng theo chủ đề (Firebase Cloud Storage)

Điền theo `docs/templates/task-contract.md` (PLAN.md §14.3). **Đã implement — 2026-07-31** (xem "Hoàn tất" cuối file).

---

## Bối cảnh / quyết định đã chốt (2026-07-31)

- Nguồn: **Cloud Storage for Firebase**, file JSON tĩnh theo chủ đề — không dùng Firestore (tránh chi phí đọc theo document cho catalog tĩnh lớn).
- Sync: **tải theo yêu cầu** khi user chọn học 1 chủ đề lần đầu; sau đó **offline hoàn toàn**. Có cơ chế phát hiện + áp dụng bản cập nhật (so `version` trong `topics.json` với version đã tải local).
- Vẫn giữ nguyên `study/` feature — không sửa domain/application của `study/`. Catalog chỉ ghi vào `VocabularyTable` sẵn có, coi như một nguồn nhập dữ liệu mới (giống `seedInitialVocabulary` nhưng động).

## Mục tiêu

Người dùng duyệt danh sách chủ đề từ vựng (Du lịch, Ngành học, Oxford 3000...), chọn 1 chủ đề để tải về — từ được thêm vào bộ học local, sẵn sàng xuất hiện trong luồng ôn tập `study/` như từ tự nhập. Khi chủ đề có bản cập nhật trên remote, app báo và cho phép đồng bộ lại mà không mất tiến độ SRS đã có.

## Phạm vi file

- **NEW feature** `lib/features/vocabulary/` (đặt tên khác `study/` — hai mối quan tâm riêng: duyệt/nhập catalog vs ôn tập):
  - `domain/topic.dart` — `Topic { id, name, wordCount, version }`
  - `domain/catalog_word.dart` — `CatalogWord { id, term, definition, phonetic, partOfSpeech, exampleSentence }` (khác `StudyCard` — chưa có progress, chưa "thuộc về" local DB)
  - `domain/vocabulary_catalog_repository.dart` — interface: `Future<List<Topic>> listTopics()`, `Future<List<CatalogWord>> fetchTopicWords(String topicId)`
  - `domain/downloaded_topic.dart` — `DownloadedTopic { topicId, downloadedVersion, downloadedAt }`
  - `domain/topic_library_repository.dart` — interface: `Future<List<DownloadedTopic>> getDownloadedTopics()`, `Future<void> importTopic(Topic topic, List<CatalogWord> words)` (ghi vào `VocabularyTable` + `DownloadedTopicsTable`, tạo `WordProgress.initial()` cho từ mới, **match theo `catalogId` để không tạo trùng khi update**)
  - `data/firebase_catalog_repository.dart` — implement `VocabularyCatalogRepository` bằng `firebase_storage` (đọc `topics.json` + `<topicId>.json`)
  - `data/drift_topic_library_repository.dart` — implement `TopicLibraryRepository` bằng Drift (dùng `AppDatabase` sẵn có)
  - `application/topic_catalog_controller.dart` — `AsyncNotifier<List<Topic>>`, có method `downloadTopic(Topic)`, `checkForUpdates()`
  - `presentation/topic_list_screen.dart`, `presentation/topic_detail_screen.dart`

- **EDIT (schema — approval zone)**:
  - `lib/core/db/tables.dart`:
    - `VocabularyTable` — thêm cột `catalogId TEXT NULL UNIQUE` (nullable — từ tự nhập tay hoặc seed cũ không có).
    - Bảng mới `DownloadedTopicsTable` — `topicId TEXT PRIMARY KEY`, `downloadedVersion INTEGER`, `downloadedAt DATETIME`.
  - `lib/core/db/app_database.dart` — `schemaVersion => 3`, `onUpgrade` thêm cột + bảng mới, migration test thật (giống pattern v1→v2 đã có).

- **EDIT**: `pubspec.yaml` (+`firebase_core`, +`firebase_storage`), `android/app/build.gradle.kts` + `ios/Runner/` (wiring config file Firebase — cần `google-services.json`/`GoogleService-Info.plist` từ người dùng).

- Không đụng `lib/features/study/domain/`, `session_controller.dart`, `srs_scheduler.dart` — `study/` chỉ đọc `VocabularyTable`/`ProgressTable` như cũ, không biết catalog tồn tại.

## Đầu ra mong đợi

- Màn danh sách chủ đề (tên, số từ, đã tải hay chưa, có badge "cập nhật" nếu remote version mới hơn local).
- Bấm 1 chủ đề → tải + import vào `VocabularyTable`, chuyển ngay được sang `study/` để ôn.
- Cập nhật lại 1 chủ đề đã tải → từ cũ giữ nguyên tiến độ SRS (match theo `catalogId`), từ mới trong bản cập nhật được thêm, từ bị xóa khỏi catalog **không tự xóa local** (tránh mất tiến độ ngoài ý muốn — chỉ thêm/cập nhật nội dung, không xóa).

## Ràng buộc kiến trúc

- `firebase_storage`/`firebase_core` chỉ được import trong `lib/features/vocabulary/data/` — không lộ ra `application/`/`presentation/` (đúng pattern đã dùng cho Drift/TTS/wakelock).
- `study/` không đổi gì — `vocabulary/` là consumer của `core/db/` giống `study/`, không phải ngược lại.
- Domain `vocabulary/` không phụ thuộc domain `study/` và ngược lại — 2 feature độc lập, chỉ gặp nhau ở tầng `data/` qua `AppDatabase` chung (`core/db/`).
- Migration v2→v3 phải có test thật (raw SQL dựng schema v2, insert dữ liệu, mở lại bằng `AppDatabase` v3, verify) — theo đúng tiền lệ `migration_test.dart`.

## Tiêu chí hoàn tất

- `dart analyze` sạch, `flutter test` pass — test cho: parse JSON catalog, import lần đầu (tạo mới), import lại sau update (match theo `catalogId`, không tạo trùng, không mất `WordProgress` cũ), migration v2→v3.
- Không phá `import_lint`.
- Toàn bộ test hiện có vẫn pass (không regression Phase 1/2 + các feature sau đó).
- Firebase Storage rules cho phép đọc public, không cần auth (catalog không nhạy cảm).

---

## Definition of Ready — CHƯA tick, đang chờ

- [ ] Firebase project đã tạo, đã bật Cloud Storage.
- [ ] `google-services.json` (Android) + `GoogleService-Info.plist` (iOS) đã có, đặt đúng chỗ.
- [ ] Ít nhất 1 file `topics.json` + 1 file chủ đề mẫu đã upload lên Storage theo schema đã thống nhất (xem phần dưới) để dev/test thật, không phải mock.
- [ ] Storage security rules đã set (đọc public).
- [ ] Nội dung `oxford-3000`/`1000` (nếu dùng danh sách có thương hiệu) đã kiểm tra license — nếu tự biên soạn thì bỏ qua mục này.

## Schema JSON catalog (đã thống nhất trong thảo luận — không phải approval zone riêng, đã duyệt cùng contract này)

```jsonc
// catalog/topics.json
[
  { "id": "travel", "name": "Du lịch", "wordCount": 120, "version": 1, "file": "travel.json" },
  { "id": "oxford-3000", "name": "Oxford 3000", "wordCount": 3000, "version": 1, "file": "oxford-3000.json" }
]

// catalog/travel.json
{
  "topicId": "travel",
  "version": 1,
  "words": [
    {
      "id": "travel-001",
      "term": "itinerary",
      "definition": "lịch trình",
      "phonetic": "/aɪˈtɪn.ə.rer.i/",
      "partOfSpeech": "noun",
      "exampleSentence": "Our itinerary includes three cities in five days."
    }
  ]
}
```

`words[].id` bắt buộc ổn định + duy nhất toàn catalog (không riêng từng file) — dùng làm `VocabularyTable.catalogId`.

---

## Hoàn tất — 2026-07-31

**Thay đổi so với thiết kế gốc:**
- Dùng `firebase_storage` SDK thật (không phải HTTP+token) — user đã publish Storage rule `allow read: if true;` cho toàn bucket, xác nhận qua fetch `topics.json`/`travel.json` không cần token.
- File catalog thực tế nằm ở **root bucket** (`topics.json`, `travel.json`), không phải trong `catalog/` như ví dụ minh họa ban đầu — `FirebaseCatalogRepository` đọc đúng theo path thật.
- Quy ước tên file chi tiết chủ đề: luôn `<topicId>.json` (không dùng field `"file"` trong `topics.json` để tra cứu) — đơn giản hơn, ít điểm hỏng hơn.
- **`google-services.json`/`GoogleService-Info.plist`** đã chuyển từ `google-services/` (do user upload tạm) vào đúng vị trí chuẩn Flutter: `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`. Đã wiring Gradle plugin `com.google.gms.google-services` (`android/settings.gradle.kts`, `android/app/build.gradle.kts`). `Firebase.initializeApp()` gọi trong `bootstrap.dart`, **bỏ qua trên web** (`kIsWeb`) vì project chưa đăng ký app Firebase cho Web — feature catalog tạm thời chỉ hoạt động Android/iOS.

**Implement:**
- `lib/features/vocabulary/` — feature mới đủ 4 lớp: `domain/` (`Topic`, `CatalogWord`, `DownloadedTopic`, `VocabularyCatalogRepository`, `TopicLibraryRepository`), `data/` (`FirebaseCatalogRepository` + hàm parse JSON thuần `parseTopicsJson`/`parseTopicWordsJson` tách riêng để test không cần SDK, `DriftTopicLibraryRepository`), `application/` (`providers.dart`, `TopicCatalogController` — `AsyncNotifier`), `presentation/` (`TopicListScreen`).
- Schema v3: `VocabularyTable.catalogId` (nullable, unique), bảng mới `DownloadedTopicsTable`. **Bug thật phát hiện lúc viết migration**: SQLite không cho `ALTER TABLE ... ADD COLUMN ... UNIQUE` — sửa bằng cách thêm cột trơn rồi tạo `CREATE UNIQUE INDEX` riêng.
- Entry point: icon "Chủ đề từ vựng" trên AppBar `MemoScreen` (Material icon tạm `Icons.menu_book_outlined` — **chưa** phải SVG Reicon duotone theo ADR-009, để làm sau khi có asset).
- Import không đụng `study/domain/` — từ mới thêm vào `VocabularyTable` tự động được `study/` coi là "due ngay" vì chưa có `ProgressTable` row (hành vi sẵn có từ Phase 2), không cần `vocabulary/` biết gì về SRS.

**Verify:**
- `dart analyze` sạch, `flutter test` **51/51 pass** (10 test mới: parse JSON bằng dữ liệu THẬT fetch trực tiếp từ bucket production lúc code — không phải mock tự bịa; import lần đầu/update không trùng/giữ tiến độ SRS; controller build/download/lỗi; migration v2→v3 thật; widget test màn danh sách chủ đề).
- Đã verify **thật** qua `WebFetch` trực tiếp vào bucket `voca-370e1.firebasestorage.app`: `topics.json` và `travel.json` (12 từ) đọc công khai thành công, đúng schema.

**Chưa verify được:**
- Build/chạy thật trên thiết bị Android/iOS (sandbox không có Android SDK/Xcode) — chỉ verify được qua `flutter test` (VM) + `dart analyze`. Wiring Gradle/Podfile đúng cú pháp nhưng chưa build thử thật.
- Lời gọi `firebase_storage` SDK thật qua platform channel (đã verify logic parse bằng dữ liệu thật, nhưng chưa chạy được `FirebaseCatalogRepository.listTopics()` end-to-end trên thiết bị thật).
- iOS: `GoogleService-Info.plist` đã đặt đúng thư mục `ios/Runner/` nhưng **chưa** được thêm vào `Runner.xcodeproj` như resource build (cần Xcode để làm đúng cách, hoặc build thử `pod install` để CocoaPods/Firebase pod tự nhận file — chưa verify được trong sandbox này).
