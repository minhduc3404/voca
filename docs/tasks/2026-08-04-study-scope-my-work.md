# Task Contract — Phạm vi phiên học (StudyScope) + nhóm "từ tôi lưu" trên Tiến độ

Trạng thái: **đã duyệt trực tiếp bởi chủ dự án (2026-08-04) — đã triển khai, CHƯA chạy được
`flutter analyze`/`flutter test`** (môi trường không có `flutter`/`dart` binary).

Bối cảnh: phân tích "My Work" trong hội thoại cùng ngày. Đây là **nhóm 2** trong bảng ưu tiên đã
trình bày — phần hạ tầng biến bộ từ tự thêm từ "kho lưu trữ" thành bộ học ôn riêng được.

## Mục tiêu

1. **(D)** Phiên học có thể giới hạn phạm vi: toàn bộ / một chủ đề catalog / riêng từ tự thêm —
   thay vì chỉ có đúng một phiên toàn cục như trước.
2. **(C)** Nhóm từ tự thêm (`topicId IS NULL`) hiện trong "Chủ đề đang học" ở màn Tiến độ, khớp lại
   với `dueCount`/`totalCount` (vốn đã luôn đếm cả từ tự thêm nhưng danh sách chủ đề thì loại ra).

Đo được:
- `getDueCards(now, scope: StudyScope.topic('travel'))` chỉ trả từ của chủ đề đó, vẫn tôn trọng lịch SRS.
- `getDueCards(now, scope: StudyScope.manual())` chỉ trả từ có `topicId IS NULL`.
- Màn Tiến độ liệt kê nhóm "Từ tôi lưu" kèm số từ; chạm vào một nhóm bất kỳ → mở `MemoScreen` chỉ ôn
  nhóm đó.
- Không đổi hành vi mặc định: mọi lời gọi cũ (`getDueCards(now)`, `MemoScreen()`) vẫn ôn toàn bộ.

## Ghi chú phạm vi quan trọng

Feature Reading/"My Work" (`docs/tasks/2026-08-04-reading-paste-translate-save.md`) **chưa được
implement ở bất kỳ branch nào** — đã kiểm tra `main` và cả 4 branch `claude/*`. Vì vậy task này
**không** thêm nút "Học ngay" trên `MyWorkScreen` (màn đó chưa tồn tại). Thay vào đó, cơ chế scope
được nối vào bề mặt UI đang có thật: danh sách "Chủ đề đang học" ở `ProgressScreen` — vốn đã render
`activeTopics` nhưng chưa bấm được.

Khi Reading/My Work được xây, nó chỉ cần push `MemoScreen(scope: const StudyScope.manual())` — hạ
tầng đã sẵn, không phải sửa lại domain/data.

## Phạm vi file

**NEW**
- `lib/features/study/domain/study_scope.dart` — `StudyScopeKind` + value object `StudyScope`
  (`all`/`topic(id)`/`manual`), có `==`/`hashCode` để dùng làm giá trị override provider.
- `test/features/study/domain/study_scope_test.dart`
- `test/features/study/application/session_controller_scope_test.dart`
- File contract này.

**EDIT — domain (approval zone §9: domain contract)**
- `domain/progress_repository.dart` — `getDueCards(DateTime now, {StudyScope scope = const StudyScope.all()})`.
- `domain/study_stats_repository.dart` — `ActiveTopic.topicId` đổi thành `String?` (null = nhóm tự
  thêm); thêm `isManual` và `scope`; cập nhật doc `getActiveTopics`.

**EDIT — data**
- `data/drift_progress_repository.dart` — lọc `vocabularyTable` theo scope (`topicId.equals` /
  `topicId.isNull()`), phần còn lại của thuật toán due giữ nguyên.
- `data/drift_study_stats_repository.dart` — `getActiveTopics` bỏ `WHERE v.topic_id IS NOT NULL`;
  đọc `topic_id`/`name` dạng nullable.

**EDIT — application**
- `application/providers.dart` — thêm `studyScopeProvider` (mặc định `StudyScope.all()`).
- `application/session_controller.dart` — `build()` watch `studyScopeProvider`, truyền xuống repository.

**EDIT — presentation**
- `presentation/memo_screen.dart` — `MemoScreen({StudyScope scope = const StudyScope.all()})`, trở
  thành `StatelessWidget` bọc `ProviderScope(overrides: [studyScopeProvider.overrideWithValue(scope)])`
  quanh `_MemoView` (toàn bộ nội dung cũ, không đổi logic).
- `presentation/progress_screen.dart` — `_TopicTile` bấm được (`Material` + `InkWell`) → push
  `MemoScreen(scope: topic.scope)`; nhãn `'Từ tôi lưu'` + icon `user` cho nhóm tự thêm; thêm dòng
  phụ đề "Chạm để ôn riêng nhóm từ này".

