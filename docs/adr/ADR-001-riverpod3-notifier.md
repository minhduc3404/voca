# ADR-001: Riverpod 3 với Notifier/AsyncNotifier

Status: Accepted

## Context

Voca cần một cơ chế state management nhất quán cho application/presentation layer, tránh trộn lẫn nhiều phong cách quản lý state trong cùng một codebase (PLAN.md §2, §7).

## Decision

Dùng `Riverpod 3`, chuẩn hóa quanh `Notifier` và `AsyncNotifier`. Không viết kiến trúc mới theo transitional pattern cũ (kiểu `StateNotifier`). Nếu có mã kế thừa, migrate từng feature theo lớp, không trộn hai phong cách trong cùng module nếu tránh được. Provider phải có tên mô tả chức năng. Notifier chỉ điều phối và gọi use case, không chứa business logic.

## Consequences

- State quản lý nhất quán, dễ review, dễ test.
- Cần kỷ luật khi migrate code cũ để tránh trộn pattern.
- Business logic phải nằm ở domain/application, không rò rỉ vào notifier.
