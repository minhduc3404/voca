# ADR-007: Feature-first, tối đa 4 lớp, không barrel rộng

Status: Accepted

## Context

Voca cần cấu trúc thư mục rõ ràng để giữ hướng phụ thuộc (`presentation → application → domain ← data`) dễ review và dễ mở rộng theo feature, tránh core/ trở thành bãi chứa logic nghiệp vụ (PLAN.md §3, §4, §12, §13).

## Decision

Tổ chức theo feature-first: mỗi `features/<feature_name>/` có tối đa 4 lớp — `presentation`, `application`, `domain`, `data`. `app/` chứa ghép ứng dụng/bootstrap/routing/l10n/theme. `core/` chỉ nhận module đã chứng minh dùng chung cho ≥ 2 feature (two-feature rule, §12) — không thêm vì giả định tương lai. Không tạo folder rỗng chỉ để dự phòng. Không tạo barrel file rộng; barrel hẹp chỉ khi có lý do rõ và không che khuất biên giới layer (§13).

## Consequences

- Cấu trúc dự đoán được, dễ định vị code theo feature.
- `core/` giữ nhỏ và có trách nhiệm rõ, giảm rủi ro trở thành dependency dùng chung mù mờ.
- Không có shortcut import qua barrel rộng — import phải tường minh theo file/module.
