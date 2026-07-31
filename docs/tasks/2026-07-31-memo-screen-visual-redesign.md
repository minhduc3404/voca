# Task Contract — Redesign UI màn Memo theo Claude Design mockup "Voca Memo"

Điền theo `docs/templates/task-contract.md` (PLAN.md §14.3).

---

## Mục tiêu

Áp dụng lại giao diện (màu sắc, typography, bố cục) của mockup tĩnh
`Voca Memo - Memo Screen.dc.html` (Claude Design) lên toàn bộ flow học hiện có
(`MemoScreen` + trạng thái "Đã lưu!" + trạng thái hoàn thành), **không đổi
domain/persistence contract**. Bổ sung 1 tính năng tương tác nhỏ được chủ dự
án xác nhận riêng: nút ⏮/⏸/⏭ trong mockup → điều khiển tốc độ đếm ngược +
tạm dừng của chế độ rảnh tay đã có sẵn (không phải điều hướng lùi/bỏ qua thẻ
— domain không hỗ trợ việc đó).

## Phạm vi file

- **EDIT**: `lib/app/theme/app_theme.dart` (bảng màu dark theo mockup, thêm
  `AppColors`), `lib/app/app.dart` (khoá `themeMode: ThemeMode.dark` — app chỉ
  có 1 màn, URD của mockup chỉ định dark theme cố định, không theo hệ thống),
  `lib/features/study/presentation/memo_screen.dart` (bố cục app bar/progress
  bar/control bar theo mockup + pause/speed control, restyle trạng thái
  "Đã lưu!"/hoàn thành), `lib/features/study/presentation/widgets/word_card.dart`
  (restyle theo mockup: phonetic mono, term lớn, nghĩa màu xanh, ví dụ in
  nghiêng), `lib/features/study/presentation/widgets/remember_button.dart`
  (restyle nút "Đã nhớ" theo mockup — pill, icon check, glow).
- **NEW**: `test/features/study/presentation/memo_screen_pause_speed_test.dart`
  (test cho pause/resume + đổi tốc độ).
- Không đụng `domain/`, `data/`, `session_controller.dart`, schema, ARB keys
  dùng chung (chỉ thêm key cục bộ cho tooltip nếu cần), điều hướng cấp app.

## Đầu ra mong đợi

- Màu nền `#10131A`, accent `#6C8CFF`, các màu phụ (`#9FB0D6` cho nghĩa, chữ
  mờ cho ví dụ/phonetic) áp cho toàn bộ màn Memo + các trạng thái con.
- Bố cục thẻ từ: phonetic (monospace) → term (bold lớn) → nghĩa → ví dụ in
  nghiêng, căn giữa, có hiệu ứng fade nhẹ khi đổi thẻ.
- App bar dạng "X / Y" + "còn N từ" (tính từ `session.position`/`session.total`
  đã có sẵn, không cần field mới) + progress bar mảnh theo mockup.
- Control bar: ⏮ (giảm tốc) / ⏸ (tạm dừng ↔ ▶ tiếp tục) / ⏭ (tăng tốc) +
  nút "Đã nhớ" lớn, giữ nguyên text/behaviour hiện có.
- Font: giữ `NotoSans` đã bundle (ADR-006 cấm tải font CDN động; sandbox này
  không có quyền mạng tới Google Fonts để vendor `Nunito`/`JetBrains Mono`
  mới) — dùng `NotoSans` cho chữ thường, alias `monospace` hệ thống cho
  phonetic để giữ cảm giác monospace của mockup. Ghi nhận là sai khác đã biết,
  có thể vendor font đúng sau nếu có quyền mạng.
- Icon theo đúng ADR-009: vendor thủ công SVG duotone từ Reicon vào
  `assets/icons/<kebab-case>.svg`, render qua `flutter_svg` (`AppIcon`
  widget mới ở `lib/app/theme/app_icon.dart`, tô 1 màu bằng
  `ColorFilter.mode(color, BlendMode.srcIn)` để giữ hiệu ứng 2 tầng opacity
  gốc của icon duotone). Thay luôn `Icons.volume_up` cũ trong `word_card.dart`
  (vốn đã vi phạm ADR-009 từ task TTS trước) để nhất quán toàn màn hình.
  8 icon: `check-circle`, `slider-vertical`, `pause`, `play`, `skip-prev`,
  `skip-next`, `volume-up`, `confetti`.
  **Nguồn dữ liệu:** `reicon.dev` (domain) không nằm trong network allowlist
  của sandbox này (`host_not_allowed`) nên không tải trực tiếp được; thay
  vào đó lấy path data y hệt từ chính source code mã nguồn mở của trang
  (`github.com/dqev/reicon`, MIT License, `data/icon-duotone.json`) — nội
  dung SVG giống hệt những gì `reicon.dev/icons?weight=duotone` cung cấp,
  chỉ khác kênh tải. Cần audit lại nếu về sau có quyền mạng trực tiếp tới
  `reicon.dev`.

