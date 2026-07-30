# ADR-011: Thêm learning steps (phút) vào SRS — bổ sung ADR-010

Status: Accepted

## Context

Mockup UI (2026-07-30) hiển thị nhãn thời gian trên nút rating kiểu Anki thật, vd "Again → 10 phút" cho thẻ đang học. ADR-010 (SM-2 cổ điển đã implement ở Phase 1) chỉ tính theo đơn vị NGÀY, không có khái niệm "learning step" trong ngày — một thẻ mới trả lời đúng 1 lần là coi như đã "học", interval tối thiểu luôn là 1 ngày. Đây là domain contract — approval zone, con người đã chọn hướng bổ sung learning steps khi được hỏi trực tiếp (2026-07-30).

## Decision

### Learning steps (dùng chung cho cả thẻ mới VÀ thẻ relearning sau lapse)

`[1, 10]` phút — một mảng bậc thang duy nhất, KHÔNG tách learning steps (thẻ mới) và relearning steps (sau lapse) thành 2 mảng khác nhau như Anki thật, để tránh phải thêm field thứ 2 (`isRelearning`) vào `WordProgress`/schema. Đơn giản hoá có chủ đích — đổi lại là cùng 1 field `learningStep` đủ dùng cho cả 2 tình huống.

### Field mới: `WordProgress.learningStep` (`int?`)

- `null` → thẻ đã "graduate", ở review phase — `interval` có nghĩa là SỐ NGÀY như ADR-010 cũ, toàn bộ công thức SM-2 (ease factor, interval theo ngày, max 365 ngày) giữ nguyên không đổi.
- `0, 1, ...` → thẻ đang ở learning/relearning phase — index vào mảng `learningSteps` (đơn vị phút). `interval` (ngày) KHÔNG được dùng trong giai đoạn này (giữ nguyên giá trị cũ, không có ý nghĩa).

### Hành vi trong learning/relearning phase (`learningStep != null`)

- `Again`: `learningStep = 0` (quay lại bước đầu), delay = `learningSteps[0]` = 1 phút.
- `Hard`: `learningStep` giữ nguyên (lặp lại bước hiện tại), delay = `learningSteps[learningStep]`.
- `Good`: sang bước kế tiếp nếu còn (`learningStep += 1`, delay = `learningSteps[bước mới]`); nếu đã ở bước cuối → **graduate**: `learningStep = null`, `interval = 1 ngày`, `reps = 1`.
- `Easy`: **graduate ngay lập tức** bất kể đang ở bước nào: `learningStep = null`, `interval = 4 ngày`, `reps = 1`.
- `easeFactor` **không đổi** trong suốt learning/relearning phase (chỉ áp dụng công thức ease ở review phase, đúng hành vi Anki thật).
- `lapses` **không tăng** khi Again trong learning phase (không phải lapse thật — thẻ chưa từng graduate) — `reps` giữ nguyên 0.

### Hành vi trong review phase (`learningStep == null`) — giữ nguyên ADR-010, trừ 1 thay đổi

- `Hard`/`Good`/`Easy`: **không đổi** — công thức SM-2 theo ngày y hệt ADR-010.
- `Again` (**thay đổi**): không còn reset thẳng về `interval = 1 ngày` như ADR-010 cũ. Thay vào đó là **lapse thật** → vào lại relearning: `learningStep = 0`, delay = `learningSteps[0]` = 1 phút, `lapses += 1`, `reps = 0`, `easeFactor` áp dụng delta `-0.20` như cũ (giữ nguyên phần ease).

### `WordProgress.initial()`

Thẻ mới bắt đầu ở learning phase: `learningStep = 0`, `interval = 0` (chưa có ý nghĩa), `easeFactor = 2.5`, `reps = 0`, `lapses = 0`, `nextReview = now` (due ngay, giữ nguyên hành vi cũ).

### Copy-with và null-explicit

`WordProgress.copyWith` dùng pattern `field ?? this.field` — KHÔNG set được `learningStep`/`lastReview` về `null` một cách tường minh. `srs_scheduler.dart` dựng `WordProgress(...)` trực tiếp qua constructor đầy đủ ở các nhánh cần null hoá `learningStep` (graduate, lapse), không dùng `copyWith` cho các nhánh đó.

## Rationale

- Khớp trải nghiệm Anki thật mà mockup mô tả, vẫn giữ được toàn bộ công thức SM-2 review-phase đã test kỹ ở ADR-010 — chỉ thêm 1 giai đoạn "khởi động" trước khi vào review phase.
- Dùng chung 1 mảng learning steps cho cả learning lẫn relearning giảm 1 field, giảm độ phức tạp state — đánh đổi chấp nhận được vì app còn nhỏ, thẻ mới và thẻ vừa lapse có delay khởi động giống nhau không phải vấn đề lớn về mặt sư phạm.

## Consequences

- **Schema thay đổi** — `ProgressTable` cần thêm cột `learningStep` (nullable int). Đây là schema change ĐẦU TIÊN thật sự kể từ v1 → cơ hội đầu tiên viết migration test thật (mở DB v1 cũ, migrate lên v2, verify dữ liệu cũ vẫn đọc được với `learningStep` mặc định hợp lý) — trước đây chỉ test được `onCreate`, chưa test được `onUpgrade`.
- Toàn bộ test matrix `srs_scheduler_test.dart` (12 case, ADR-010) phải viết lại — hành vi "thẻ mới trả lời đúng 1 lần" không còn graduate ngay lập tức nữa.
- UI preview label trên nút rating (mockup) cần `WordProgress` hiện tại của thẻ để tính trước 4 kết quả — `StudySessionState`/`SessionController` cần expose thêm `currentProgress`, trước đây chỉ lưu trong scope của `submitAnswer()`.
