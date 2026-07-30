# ADR-008: SRS contract và test matrix cho miền critical

Status: Accepted

## Context

Voca có các miền nghiệp vụ critical (ví dụ luồng SRS - spaced repetition) cần contract chặt và không cho phép "tự hiểu ngầm", vì sai sót ở đây ảnh hưởng trực tiếp đến dữ liệu học tập của người dùng (PLAN.md §11).

## Decision

SRS và các miền critical khác phải được xác định trước khi code feature tương ứng, với contract rõ về input/output, bất biến, lỗi hợp lệ, hành vi lưu trữ, hành vi hiển thị tối thiểu — mọi giả định ghi vào SRS hoặc ADR. Mỗi miền critical bắt buộc có test matrix tối thiểu: domain unit test (bất biến/rule), application test (orchestration/mapping), data test (repository/DAO/migration), widget/integration test (luồng người dùng trọng yếu).

## Consequences

- Không merge nếu luồng critical thiếu test (§14.6).
- Chi phí viết test tăng ở miền critical, đổi lại giảm rủi ro sai lệch nghiệp vụ.
- Assumption không ghi vào SRS/ADR coi như chưa được chốt, không được implement.