**EDIT — test (cập nhật theo contract mới)**
- 6 fake `ProgressRepository` (`progress_screen_test`, `home_screen_test`, `onboarding_screen_test`,
  `memo_screen_test`, `memo_screen_pause_speed_test`, `widget_test`) — thêm named param `scope`.
- `test/features/study/data/drift_progress_repository_test.dart` — nhóm test mới cho scope.
- `test/features/study/data/drift_study_stats_repository_test.dart` — test cũ
  `'không có topic_id → rỗng'` **đổi ý nghĩa có chủ đích** (giờ trả về 1 nhóm tự thêm), tách thành 3
  test mới.
- `test/features/study/presentation/progress_screen_test.dart` — nhãn "Từ tôi lưu" + chạm tile.

**KHÔNG đụng:** schema Drift (không migration — chỉ đọc `topicId` đã có từ v5), `HomeScreen`,
`features/vocabulary/`, `features/conversation/`.

## Quyết định thiết kế

**Vì sao override `ProviderScope` thay vì `AsyncNotifierProvider.family`?**
Family là cách idiomatic hơn, nhưng môi trường này không có pub cache để đọc/verify chữ ký chính xác
của family-notifier trong Riverpod 3, và cũng không compile được để bắt lỗi. Pattern
`ProviderScope` + `overrideWithValue` đã có tiền lệ chạy được trong repo (`bootstrap.dart` override
`audioHandlerProvider`), nên rủi ro thấp hơn. Chữ ký `sessionControllerProvider` cũng không đổi →
không call site nào bị vỡ. Nếu sau này muốn chuyển sang family, chỉ cần sửa
`session_controller.dart` + `memo_screen.dart`.

**Hệ quả có chủ đích:** mỗi scope là một container con, nên rời `MemoScreen` rồi vào lại sẽ **nạp lại**
danh sách thẻ due thay vì giữ nguyên vị trí đang dở như trước. Đây là điều cần thiết cho tính đúng
đắn (mở chủ đề A rồi chủ đề B không được dùng lại state của A), và khớp ghi chú sẵn có trong
`home_screen.dart` ("Hiện tại chưa lưu session state").

**Nhãn nhóm tự thêm nằm ở presentation** (`_TopicTile._manualLabel = 'Từ tôi lưu'`), domain để
`ActiveTopic.name` rỗng — giữ chuỗi UI ra khỏi domain/data.

## Ràng buộc kiến trúc

- `presentation → application → domain ← data` giữ nguyên. `study_scope.dart` thuần Dart, không
  import Flutter/Riverpod/Drift.
- Riverpod 3: vẫn `Notifier`/`AsyncNotifier`, không dùng pattern legacy.
- Approval zone §9 chạm: **domain contract** (`ProgressRepository.getDueCards`, `ActiveTopic`) — đã
  được chủ dự án duyệt trực tiếp qua yêu cầu "thực hiện nhóm 2".
- Không đụng persistence schema/migration → không có approval zone persistence.
- Không thêm folder/file rỗng, không barrel rộng.

## Tiêu chí hoàn tất

- [ ] `flutter analyze` sạch. *(Chưa chạy được — môi trường không có flutter/dart binary.)*
- [ ] `flutter test` pass toàn bộ, gồm test mới. *(Như trên — logic đã review thủ công, chưa chạy.)*
- [x] `getDueCards` mặc định không đổi hành vi (scope mặc định = all).
- [x] Mọi implementation/fake của `ProgressRepository` đã cập nhật theo chữ ký mới (6 fake test +
      1 impl thật) — `grep` xác nhận không còn chữ ký cũ.
- [x] `ActiveTopic` nullable `topicId` không phá call site cũ (test cũ dựng với `topicId` non-null
      vẫn hợp lệ).
- [ ] Test thủ công trên thiết bị: màn Tiến độ hiện nhóm "Từ tôi lưu", chạm vào ôn đúng nhóm đó.
      *(Cần chủ dự án verify.)*

---

## Definition of Ready (§14.4)
- [x] Requirement rõ (nhóm 2 = D + C trong phân tích đã trình bày)
- [x] Miền ảnh hưởng xác định (`features/study/` domain+data+application+presentation)
- [x] Contract đầu vào/đầu ra kiểm chứng được (scope → tập thẻ trả về)
- [x] Phụ thuộc bên ngoài: không thêm package mới
- [x] Tiêu chí hoàn tất test được

## Definition of Done (§14.5)
- [x] Code đúng kiến trúc
- [ ] Test liên quan đã có và qua *(đã viết, chưa chạy được)*
- [x] Không phá dependency direction
- [x] Không thêm folder/file rỗng
- [x] Không tạo import vòng hoặc import trái tầng
- [x] Tài liệu cần thiết đã cập nhật (contract này)
