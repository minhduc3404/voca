# ADR-004: Navigator push/pop làm baseline navigation

Status: Accepted

## Context

Voca cần một chiến lược điều hướng khởi điểm, đơn giản, không thêm phụ thuộc build tool khi số màn hình còn nhỏ và chưa có nhu cầu deep link/route restoration (PLAN.md §2, §10).

## Decision

Dùng `Navigator.push` / `Navigator.pop` làm chuẩn khởi điểm. Không đưa `go_router` vào baseline. Xem xét lại chiến lược nếu xuất hiện: deep link cần route declaration trung tâm, nhiều nhánh điều hướng theo auth/onboarding/phân quyền phức tạp, số màn hình/stack pattern tăng đến mức giảm rõ ràng, hoặc cần route restoration/nested navigation/redirection có cấu trúc.

## Consequences

- Không có route table trung tâm ở baseline — đơn giản, ít phụ thuộc.
- Cần theo dõi các tín hiệu ở §10 để biết khi nào phải re-đánh giá và viết ADR mới nếu chuyển sang go_router.
- Điều hướng cấp ứng dụng là approval zone, mọi thay đổi cần ký duyệt (§14.2).
