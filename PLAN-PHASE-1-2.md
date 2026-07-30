# Voca — Kế hoạch triển khai Phase 1 & 2

## Trạng thái đầu vào

Repo trống, không có `pubspec.yaml`, không có `lib/`, không có `android/`, không có `ios/`.

---

## Kiến trúc mục tiêu (nhắc lại)

```
Feature-first, tối đa 4 lớp/feature
presentation → application → domain ← data
```

Stack chốt: Riverpod 3 + Drift/drift_flutter + shared_preferences + Navigator.push/pop + ARB/gen_l10n + bundled TTF.
Không baseline: go_router, freezed, google_fonts.

---

# Phase 1 — Nền tảng kiến trúc

## Mục tiêu

Feature `study/` chạy qua đủ 4 lớp với fake/in-memory persistence.
Kiểm chứng: dependency direction, provider injection, testability domain.

## Cây thư mục sau Phase 1

```
VocaApp/
├── pubspec.yaml                          NEW
├── analysis_options.yaml                 NEW
│
└── lib/
    ├── main.dart                         NEW
    ├── app.dart                          NEW
    │
    ├── core/
    │   ├── constants.dart                NEW  (nếu có hằng số thật)
    │   └── providers.dart                NEW  (placeholder hạ tầng)
    │
    └── features/
        └── study/
            ├── domain/
            │   ├── study_card.dart        NEW
            │   ├── word_progress.dart     NEW
            │   ├── srs_scheduler.dart     NEW
            │   └── progress_repository.dart NEW (interface)
            │
            ├── data/
            │   └── fake_progress_repository.dart NEW
            │
            ├── application/
            │   ├── session_controller.dart NEW
            │   └── providers.dart          NEW
            │
            └── presentation/
                ├── memo_screen.dart        NEW
                └── widgets/
                    ├── word_card.dart      NEW
                    └── control_bar.dart    NEW
```

Tổng: **15 file** — tất cả NEW. Không có `core/db/`, `features/deck/`, `features/settings/`, barrel file.

## Chi tiết từng file

### Project root

| # | File | Nội dung tối thiểu |
|---|------|-------------------|
| 1 | `pubspec.yaml` | `flutter`, `flutter_riverpod`, `flutter_localizations`, `intl`, `flutter_lints` (dev), `build_runner` (dev) |
| 2 | `analysis_options.yaml` | `include: package:flutter_lints/flutter.yaml` |

### `lib/` — App entry

| # | File | Lớp | Nội dung | Cấm import |
|---|------|-----|----------|------------|
| 3 | `main.dart` | entry | `runApp(ProviderScope(child: App()))` | — |
| 4 | `app.dart` | presentation | `MaterialApp` + theme + supportedLocales + localizationsDelegates + home | domain/data/DB trực tiếp |

### `lib/core/`

| # | File | Nội dung |
|---|------|----------|
| 5 | `constants.dart` | Hằng số dùng chung (chỉ tạo nếu có thật, không tạo file rỗng) |
| 6 | `providers.dart` | Provider hạ tầng — ở Phase 1 chỉ là placeholder, sẽ có db/prefs thật ở Phase 2 |

### `lib/features/study/domain/` — Pure Dart

| # | File | Mô tả | Import hợp lệ |
|---|------|-------|--------------|
| 7 | `study_card.dart` | Model thẻ học: term, definition, language | `dart:core` |
| 8 | `word_progress.dart` | Trạng thái SRS: interval, easeFactor, nextReview, reps, lapses | `dart:core` |
| 9 | `srs_scheduler.dart` | Hàm thuần: `(currentProgress, answer, now) → newProgress` | `dart:core`, `study_card`, `word_progress` |
| 10 | `progress_repository.dart` | Interface: `getDueCards()`, `recordAnswer()`, `getProgress()` | `dart:core`, `study_card`, `word_progress` |

**Tất cả 4 file domain cấm import:** `package:flutter/`, `package:flutter_riverpod/`, `package:drift/`, `package:shared_preferences/`.

### `lib/features/study/data/`

| # | File | Mô tả | Import hợp lệ |
|---|------|-------|--------------|
| 11 | `fake_progress_repository.dart` | Implement `ProgressRepository` bằng `Map<int, WordProgress>` in-memory | `domain/`, `dart:collection` |

### `lib/features/study/application/`

