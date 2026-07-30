# ADR-010: Chốt thuật toán SRS — SM-2 cổ điển (Anki-style)

Status: Accepted

## Context

`PLAN-PHASE-1-2.md` liệt 7 quyết định phải chốt trước khi code `srs_scheduler.dart`: rating scale, interval sequence, reset/lapse behavior, same-day review behavior, timezone/day boundary, maximum interval, due-date rounding. ADR-008 chỉ quy định quy trình (bắt buộc có test matrix cho miền critical), chưa quyết định thuật toán cụ thể. Đây là domain contract — approval zone theo PLAN.md §14.2 / CLAUDE.md §9. Con người đã chọn hướng SM-2 cổ điển (kiểu Anki) khi được hỏi trực tiếp.

## Decision

### Rating scale

4 mức, index 0–3: `0 = Again`, `1 = Hard`, `2 = Good`, `3 = Easy`. Khớp với 4 nút đã định nghĩa ở `control_bar.dart`.

### Ease factor

- Khởi tạo: `2.5`.
- Sàn: `1.3` (không giảm dưới mức này). Không có trần.
- Điều chỉnh mỗi lần trả lời: `Again: -0.20`, `Hard: -0.15`, `Good: +0.0`, `Easy: +0.15`.

### Interval sequence

Thẻ mới (`reps == 0`):
- `Again`: interval = 1 ngày, `reps` giữ 0, `lapses += 1`.
- `Hard`: interval = 1 ngày, `reps = 1`.
- `Good`: interval = 1 ngày, `reps = 1`.
- `Easy`: interval = 4 ngày, `reps = 1`.

Thẻ đã học (`reps >= 1`):
- `Again`: interval = 1 ngày, `reps = 0`, `lapses += 1` (lapse — reset về learning).
- `Hard`: interval = `max(round(interval_cũ * 1.2), interval_cũ + 1)`.
- `Good`: interval = `round(interval_cũ * easeFactor)`.
- `Easy`: interval = `round(interval_cũ * easeFactor * 1.3)`.

Trong 3 công thức trên, `easeFactor` là ease factor **trước khi điều chỉnh** ở mục "Ease factor" (tức giá trị đang lưu trong `WordProgress` hiện tại). Ease factor mới (sau điều chỉnh) chỉ được lưu lại để dùng cho lần ôn **kế tiếp**, không hồi tố vào interval vừa tính — đúng quy ước SM-2 gốc.

### Maximum interval

Trần cứng `365` ngày — interval tính ra vượt trần thì cắt về 365.

### Same-day / review sớm (trước `nextReview`)

Không có logic đặc biệt trong domain: `srs_scheduler` luôn tính theo `rating` + `now` được truyền vào, không tự so sánh `now` với `nextReview` cũ để "phạt" hay bỏ qua review sớm. Quyết định có cho phép review sớm hay không là của tầng gọi (application/data), không phải domain.

### Timezone / day boundary / due-date rounding

- `nextReview = now.add(Duration(days: interval))` — cộng thẳng theo `Duration`, không quy tròn về đầu ngày, không có khái niệm "ngày lịch" (calendar day) trong domain.
- "Due" được xác định bằng so sánh `DateTime` đầy đủ (`!now.isBefore(nextReview)`), không cắt phần giờ/phút.
- Domain không tự xử lý timezone/DST: `DateTime` truyền vào scheduler được coi là đã ở đúng mốc caller muốn; scheduler chỉ cộng `Duration`. Việc chọn local hay UTC là quyết định của tầng gọi, phải ghi rõ trong doc-comment của `progress_repository.dart`.

## Rationale

- SM-2 cổ điển đã kiểm chứng rộng rãi (Anki), dễ giải thích, đủ đơn giản để test thuần Dart không cần calendar/timezone logic phức tạp.
- Bỏ "learning steps" tính bằng phút (như Anki thật dùng cho thẻ mới) để giữ granularity ở cấp ngày, khớp `ProgressTable.interval: int` (đơn vị ngày) đã định nghĩa trong PLAN-PHASE-1-2.md.
- Cộng thẳng `Duration` thay vì tính theo "ngày lịch" là lựa chọn đơn giản hóa có chủ đích, né toàn bộ nhóm vấn đề timezone/DST/ranh giới nửa đêm ở Phase 1–2.

## Consequences

- `srs_scheduler_test.dart` viết đủ 12 case trong test matrix của PLAN-PHASE-1-2.md dựa trên các con số ở trên.
- Case 7 (boundary nửa đêm) và case 8 (timezone/DST) trở thành test xác nhận "không có side-effect theo ngày lịch/timezone" (scheduler cộng `Duration` thuần), không phải test một cơ chế calendar-day phức tạp — vì thiết kế này chủ động không có cơ chế đó.
- Nếu sau này sản phẩm cần "học đúng theo ngày lịch địa phương của người dùng" (vd thẻ due hôm qua vẫn hiện due đến hết hôm nay theo giờ local), đó là thay đổi domain contract mới — cần ADR riêng và qua lại approval zone.
