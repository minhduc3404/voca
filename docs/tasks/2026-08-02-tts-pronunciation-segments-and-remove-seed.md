# Task Contract — TTS pronunciation segments, timing cache và bỏ seed từ vựng hardcode

Trạng thái: **đã triển khai, đã kiểm tra — chờ người dùng tích hợp JSON catalog lên Firebase**.

## Mục tiêu

1. Thay cơ chế chia đều ký tự + timer cố định hiện tại bằng
   `pronunciationSegments` do catalog cung cấp. Mỗi segment có range trong
   `term`, text hiển thị, IPA, stress và `timingWeight`.
2. Dùng word-boundary callback của TTS để biết chính xác từ nào trong term/cụm
   từ đang đọc; lưu thời lượng quan sát được theo cấu hình giọng đọc vào cache
   local để animation segment ở các lượt sau có nhịp sát audio hơn.
3. Khi thiếu segment (từ nhập tay, catalog cũ, parse lỗi), chỉ highlight toàn
   bộ từ đang được TTS đọc; không suy đoán/chia ký tự theo số âm tiết.
4. Bỏ danh sách vocabulary seed hardcode khỏi app. Cài đặt mới không còn tự tạo
   từ mẫu; vocabulary chỉ đến từ catalog đã tải hoặc feature nhập từ trong tương
   lai.

## Schema mới — cần duyệt

### 1. JSON remote `words[]`

`pronunciationSegments` là optional để catalog cũ vẫn import được. `start` và
`end` là UTF-16 offset của Dart, `start` inclusive và `end` exclusive; vì
language hiện là `en`, range khớp trực tiếp với callback offset từ native TTS.

```jsonc
{
  "id": "travel-004",
  "term": "destination",
  "phonetic": "/ˌdes.tɪˈneɪ.ʃən/",
  "pronunciationSegments": [
    {
      "start": 0,
      "end": 3,
      "text": "des",
      "ipa": "des",
      "stress": "secondary",
      "timingWeight": 1.4
    },
    {
      "start": 3,
      "end": 5,
      "text": "ti",
      "ipa": "tɪ",
      "stress": "none",
      "timingWeight": 1.0
    },
    {
      "start": 5,
      "end": 7,
      "text": "na",
      "ipa": "neɪ",
      "stress": "primary",
      "timingWeight": 2.0
    },
    {
      "start": 7,
      "end": 11,
      "text": "tion",
      "ipa": "ʃən",
      "stress": "none",
      "timingWeight": 1.0
    }
  ]
}
```

Validation khi parse/import:

- `0 <= start < end <= term.length`.
- `term.substring(start, end) == text`.
- Segment tăng dần, không overlap; trong mỗi từ callback (`TtsWordRange`) có thể
  có 0 hoặc nhiều segment.
- `stress` chỉ là `none`, `secondary`, hoặc `primary`.
- `timingWeight > 0`; recommended: `1.0`, `1.4`, `2.0` tương ứng stress.
- Nếu bất kỳ segment nào invalid, bỏ toàn bộ segment của word đó và fallback
  highlight nguyên từ; không làm hỏng cả lần tải topic.

### 2. Core value contract

```dart
enum PronunciationStress { none, secondary, primary }

class PronunciationSegment {
  const PronunciationSegment({
    required this.position,
    required this.start,
    required this.end,
    required this.text,
    required this.ipa,
    required this.stress,
    required this.timingWeight,
  });

  final int position;
  final int start;
  final int end;
  final String text;
  final String ipa;
  final PronunciationStress stress;
  final double timingWeight;
}
```

`position` là thứ tự bền vững trong word, không suy ra từ `start` để vẫn lưu
được segment có range cách nhau bởi space/punctuation trong phrase.

### 3. Drift schema v4

