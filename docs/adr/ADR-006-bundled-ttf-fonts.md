# ADR-006: Bundled TTF font trong ứng dụng

Status: Accepted

## Context

Voca cần font hiển thị nhất quán, không phụ thuộc tải mạng lúc runtime, và tránh thêm gói ngoài không nằm trong baseline stack (PLAN.md §2, §4).

## Decision

Dùng font TTF bundle trực tiếp trong ứng dụng (assets), khai báo qua cấu hình font chuẩn của Flutter. Không dùng `google_fonts` (gói tải font động) trong kiến trúc khởi điểm.

## Consequences

- Font hiển thị ổn định, không phụ thuộc mạng, không rủi ro tải chậm/fail.
- Tăng kích thước bundle app theo số font/weight nhúng — cần chọn lọc font cần thiết.
- Nếu sau này cần nhiều font/style động, phải xem lại quyết định này qua ADR mới.