| # | File | Mô tả | Import hợp lệ |
|---|------|-------|--------------|
| 12 | `session_controller.dart` | Riverpod `Notifier`, state: `StudySessionState`, method: `submitAnswer(rating)` → gọi scheduler → gọi repo | `flutter_riverpod`, `domain/` |
| 13 | `providers.dart` | Provider nối `FakeProgressRepository` vào `ProgressRepository` contract | `flutter_riverpod`, `domain/`, `data/` |

**Cấm import:** `package:flutter/widgets.dart`, `Navigator`, `data/` (trong controller — chỉ providers.dart mới import data).

### `lib/features/study/presentation/`

| # | File | Mô tả | Import hợp lệ |
|---|------|-------|--------------|
| 14 | `memo_screen.dart` | Widget đọc `sessionControllerProvider`, hiển thị card + control bar, gọi `submitAnswer` | `flutter/material`, `flutter_riverpod`, `application/`, `widgets/` |
| 15a | `widgets/word_card.dart` | Widget hiển thị mặt trước/sau thẻ học | `flutter/material`, `domain/study_card.dart` |
| 15b | `widgets/control_bar.dart` | Widget nút chọn rating (again/hard/good/easy) | `flutter/material` |

**Cấm import:** `core/db/`, `data/`, Drift table, `shared_preferences`, `domain/` (trừ model).

## Dependency direction — Phase 1

```
presentation ──→ application ──→ domain ←── data
memo_screen      session_ctrl    srs_scheduler   fake_repo
word_card                        progress_repo   (Map in-memory)
control_bar                      study_card
                                 word_progress
```

## Exit criteria Phase 1

- [ ] `dart analyze` sạch, không warning.
- [ ] Không có Flutter/Riverpod/Drift import trong `features/study/domain/`.
- [ ] `srs_scheduler` test pass (≥ 5 test case), không cần `pumpWidget`.
- [ ] Flow chạy end-to-end: màn hình → controller → scheduler → repo → UI update.
- [ ] Repository inject được qua provider, override được cho test.
- [ ] Có thể xóa `fake_progress_repository.dart` mà không sửa bất kỳ file nào khác.
- [ ] Domain model không bị leak ra presentation dưới dạng mutable.
- [ ] Không folder rỗng, không barrel file.

---

# Phase 2 — Persistence nền

## Mục tiêu

Thay fake/in-memory repository bằng Drift thật. Schema tồn tại, migration test được, UI vẫn không chạm DB.

## Cây thư mục sau Phase 2

```
VocaApp/
├── pubspec.yaml                          EDIT (+drift, +drift_flutter)
├── analysis_options.yaml                 NONE
│
└── lib/
    ├── main.dart                         NONE
    ├── app.dart                          NONE
    │
    ├── core/
    │   ├── constants.dart                NONE
    │   ├── providers.dart                EDIT (+appDatabaseProvider)
    │   │
    │   └── db/                           ← MỚI
    │       ├── tables.dart               NEW
    │       └── app_database.dart         NEW
    │           app_database.g.dart       (generated, không edit)
    │
    └── features/
        └── study/
            ├── domain/
            │   ├── study_card.dart        NONE
            │   ├── word_progress.dart     NONE
            │   ├── srs_scheduler.dart     NONE
            │   └── progress_repository.dart NONE (interface giữ nguyên)
            │
            ├── data/
            │   ├── ✗ fake_progress_repository.dart  DELETE
            │   └── drift_progress_repository.dart    NEW
            │
            ├── application/
            │   ├── session_controller.dart NONE
            │   └── providers.dart          EDIT (repo provider)
            │
            └── presentation/
                ├── memo_screen.dart        NONE
                └── widgets/
                    ├── word_card.dart      NONE
                    └── control_bar.dart    NONE
```

| Status | Số file | Ghi chú |
|--------|---------|---------|
| NEW | 3 | tables.dart, app_database.dart, drift_progress_repository.dart |
| EDIT | 3 | pubspec.yaml, core/providers.dart, application/providers.dart |
| DELETE | 1 | fake_progress_repository.dart |
| NONE | 12 | toàn bộ domain, controller, presentation, main, app |
| **Tổng** | **19** | (15 Phase 1 + 3 NEW − 1 DELETE + 2 file mở rộng) |

**12/19 file không cần sửa** khi thay toàn bộ persistence layer — bằng chứng kiến trúc đúng.

## Chi tiết file thay đổi

### EDIT — `pubspec.yaml`

Thêm:

```yaml
dependencies:
  drift: ^2.x
  drift_flutter: ^0.x
  sqlite3_flutter_libs: ^0.x   # nếu drift docs yêu cầu
  path_provider: ^2.x          # nếu drift docs yêu cầu

dev_dependencies:
  drift_dev: ^2.x
  build_runner: ^2.x
```

Phiên bản cụ thể tra drift docs tại thời điểm code.

### NEW — `core/db/tables.dart`

```dart
// Định nghĩa Drift table — không chứa business logic
VocabularyTable:
  id: int (autoIncrement)
  term: text
  definition: text
  language: text
  createdAt: dateTime

ProgressTable:
  id: int (autoIncrement)
  vocabId: int (→ VocabularyTable)
  interval: int
  easeFactor: double
  reps: int
  lapses: int
  nextReview: dateTime
  lastReview: dateTime
  createdAt: dateTime
  updatedAt: dateTime
```

### NEW — `core/db/app_database.dart`

```dart
@DriftDatabase(tables: [VocabularyTable, ProgressTable])
class AppDatabase extends $AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m, version) async { /* tạo bảng */ },
    onUpgrade: (m, from, to) async { /* migration code */ },
  );
}
```

### EDIT — `core/providers.dart`

```dart
// Thêm (giữ nguyên các provider khác nếu có)
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(/* drift_flutter setup */);
  ref.onDispose(() => db.close());
  return db;
});
```

### EDIT — `features/study/application/providers.dart`

```dart
// Sửa: FakeProgressRepository → DriftProgressRepository
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return DriftProgressRepository(ref.watch(appDatabaseProvider));
});
```

`session_controller.dart` không cần sửa — nó chỉ inject `ProgressRepository` contract.

### NEW — `features/study/data/drift_progress_repository.dart`

```dart
class DriftProgressRepository implements ProgressRepository {
  final AppDatabase _db;
  DriftProgressRepository(this._db);

  // query ProgressTable + join VocabularyTable
  // map Drift row → domain WordProgress
  // map domain WordProgress → Drift companion (upsert)
}
```

### DELETE — `features/study/data/fake_progress_repository.dart`

Xóa hoàn toàn. Sau khi xóa, không còn import nào tham chiếu file này.

## Migration rules

- Mỗi schema change: tăng `schemaVersion`, viết migration code trong `onUpgrade`, có migration test.
- Migration test: mở DB version cũ (in-memory), chèn dữ liệu, migrate, verify dữ liệu nguyên vẹn.
- Không destructive migration (`DROP TABLE` + tạo lại) trừ khi có lý do + human duyệt.
- Human approval bắt buộc cho: thay primary key, unique constraint, delete behavior, SRS history semantics.
- AI không tự thực hiện schema change nếu task contract chưa được duyệt.

## Dependency direction — Phase 2

```
presentation ──→ application ──→ domain ←── data ←── core/db
memo_screen      session_ctrl    srs_scheduler   drift_repo   app_database
word_card                        progress_repo   (query+map)  tables
control_bar                      study_card
                                 word_progress
```

Mũi tên `data ←── core/db`: data layer phụ thuộc infrastructure — đây là hướng hợp lệ.

## Exit criteria Phase 2

- [ ] `dart analyze` sạch — không regression từ Phase 1.
- [ ] `dart run build_runner build` thành công, generated file hợp lệ.
- [ ] Migration test pass — mở DB version cũ, migrate, data nguyên vẹn.
- [ ] Repository test pass — insert vocab, insert progress, join, đọc đúng.
- [ ] UI không import `core/db/` hoặc Drift table trực tiếp.
- [ ] `session_controller.dart` không bị sửa (chỉ inject contract, không biết Drift tồn tại).
- [ ] Restart app → progress không mất (manual verify hoặc integration test).
- [ ] `shared_preferences` không được dùng cho progress data.
- [ ] `fake_progress_repository.dart` đã bị xóa, không còn import tham chiếu.
- [ ] Phase 1 exit criteria vẫn đúng (không regression).
- [ ] Human duyệt schema + migration strategy.
- [ ] Không folder rỗng mới, không barrel file.

## Kiểm tra nhanh import cấm

```bash
# Sau Phase 2, chạy các lệnh này để verify
grep -r "import.*package:flutter" lib/features/study/domain/    # → phải rỗng
grep -r "import.*core/db" lib/features/study/presentation/       # → phải rỗng
grep -r "import.*core/db" lib/features/study/application/        # → phải rỗng
grep -r "import.*data/drift_progress" lib/features/study/application/session_controller.dart  # → phải rỗng
grep -r "import.*shared_preferences" lib/features/study/         # → chỉ trong data/ (nếu cần)
```