## Ràng buộc kiến trúc

- Toàn bộ thay đổi nằm trong `presentation/` + `app/theme/` (không phải
  `data`/`domain`) — `presentation` vẫn không import `data` trực tiếp.
- Pause/tốc độ là state cục bộ trong `_SessionBodyState` (widget state),
  không đẩy xuống `application`/`domain` — không đổi `StudySessionState`,
  không đổi `SessionController`, không đổi cách gọi `submitAnswer`.
- Nút "cài đặt" (icon phải trên mockup) không có màn đích thật trong app này
  — hiện chỉ hiện `SnackBar` "chưa khả dụng", không tạo route/domain mới
  (tránh thêm điều hướng cấp ứng dụng ngoài phạm vi task).
- Không đổi ARB key `appTitle` (đang dùng chung). Không thêm key ARB mới cho
  task này vì toàn bộ text còn lại đã hardcode tiếng Việt từ trước (theo
  đúng pattern hiện có trong `memo_screen.dart`/`remember_button.dart`) —
  nhất quán, không lẫn 1 phần i18n 1 phần hardcode.

## Tiêu chí hoàn tất

- Test cũ trong `memo_screen_test.dart`/`word_card_test.dart` vẫn pass không
  sửa assertion (chỉ cho phép sửa nếu chúng test chi tiết trình bày cụ thể bị
  đổi có chủ đích, ví dụ format app bar).
- Test mới cho pause/speed pass.
- `dart analyze`/`flutter test` sạch — **lưu ý:** sandbox thực hiện task này
  không có Flutter SDK/quyền mạng để cài SDK, nên không tự chạy được
  `flutter analyze`/`flutter test` — cần chủ dự án chạy lại locally trước
  khi merge.
- Không phá dependency direction, không import vòng.

---

## Definition of Ready — đã tick

- [x] Requirement rõ: xem chat handoff `chats/chat1.md` trong bundle Claude
      Design + xác nhận trực tiếp từ chủ dự án về hành vi ⏮/⏸/⏭ và phạm vi
      (restyle toàn bộ study flow).
- [x] Miền ảnh hưởng: `presentation/` + `app/theme/` của feature `study` duy
      nhất (app hiện chỉ có 1 feature/1 màn).
- [x] Không đụng approval zone (domain contract, schema, điều hướng cấp app,
      ARB key dùng chung).
- [x] Tiêu chí hoàn tất đo được (test list ở trên).

## Hoàn tất — 2026-07-31

Đã áp màu/typography/bố cục mockup lên `MemoScreen`/`WordCard`/
`RememberButton` + trạng thái "Đã lưu!"/hoàn thành. Thêm pause (⏸) +
đổi tốc độ (⏮/⏭, 0.5x–2.0x, 6 nấc, mặc định 1.0x) cho chế độ rảnh tay hiện
có, dựa trên `AnimationController` (thay `TweenAnimationBuilder`) để có thể
`stop()`/`animateTo()` được — tại tốc độ mặc định + không tạm dừng, lịch
phát TTS (2s/6s) và auto-advance (10s) giống hệt bản gốc (test cũ không
sửa assertion). Icon chuyển hết sang Reicon duotone vendor thủ công theo
ADR-009 (xem ghi chú nguồn dữ liệu ở trên) — đổi 1 assertion trong
`word_card_test.dart` (`find.byIcon(Icons.volume_up)` → `find.byKey(...)`)
vì icon giờ là SVG, không còn `IconData`. 2 test mới cho pause/tốc độ ở
`test/features/study/presentation/memo_screen_pause_speed_test.dart`.

- [x] Test cũ giữ nguyên assertion (trừ 1 chỗ đổi có chủ đích, ghi rõ ở trên).
- [x] Test mới cho pause/speed.
- [ ] **Chưa chạy được** `dart analyze`/`flutter test` trong sandbox này —
      không có Flutter SDK cài sẵn và không có quyền mạng tới
      `storage.googleapis.com`/CDN Flutter để cài (đã thử). Cần chủ dự án
      chạy lại locally trước khi merge — đặc biệt review kỹ phần
      `_SessionBodyState` (logic `AnimationController` mới, 2 chỗ từng có
      lỗi kiểu `num`/`double` do `.clamp()` đã tự phát hiện và sửa khi đọc
      lại code, nhưng không có cách verify bằng compiler thật).
- [x] Không phá dependency direction, không import vòng (chỉ thêm import
      `app/theme/*` vào `presentation/`, không đụng `data`/`domain`).
