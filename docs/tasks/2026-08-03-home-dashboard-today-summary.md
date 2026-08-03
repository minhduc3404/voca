# Task Contract — Home dashboard "Hôm nay": today summary + streak + chủ đề đang học

> **CẬP NHẬT HƯỚNG (2026-08-03, sau khi xem wireframe `Ideas/wireframe_01.png`):**
> Wireframe thiết kế TRANG CHỦ = **topic browser** ("Chào bạn! Hôm nay bạn muốn học
> chủ đề gì?" + grid chủ đề + Tiếp tục học), KHÔNG phải dashboard thống kê.
> Theo quyết định của chủ dự án:
> - **Home = topic browser** (theo wireframe): greeting + grid chủ đề + "Tiếp tục học"
> - **Streak/stats → màn "Tiến độ học" riêng** (màn 8 trong wireframe)
> - **Thêm onboarding 3 màn** trước Home
> - **Bottom nav**: Khám phá / Tiến độ / Cá nhân (phạm vi: Khám phá = Home, Tiến độ = stats; Cá nhân = placeholder)
>
> Schema v5 (StudyLogTable + topic_id + topic_name + backfill) **vẫn giữ** — là
> nền tảng cho streak và chủ đề đang học trên màn Tiến độ học.

---

Điền theo `docs/templates/task-contract.md` (PLAN.md §14.3).

## Mục tiêu

Thay `home: MemoScreen` (chỉ hiện thẻ due) bằng **HomeScreen topic browser** theo wireframe:
- **Greeting**: "Chào bạn! Hôm nay bạn muốn học chủ đề gì?"
- **Grid chủ đề** (từ catalog — reuse `topic_catalog_controller`)
- **"Tiếp tục học"** card → resume bài đang dở
- Bottom nav: Khám phá / Tiến độ / Cá nhân
- Onboarding 3 màn (giới thiệu app) trước Home, flag qua shared_preferences
- Màn **Tiến độ học**: streak + summary (chuyển từ HomeScreen cũ) + chủ đề đang học

## Phạm vi file

### Schema v5 (approval zone — đã duyệt 2026-08-03) — GIỮ NGUYÊN
- **EDIT** `lib/core/db/tables.dart`: `VocabularyTable.topicId` + `DownloadedTopicsTable.topicName` + `StudyLogTable`
- **EDIT** `lib/core/db/app_database.dart`: schemaVersion 5, migration v4→v5 + backfill
- `app_database.g.dart` đã regenerate

### Domain (thuần, test được) — GIỮ NGUYÊN
- `lib/features/study/domain/study_stats.dart`: `TodayStudyStats`, `StudyStreak`, `computeStreak`, `dateKey`
- `lib/features/study/domain/study_log_repository.dart`
- `lib/features/study/domain/study_stats_repository.dart` + `ActiveTopic`

### Data — GIỮ NGUYÊN
- `DriftStudyLogRepository`, `DriftStudyStatsRepository`, `recordAnswer` transaction + study log, import topic set topicId/topicName

### Presentation — THAY ĐỔI
- **REWRITE** `lib/features/study/presentation/home_screen.dart` → Home = topic browser (greeting + grid chủ đề + Tiếp tục học)
- **NEW** `lib/features/study/presentation/progress_screen.dart` → Tiến độ học (streak + stats + chủ đề đang học) — nhận dữ liệu từ `TodaySummaryController` (giữ)
- **NEW** `lib/features/study/presentation/onboarding_screen.dart` → 3 màn intro
- **NEW** `lib/features/study/presentation/main_scaffold.dart` → bottom nav (Khám phá / Tiến độ / Cá nhân placeholder)
- **NEW** `lib/features/study/data/onboarding_flag_repository.dart` → abstraction shared_preferences cho onboarding flag (đã học onboarding chưa)
- **EDIT** `lib/app/app.dart` → `home:` quyết định: onboarding nếu chưa xem, ngược lại MainScaffold
- **EDIT** `lib/features/study/presentation/memo_screen.dart` → bỏ entry TopicListScreen (giờ ở Home), giữ back
- **EDIT** `lib/features/vocabulary/presentation/topic_list_screen.dart` → có thể giữ cho màn "Tất cả chủ đề" (từ Home "Xem tất cả")

### Tests
- **EDIT** `test/features/study/presentation/home_screen_test.dart` → test Home mới (grid chủ đề + greeting)
- **NEW** `test/features/study/presentation/onboarding_screen_test.dart`
- **NEW** `test/features/study/presentation/progress_screen_test.dart` (move streak/stats test)
- Giữ nguyên các test domain/data/migration

## Đầu ra mong đợi

- HomeScreen hiển thị đủ: streak, summary, chủ đề đang học, CTA.
- MemoScreen vẫn hoạt động khi push từ Home (không regression study flow).
- Migration v4→v5 + backfill đúng, test pass local.
- `dart analyze` sạch (import_lint: presentation không import data; domain không import flutter/riverpod/drift).

## Ràng buộc kiến trúc

- `presentation → application → domain ← data` giữ nguyên. `HomeScreen` (presentation) chỉ gọi controller (application); controller gọi repository contract (domain); `data/` implement.
- `computeStreak` ở **domain** (thuần Dart, không DateTime.now() — clock truyền vào).
- Không đụng `SessionController`/`srs_scheduler` logic.
- `AsyncStateView` đặt `features/study/presentation/widgets/` (chưa đủ 2 feature → chưa lên `core/`).

## Trạng thái (2026-08-03)

- [x] `dart analyze lib test` — **sạch, No issues found** (chạy bằng dart SDK 3.12.2 trong sandbox).
- [ ] `flutter test` — **chưa chạy** (SDK Flutter nằm trên ổ read-only trong sandbox, không dựng được flutter_tools). **CẦN CHẠY LOCAL:** `fvm flutter test`.
- [x] `computeStreak` — verify thuần (12 case, ALL PASS) qua `dart run` script tạm (đã xóa); test thật ở `test/features/study/domain/study_stats_test.dart`.
- [x] Backfill rule `_topicIdFromCatalogId` — verify thuần (7 case, ALL PASS); test thật ở `test/core/db/migration_v4_to_v5_test.dart`.
- [x] `app_database.g.dart` — đã regenerate (chứa StudyLogTable + topicId + topicName, schema v5) — 675 dòng thêm.
- [x] **REWORK 2026-08-03 (theo wireframe):** HomeScreen = topic browser (greeting + grid chủ đề + Tiếp tục học); streak/stats → `ProgressScreen` (màn Tiến độ học); `MainScaffold` bottom nav 3 tab (Khám phá / Tiến độ / Cá nhân); `OnboardingScreen` 3 màn intro (flag shared_preferences qua `OnboardingFlagRepository`); `app.dart` `_Root` chọn onboarding vs MainScaffold. Test: `home_screen_test` viết lại cho topic browser; mới `progress_screen_test`, `onboarding_screen_test`; `widget_test` cập nhật.
- [ ] `flutter test` toàn bộ suite local trước khi merge.

## Definition of Done (§14.5)

- [x] Code đúng kiến trúc (dart analyze lib test sạch — chỉ còn 1 info pre-existing RegExp deprecation ở memo_screen.dart:41)
- [x] Test liên quan đã viết (domain/data/migration giữ nguyên + presentation viết lại: home_screen, progress_screen, onboarding_screen, widget_test)
- [ ] Test pass local (`fvm flutter test`)
- [x] Không thêm folder/file rỗng
- [x] Không tạo import vòng hoặc import trái tầng (dart analyze sạch)
- [x] ADR/tài liệu cần thiết đã cập nhật (task contract này)

---

## Definition of Ready (§14.4) — phải tick hết trước khi bắt đầu

- [x] Requirement đã rõ (3 phần: summary/streak/topics + CTA)
- [x] Miền ảnh hưởng đã xác định (study + vocabulary + core/db)
- [x] Approval zone đã duyệt: schema v5 (StudyLogTable + topic_id + topic_name + backfill) — duyệt 2026-08-03; navigation cấp app (home → HomeScreen) — duyệt; streak rule nghiêm — duyệt
- [x] Phụ thuộc bên ngoài: không thêm package mới (drift/riverpod có sẵn)
- [x] Ước lượng: ~8 file mới + 6 file sửa + 6 test

## Definition of Done (§14.5)

- [ ] Code đúng kiến trúc
- [ ] Test liên quan đã có và pass (local)
- [ ] Không phá dependency direction
- [ ] Không thêm folder/file rỗng
- [ ] Không tạo import vòng hoặc import trái tầng
- [ ] ADR/tài liệu cần thiết đã cập nhật (task contract này)
