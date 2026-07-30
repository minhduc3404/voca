# ADR-003: shared_preferences chỉ cho cấu hình nhẹ

Status: Accepted

## Context

Voca cần một nơi lưu cấu hình người dùng/UI flag không mang tính nghiệp vụ lõi, tách biệt khỏi dữ liệu domain chính đã có Drift đảm nhiệm (PLAN.md §2, §9).

## Decision

`shared_preferences` chỉ dùng cho dữ liệu nhẹ: cấu hình người dùng, lựa chọn UI, cờ tính năng cục bộ, trạng thái không mang tính nghiệp vụ lõi. Không dùng để lưu dữ liệu domain chính, dữ liệu cần query phức tạp, hoặc trạng thái cần migration có tính cấu trúc cao. Truy cập preference phải bọc qua abstraction trong `data/` hoặc service riêng, không rải lệnh đọc/ghi khắp app.

## Consequences

- Ranh giới rõ giữa dữ liệu domain (Drift) và cấu hình nhẹ (shared_preferences).
- Không có logic domain ẩn trong preference key.
- Mọi truy cập preference đi qua một điểm abstraction duy nhất, dễ thay thế/test.
