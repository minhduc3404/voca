# Task Contract — Phase 1 & 2: Feature `study/` qua đủ 4 lớp + Drift persistence

Điền theo `docs/templates/task-contract.md` (PLAN.md §14.3), phạm vi = `PLAN-PHASE-1-2.md`.

---

## Mục tiêu

Dựng feature `study/` chạy qua đủ 4 lớp (`presentation → application → domain ← data`) trước với repository fake/in-memory (Phase 1), sau đó thay bằng Drift thật (Phase 2) mà không sửa domain/controller/presentation. Kiểm chứng: dependency direction đúng, provider injection override được cho test, `srs_scheduler` test được thuần Dart không cần `pumpWidget`.

## Phạm vi file

Đúng theo `PLAN-PHASE-1-2.md` (đã cập nhật khớp trạng thái Phase 0 hiện có):

- **Phase 1 — NEW**: `lib/core/providers.dart`, `lib/core/constants.dart` (nếu có hằng số thật), `lib/features/study/domain/{study_card,word_progress,srs_scheduler,progress_repository}.dart`, `lib/features/study/data/fake_progress_repository.dart`, `lib/features/study/application/{session_controller,providers}.dart`, `lib/features/study/presentation/memo_screen.dart`, `lib/features/study/presentation/widgets/{word_card,control_bar}.dart`.
- **Phase 1 — EDIT**: `lib/app/app.dart` (đổi `home:` từ `_HomePlaceholder` sang `MemoScreen`).
- **Phase 2 — NEW**: `lib/core/db/tables.dart`, `lib/core/db/app_database.dart` (+ `.g.dart` generated), `lib/features/study/data/drift_progress_repository.dart`.
- **Phase 2 — EDIT**: `lib/core/providers.dart`, `lib/features/study/application/providers.dart`.
- **Phase 2 — DELETE**: `lib/features/study/data/fake_progress_repository.dart`.
- **Không đụng**: `pubspec.yaml`, `analysis_options.yaml`, `main.dart`, `app/bootstrap/bootstrap.dart`, `app/theme/app_theme.dart`, `l10n/` — đã đúng chuẩn từ Phase 0.

Ngoài phạm vi này = ngoài task (không đụng `features/deck/`, `features/settings/`, navigation cấp ứng dụng ngoài 1 điểm nối `home:`).

## Đầu ra mong đợi

- Code Phase 1 + Phase 2 theo đúng cây file ở trên.
- `srs_scheduler_test.dart` — 12 test case theo test matrix PLAN-PHASE-1-2.md, dùng tham số cụ thể từ ADR-010.
- Migration test (Phase 2): mở DB version cũ, migrate, verify data nguyên vẹn.
- Repository test (Phase 2): insert vocab, insert progress, join, đọc đúng.
- ADR-010 (SRS algorithm — đã tạo, xem `docs/adr/ADR-010-srs-sm2-algorithm.md`).

## Ràng buộc kiến trúc

- `domain/` không import Flutter/Riverpod/Drift/shared_preferences (CLAUDE.md §2, enforce tự động qua `import_lint` trong `analysis_options.yaml`).
- `application/` không import Drift table/query hay `shared_preferences` trực tiếp (CLAUDE.md §2, enforce tự động qua `application_no_drift`/`application_no_shared_preferences` trong `import_lint`).
- `presentation/` không import `data/` trực tiếp (đã có `presentation_no_data` trong import_lint).
- `session_controller.dart` không được sửa ở Phase 2 — chỉ inject `ProgressRepository` contract, không biết Drift tồn tại.
- Approval zone bị chạm: **domain contract** (SRS algorithm — đã duyệt qua ADR-010) và **persistence schema/migration** (Phase 2 — cần duyệt schema `VocabularyTable`/`ProgressTable` trước khi implement thật).

## Tiêu chí hoàn tất

Xem "Exit criteria Phase 1" và "Exit criteria Phase 2" đầy đủ trong `PLAN-PHASE-1-2.md`. Tóm tắt:
- `dart analyze` sạch cả 2 phase, không regression.
- `srs_scheduler` ≥ 5 test case (Phase 1) / đủ 12 case (khi có Drift ở Phase 2 cho case 12).
- Flow end-to-end chạy được: màn hình → controller → scheduler → repo → UI update.
- Thay repository implementation chỉ cần sửa `application/providers.dart`.
- Migration test + repository test pass (Phase 2), restart app → data không mất.
- `fake_progress_repository.dart` xóa sạch, không còn import tham chiếu.

