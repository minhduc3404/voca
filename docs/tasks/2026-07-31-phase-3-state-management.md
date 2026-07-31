# Task Contract — Phase 3: State và luồng chính (Riverpod 3)

Điền theo `docs/templates/task-contract.md` (PLAN.md §14.3). **NHÁP — chưa duyệt**, cần chốt lại phạm vi trước khi bắt đầu implement (xem phần "Cần quyết định trước khi duyệt" cuối file).

Theo PLAN.md §15, Phase 3 = "Chuyển luồng chính sang Riverpod 3 với `Notifier`/`AsyncNotifier`, chuẩn hóa error/loading state." Exit criteria gốc: "state management nhất quán, không còn style cũ lẫn lộn trong luồng đã chuyển."

---

## Audit hiện trạng (trước khi viết task) — 2026-07-31

Đã grep toàn bộ `lib/`:

- **Không có** `StateNotifier`/`ChangeNotifier` legacy nào — 100% state đã dùng `Notifier`/`AsyncNotifier` từ Phase 1 trở đi (`SessionController`, `TtsSettingsController`).
- `_SessionBodyState` (`memo_screen.dart`) dùng `setState` — nhưng chỉ cho state UI thuần túy cục bộ (timer, animation, `_showSaved`, `_speedIndex`, `_isPaused`), không chứa business logic. Đây **đúng** convention Riverpod (không phải mọi state đều cần là Notifier), không phải vi phạm §3.
- 3 nơi dùng `AsyncValue.when()` (`memo_screen.dart`, `tts_settings_screen.dart` ×2) — mỗi nơi tự viết loading/error widget riêng, không dùng chung pattern. Đây là phần "chưa chuẩn hóa" thật sự còn lại.

**Kết luận: phần "chuyển sang Notifier/AsyncNotifier" của Phase 3 coi như đã đạt từ trước (làm lồng trong Phase 1/2 + các task sau đó). Phạm vi Phase 3 còn lại chỉ là chuẩn hóa cách hiển thị loading/error.**

## Mục tiêu

Thống nhất cách hiển thị trạng thái loading/error cho mọi nơi dùng `AsyncValue.when()` trong `features/study/presentation/` — cùng 1 loading indicator, cùng 1 dạng thông báo lỗi (có thể kèm nút thử lại), thay vì mỗi màn tự viết riêng.

## Phạm vi file

- **NEW**: `lib/features/study/presentation/widgets/async_state_view.dart` — widget dùng chung, nhận `AsyncValue<T>` + `builder` cho data, tự render loading/error thống nhất.
- **EDIT**: `lib/features/study/presentation/memo_screen.dart`, `lib/features/study/presentation/tts_settings_screen.dart` (thay `.when(...)` thủ công bằng widget mới).
- Không đụng `domain/`, `application/`, schema, navigation cấp app.

## Đầu ra mong đợi

Widget `AsyncStateView<T>` dùng lại được ở cả 3 chỗ hiện có; UI loading/error đồng nhất về màu sắc, spacing, cách hiển thị message.

## Ràng buộc kiến trúc

- Chỉ nằm trong `features/study/presentation/widgets/` — **KHÔNG** đặt vào `core/` vì mới chỉ có 1 feature (`study/`) dùng, vi phạm two-feature rule (CLAUDE.md §6) nếu đặt sai chỗ. Khi có feature thứ 2 cần pattern này mới cân nhắc promote lên `core/`.
- Widget chỉ nhận `AsyncValue` + callback hiển thị — không chứa business logic, không import `application/`/`data/`.

## Tiêu chí hoàn tất

- `dart analyze` sạch, `flutter test` pass (test mới cho `AsyncStateView` + cập nhật test 2 màn hình đã đổi).
- Không phá `import_lint`.
- Toàn bộ test hiện có (40 case) vẫn pass — không regression Phase 1/2.

---

## Definition of Ready — CHƯA tick, cần quyết định trước

- [ ] Requirement rõ — cần chốt: có muốn thêm nút "Thử lại" (retry) cho error state không, hay chỉ hiển thị message?
- [x] Miền ảnh hưởng đã xác định: chỉ `features/study/presentation/`.
- [ ] Đây có phải quyết định "ảnh hưởng nhiều feature" cần duyệt theo CLAUDE.md §9 không? — hiện tại chỉ 1 feature dùng nên về kỹ thuật chưa chạm approval zone, nhưng nó đặt **tiền lệ pattern** cho các feature sau này → khuyến nghị người có thẩm quyền xác nhận trước khi coi là "chuẩn chung", tránh phải đổi lại khi feature thứ 2 xuất hiện.

---

## Cần quyết định trước khi duyệt task này

1. **Có cần retry action trong error state không**, hay chỉ hiển thị thông báo lỗi tĩnh (như hiện tại)?
2. **Tên/API của widget dùng chung** có ổn không, hay muốn thiết kế khác (vd: extension method trên `AsyncValue` thay vì widget riêng)?
3. Có cần làm Phase 3 **ngay bây giờ**, hay ưu tiên Phase 4 (Localization) / Phase 5 (feature lõi) trước, vì Phase 3 hiện tại phạm vi thực tế khá nhỏ (audit cho thấy phần lớn đã đạt sẵn)?
