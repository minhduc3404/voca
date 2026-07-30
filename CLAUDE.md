# Voca — quy tắc kiến trúc cho AI agent

Kiến trúc đầy đủ: xem PLAN.md. ADR: xem docs/adr/. Task contract: xem docs/templates/task-contract.md.

App: `voca_app`, package id `com.voca.remember`, Android + iOS. ARB gốc: `vi`, fallback: `en`.

## 1. Hướng phụ thuộc (bắt buộc, không ngoại lệ)

```
presentation → application → domain ← data
```

`domain` không phụ thuộc bất kỳ layer nào khác. `data` chỉ phụ thuộc `domain` (để implement contract). `presentation` không import `data` trực tiếp — luôn đi qua `application`. `core/` không chứa business logic của feature (§5, §6).

## 2. Bảng import bị cấm theo layer

| Layer | Cấm import |
|---|---|
| `presentation` | `data` (mọi thứ), repository implementation, SQL/schema, storage implementation, domain logic thuần khi đã có use case |
| `application` | `package:flutter/*` (widget), `Navigator` trực tiếp, Drift table/query, `package:shared_preferences/*` trực tiếp |
| `domain` | `package:flutter/*`, `package:flutter_riverpod/*`, `package:drift/*`, `package:shared_preferences/*`, `Navigator`, generated localization |
| `data` | widget, screen, UI controller, business rule thuần (không đẩy nghiệp vụ xuống data) |

Vi phạm bảng trên = fail review, không merge (§6, §14.6).

## 3. Riverpod 3

Chỉ dùng `Notifier` / `AsyncNotifier`. Không dùng transitional/legacy `StateNotifier`-style pattern trong code mới. Provider đặt tên mô tả chức năng rõ ràng. Notifier không chứa business logic — chỉ điều phối và gọi use case (§7).

## 4. Persistence

- Drift là nguồn chính cho dữ liệu bền vững; schema/versioning/migration định nghĩa từ đầu, migration phải test được. Query/transaction/mapping chỉ nằm trong `data/`, UI không được biết chi tiết bảng (§8).
- `shared_preferences` chỉ cho cấu hình nhẹ/UI flag, không cho dữ liệu domain hay dữ liệu cần migration cấu trúc. Luôn bọc qua abstraction trong `data/` hoặc service riêng (§9).

## 5. Điều hướng

Baseline: `Navigator.push` / `Navigator.pop` only. Không đưa `go_router` vào baseline (§10).

## 6. `core/` — two-feature rule

Một module chỉ vào `core/` khi đã chứng minh dùng chung cho ≥ 2 feature thật sự (không phải giả định tương lai). Chưa đạt thì giữ ở feature cụ thể hoặc `app/` (§12).

## 7. Barrel files

Không tạo barrel file rộng. Barrel hẹp chỉ chấp nhận nếu có lý do rõ, phạm vi nhỏ, không che khuất biên giới domain/data/presentation (§13).

## 8. Task contract bắt buộc

Mọi task không tầm thường phải điền `docs/templates/task-contract.md` (mục tiêu, phạm vi file, đầu ra mong đợi, ràng buộc kiến trúc, tiêu chí hoàn tất) trước khi bắt đầu. Không nhận task kiểu "làm đẹp"/"dọn dẹp"/"cải thiện tổng thể" không có tiêu chí đo được (§14.3).

## 9. Approval zones — cần con người ký duyệt trước khi đổi

- Domain contract
- Persistence schema/migration
- Điều hướng cấp ứng dụng
- Localization keys dùng chung
- Bất kỳ quyết định ảnh hưởng nhiều feature

AI không tự thực hiện thay đổi trong các vùng này nếu task contract chưa được duyệt (§14.2).

## 10. Definition of Done

- [ ] Code đúng kiến trúc, không phá dependency direction
- [ ] Test liên quan đã có và pass
- [ ] Không import vòng hoặc import trái tầng
- [ ] Không thêm folder/file rỗng
- [ ] ADR/tài liệu cần thiết đã cập nhật

(§14.5, đầy đủ hơn xem PLAN.md và task-contract.md)