```text
PronunciationSegmentsTable
  id              INTEGER PRIMARY KEY
  vocabId          INTEGER NOT NULL REFERENCES vocabulary_table(id) ON DELETE CASCADE
  position         INTEGER NOT NULL
  startOffset      INTEGER NOT NULL
  endOffset        INTEGER NOT NULL
  segmentText      TEXT NOT NULL        // SQLite: segment_text
  ipa              TEXT NOT NULL
  stress           TEXT NOT NULL        // none | secondary | primary
  timingWeight     REAL NOT NULL
  UNIQUE(vocabId, position)

TtsWordTimingCacheTable
  id              INTEGER PRIMARY KEY
  vocabId          INTEGER NOT NULL REFERENCES vocabulary_table(id) ON DELETE CASCADE
  wordStartOffset  INTEGER NOT NULL
  wordEndOffset    INTEGER NOT NULL
  voiceKey         TEXT NOT NULL        // '<default>' hoặc '<name>|<locale>'
  speechRate       REAL NOT NULL
  durationMs       INTEGER NOT NULL
  updatedAt        DATETIME NOT NULL
  UNIQUE(vocabId, wordStartOffset, wordEndOffset, voiceKey, speechRate)
```

Không dùng `shared_preferences`: cache này có dữ liệu có cấu trúc, phải có FK,
unique key, migration và cascade rõ ràng. `durationMs` đo từ callback monotonic
clock của lượt phát trước; không phải timestamp âm tiết do native TTS cung cấp.

### 4. State và fallback runtime

```text
TTS callback (text, wordStart, wordEnd)
  → xác định các PronunciationSegment có range nằm trong word range
  → cache hit: chọn active segment theo elapsed/durationMs/timingWeight
  → cache miss nhưng có segment: bắt đầu segment đầu bằng nhịp ước lượng theo
    `timingWeight`; đo duration để cache sau completion
  → cache miss không có segment: highlight nguyên từ
  → cancel/error/card đổi: clear highlight, không ghi cache dở dang
```

Với `boarding pass`, callback `0..8` chỉ chọn `board` + `ing`; callback `9..13`
chỉ chọn `pass`. Không tách phrase bằng `RegExp`.

## Phạm vi file

- **NEW** `lib/core/lexicon/pronunciation_segment.dart` — value contract trung
  lập được dùng thật bởi `vocabulary` (catalog/import) và `study` (render).
- **EDIT — approval zone (persistence)**:
  - `lib/core/db/tables.dart` — thêm bảng segment có thứ tự theo vocabulary và
    bảng cache thời lượng TTS theo vocabulary/range/cấu hình đọc.
  - `lib/core/db/app_database.dart` — schema v4, migration v3→v4.
  - `lib/core/db/app_database.g.dart` — generated sau khi thay đổi Drift.
  - `test/core/db/migration_test.dart` — migration thật từ schema v3.
- **EDIT catalog/import**:
  - `lib/features/vocabulary/domain/catalog_word.dart`
  - `lib/features/vocabulary/data/firebase_catalog_repository.dart`
  - `lib/features/vocabulary/data/drift_topic_library_repository.dart`
  - test parser/import tương ứng.
- **EDIT study/TTS**:
  - `lib/features/study/domain/study_card.dart`
  - `lib/features/study/data/drift_progress_repository.dart`
  - TTS contract/implementation và provider cần thiết.
  - application controller mới chịu trách nhiệm subscription callback, state
    highlight, timing-cache và cleanup.
  - `lib/features/study/presentation/memo_screen.dart`
  - `lib/features/study/presentation/widgets/word_card.dart`
  - test application/presentation tương ứng.
- **EDIT bỏ hardcode**:
  - `lib/core/db/seed_data.dart` — xóa nếu không còn được dùng.
  - `lib/core/db/app_database.dart` — bỏ lời gọi `seedInitialVocabulary()`.
  - `test/core/db/seed_data_test.dart` — xóa hoặc thay bằng assertion database
    mới tạo rỗng.
  - test database bị ảnh hưởng.