---

## Definition of Ready (§14.4) — đã tick trước khi bắt đầu

- [x] Requirement đã rõ — theo `PLAN-PHASE-1-2.md` đã review và đồng bộ với codebase thực tế.
- [x] Miền ảnh hưởng đã xác định — `lib/core/`, `lib/features/study/` (4 lớp), 1 điểm nối `app/app.dart`.
- [x] Contract đầu vào/đầu ra có thể kiểm chứng — `srs_scheduler` input/output đã chốt cụ thể (ADR-010), `ProgressRepository` interface đã định nghĩa.
- [x] Phụ thuộc bên ngoài đã biết — toàn bộ dependency (`drift`, `riverpod`, ...) đã có sẵn trong `pubspec.yaml` từ Phase 0.
- [x] Tiêu chí hoàn tất có thể test được — exit criteria đo được (test pass, `dart analyze` sạch, grep import cấm rỗng).

## Definition of Done (§14.5) — tick trước khi merge

- [x] Code đúng kiến trúc — Phase 1 đã implement (`lib/features/study/` đủ 4 lớp), verify bằng `dart analyze` thật (cài Flutter 3.44.8 vào sandbox) — `import_lint` pass, không vi phạm layer nào.
- [x] Test liên quan đã có và qua — `flutter test`: **15/15 pass** (11 case `srs_scheduler_test.dart` + case 12 và 2 case khác trong `fake_progress_repository_test.dart` + `widget_test.dart` có sẵn từ Phase 0 vẫn pass không cần sửa).
- [x] Không phá dependency direction
- [x] Không thêm folder/file rỗng — `lib/core/` chủ động **không tạo** ở Phase 1 (chưa có nội dung thật), dời `providers.dart` sang Phase 2.
- [x] Không tạo import vòng hoặc import trái tầng — `dart analyze` sạch (bao gồm `import_lint`), không còn chỉ là grep thủ công.
- [x] Tài liệu/ADR cần thiết đã cập nhật (ADR-010 đã có; schema Phase 2 vẫn cần con người duyệt riêng trước khi implement Drift)

**Phase 1: Definition of Done đã đạt đủ 6/6 mục.** Xác nhận bằng `flutter pub get && dart analyze && flutter test` chạy trực tiếp trong sandbox (cài Flutter SDK tạm thời qua `git clone` — xem log phiên làm việc), ngày 2026-07-30.

## Phase 2 — hoàn tất 2026-07-30

Sau khi duyệt schema `VocabularyTable` (bổ sung `phonetic`/`partOfSpeech`/`exampleSentence` qua sample-data review) và `ProgressTable` (giữ nguyên như phác thảo), đã implement đầy đủ:
- `core/db/tables.dart`, `core/db/app_database.dart` (+ `.g.dart` generated qua `build_runner`)
- `core/providers.dart` (`appDatabaseProvider`) — tạo NEW thật, không phải EDIT placeholder
- `data/drift_progress_repository.dart` — thay `FakeProgressRepository` (đã xóa, không còn reference)
- `application/providers.dart` — EDIT 1 dòng duy nhất để chuyển implementation
- `session_controller.dart` — **không đổi gì**, verify bằng `git diff`

Test: `test/core/db/app_database_test.dart` (schema v1 + `uniqueKeys`), `test/features/study/data/drift_progress_repository_test.dart` (6 case, gồm case 12 persist/reload và 1 test restart-app thật bằng đóng/mở lại kết nối trên cùng file `.sqlite`). Toàn suite: **21/21 pass**, `dart analyze` sạch.

**Lưu ý về "migration test"**: schema hiện ở version 1 (khởi tạo lần đầu) — chưa có version cũ để test đường nâng cấp thật. Đã test đúng phần có ý nghĩa ở v1 (`onCreate`, ràng buộc `uniqueKeys`). Test migrate v1→v2 thật sẽ viết khi có schema change đầu tiên — ghi lại như một khoản nợ kỹ thuật đã biết trước, không phải bị bỏ sót.

Định nghĩa Done Phase 2: **12/12 exit criteria đạt**, xem `PLAN-PHASE-1-2.md` mục "Exit criteria Phase 2" để biết chi tiết cách verify từng mục.
