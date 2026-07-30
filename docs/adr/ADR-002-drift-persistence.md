# ADR-002: Drift + drift_flutter cho persistence cục bộ

Status: Accepted

## Context

Voca cần lưu trữ dữ liệu bền vững cục bộ (từ vựng, tiến trình học...) với khả năng query phức tạp và migration có kiểm soát (PLAN.md §2, §8).

## Decision

Dùng `Drift` làm nguồn chính cho persistence cục bộ; `drift_flutter` chỉ là gói hỗ trợ tích hợp runtime Flutter cho kết nối, không thay thế việc thiết kế schema. Schema, versioning, migration path phải định nghĩa ngay từ đầu. Tăng version phải có kiểm soát, có migration code, và test khả năng đọc dữ liệu cũ. Query phức tạp, transaction, mapping chỉ nằm ở `data/`; UI không gọi trực tiếp query hay biết chi tiết bảng.

## Consequences

- Có schema versioning rõ ràng ngay từ Phase 2.
- Mọi migration bắt buộc có test — không merge nếu migration chưa test (§14.6).
- UI tách biệt hoàn toàn khỏi chi tiết DB, giảm rủi ro rò rỉ nghiệp vụ xuống tầng data.