- **INPUT EXTERNAL, không chỉnh trong repository**: `travel.json` trên Firebase
  Storage phải được cập nhật theo schema `pronunciationSegments`; file mẫu đã
  chuẩn bị tại `/private/tmp/travel-pronunciation-segments.json`.

## Đầu ra mong đợi

- Catalog parse/import/persist được `pronunciationSegments` theo đúng range và
  thứ tự.
- Study card render segment theo dữ liệu catalog; không còn `_splitIntoChunks`
  hay timer 220 ms suy đoán.
- Phrase như `boarding pass` nhận highlight theo native callback range; segment
  thuộc đúng từ trong phrase.
- Cache timing được tạo/cập nhật từ callback, không dùng
  `shared_preferences`, và bị phân vùng khi thay voice/rate.
- Cài đặt mới có database vocabulary rỗng cho đến khi người dùng tải catalog.
- Dữ liệu vocabulary đã tồn tại trên thiết bị **không bị xóa** bởi migration;
  việc xóa dữ liệu người dùng là ngoài phạm vi và cần yêu cầu riêng.

## Ràng buộc kiến trúc

- Dependency direction bắt buộc: `presentation → application → domain ← data`.
  Presentation không được subscribe trực tiếp TTS hoặc chứa logic mapping/timing.
- `PronunciationSegment` là core value contract hợp lệ theo two-feature rule:
  `vocabulary` và `study` đều dùng thực tế. Không đặt business logic feature vào
  `core/`.
- Callback TTS chỉ là word-boundary; cache chỉ cải thiện nhịp animation, không
  được quảng bá là timestamp âm tiết chính xác.
- Segment chữ viết chỉ dùng khi catalog đã cung cấp. Không tự nội suy mapping
  IPA→grapheme từ số ký tự.
- Thay đổi `StudyCard`/TTS contract và schema Drift là approval zone; không
  implement trước khi kiến trúc này được duyệt.
- Import topic update phải thay segment trong transaction cùng vocabulary, giữ
  nguyên `VocabularyTable.id` và toàn bộ `ProgressTable`/SRS.
- Seed bị bỏ chỉ trên đường `onCreate`; migration không xóa word cũ để bảo toàn
  dữ liệu người dùng và rollback đơn giản.

## Tiêu chí hoàn tất

- Parser từ JSON mới, segment range validation, stress/weight validation và
  catalog cũ không có segments đều có test.
- Import mới/import update ghi đúng segment, không tạo trùng, giữ nguyên SRS.
- Migration v3→v4 thật pass; database mới tạo không seed vocabulary.
- Unit test cho timing cache: callback range, phrase nhiều từ, completion,
  cancellation, đổi voice/rate và cache miss.
- Widget test: segment data render đúng; fallback không segment highlight nguyên
  từ; không còn thuật toán chia đều ký tự.
- `dart analyze`, `flutter test` và target build pass.
- Architecture review xác nhận screen mỏng, cleanup subscription rõ ràng, không
  duplicate policy/cache, và hành vi lỗi/thiếu data/backward-compatible rõ ràng.

## Definition of Ready (§14.4) — phải tick hết trước khi bắt đầu

- [x] Requirement đã rõ: catalog cấp segment, TTS callback cấp word boundary,
  cache local cấp timing quan sát được.
- [x] Miền ảnh hưởng đã xác định.
- [x] Contract đầu vào/đầu ra có thể kiểm chứng.
- [x] Phụ thuộc bên ngoài đã biết: catalog Firebase phải upload JSON mới; native
  TTS không cấp phoneme boundary.
- [x] Tiêu chí hoàn tất có thể test được.
- [x] Kiến trúc, domain contract và migration schema đã được người dùng duyệt (2026-08-02).

## Definition of Done (§14.5) — phải tick hết trước khi merge

- [x] Code đúng kiến trúc
- [x] Test liên quan đã có và qua
- [x] Không phá dependency direction
- [x] Không thêm folder/file rỗng
- [x] Không tạo import vòng hoặc import trái tầng
- [x] Tài liệu task contract đã cập nhật; không cần ADR mới
