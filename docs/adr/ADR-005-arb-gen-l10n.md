# ADR-005: ARB + gen_l10n cho localization

Status: Accepted

## Context

Voca là app học từ vựng cần đa ngôn ngữ, với `vi` là locale gốc/template arb và `en` là bản dịch fallback. Cần cơ chế localization chuẩn của Flutter, không thêm framework ngoài (PLAN.md §2, §4).

## Decision

Dùng `ARB` + `gen_l10n` (công cụ chuẩn của Flutter) cho localization, đặt trong `app/l10n/`. Localization keys dùng chung là approval zone — cần ký duyệt trước khi thay đổi (§14.2). Không hardcode text ở nơi đã có key sẵn (Phase 4 exit criteria, §15).

## Consequences

- Localization tích hợp trực tiếp vào Flutter build, không cần thêm gói ngoài.
- Domain layer không được import generated localization (§6.3) — tránh rò rỉ trình bày vào business logic.
- Thay đổi key dùng chung phải qua review vì ảnh hưởng nhiều feature.