---

## SRS domain contract (dùng chung cho cả 2 phase)

`srs_scheduler` là hàm pure-Dart:

```
input:  (WordProgress current, int rating, DateTime now)
output: WordProgress new (immutable, không mutate input)
```

Không gọi `DateTime.now()` bên trong. Clock được inject qua tham số.

### Phải chốt trước khi code

- Rating scale (0–3 hoặc 0–4)
- Interval sequence
- Reset/lapse behavior
- Same-day review behavior
- Timezone / day boundary
- Maximum interval
- Due-date rounding

### Test matrix tối thiểu (12 case)

| # | Case |
|---|------|
| 1 | Từ mới → trả lời đúng |
| 2 | Từ mới → trả lời sai |
| 3 | Review đúng liên tiếp (interval tăng dần) |
| 4 | Lapse sau chuỗi đúng (interval reset) |
| 5 | Review sớm (trước nextReview) |
| 6 | Review trễ (sau nextReview) |
| 7 | Boundary trước/sau nửa đêm |
| 8 | Timezone / DST |
| 9 | Maximum interval (không vượt quá) |
| 10 | Không mutate input object |
| 11 | Cùng input → cùng output (deterministic) |
| 12 | Persist rồi reload → lịch không đổi |

---

## After Phase 1 — những gì tồn tại / chưa tồn tại

### Tồn tại
- Cấu trúc feature-first, feature `study/` có đủ 4 lớp
- Dependency direction đúng
- `srs_scheduler` thuần Dart, test được không cần `pumpWidget`
- Repository abstraction: UI không biết dữ liệu đến từ đâu
- Provider injection + override cho test

### Chưa tồn tại (đúng ý đồ)
- `core/db/` — sẽ tạo ở Phase 2
- `features/deck/`, `features/settings/` — chưa có code thật
- Drift, freezed, go_router, google_fonts — không có trong pubspec.yaml

---

## After Phase 2 — những gì thay đổi

| File | Phase 1 | Phase 2 | Lý do |
|------|---------|---------|-------|
| `pubspec.yaml` | flutter + riverpod | +drift +drift_flutter | Persistence infrastructure |
| `core/providers.dart` | placeholder | +appDatabaseProvider | Mở DB thật |
| `core/db/tables.dart` | — | NEW | Schema |
| `core/db/app_database.dart` | — | NEW | DB + migration |
| `study/data/fake_progress_repository.dart` | Map in-memory | DELETE | Thay bằng Drift |
| `study/data/drift_progress_repository.dart` | — | NEW | Query + mapper |
| `study/application/providers.dart` | Fake repo | Drift repo | Chuyển implementation |

### Không thay đổi (12 file)
`main.dart`, `app.dart`, `analysis_options.yaml`, `core/constants.dart`, toàn bộ `domain/` (4 file), `session_controller.dart`, toàn bộ `presentation/` (3 file).

---

## Thứ tự thực hiện trong mỗi phase

### Phase 1

1. Tạo `pubspec.yaml` + `analysis_options.yaml`.
2. Tạo `main.dart` + `app.dart` — chạy được app trắng.
3. Tạo domain model: `study_card.dart`, `word_progress.dart`.
4. Tạo `srs_scheduler.dart` + **viết test trước** (test matrix ≥ 5 case).
5. Tạo `progress_repository.dart` (interface).
6. Tạo `fake_progress_repository.dart`.
7. Tạo `session_controller.dart` + `providers.dart`.
8. Tạo presentation: `memo_screen.dart`, `word_card.dart`, `control_bar.dart`.
9. Verify dependency direction.
10. Verify flow end-to-end.

### Phase 2

1. Thêm drift dependencies vào `pubspec.yaml`.
2. Tạo `core/db/tables.dart`.
3. Tạo `core/db/app_database.dart` (schema v1, migration strategy).
4. Chạy `build_runner` — verify generated code.
5. **Viết migration test trước** (mở DB version cũ, migrate, verify).
6. **Viết repository test** (insert vocab, insert progress, join, read).
7. Tạo `drift_progress_repository.dart`.
8. Sửa `application/providers.dart` sang `DriftProgressRepository`.
9. Xóa `fake_progress_repository.dart`.
10. Verify: UI không import DB, session_controller không bị sửa.
11. Manual verify: restart app → data không mất.
12. Verify tất cả exit criteria Phase 1 vẫn đúng.
