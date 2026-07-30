# Task Contract Template

Copy file này cho mỗi task không tầm thường, điền đủ 5 mục trước khi bắt đầu (PLAN.md §14.3). Không nhận task kiểu "làm đẹp"/"dọn dẹp"/"cải thiện tổng thể" nếu không có tiêu chí đo được.

---

## Mục tiêu

<!-- Mô tả cụ thể, đo được. Không mơ hồ. -->

## Phạm vi file

<!-- Liệt kê chính xác file/thư mục sẽ tạo/sửa. Ngoài phạm vi này = ngoài task. -->

## Đầu ra mong đợi

<!-- Kết quả cụ thể: code, test, tài liệu/ADR nào sẽ có sau khi xong. -->

## Ràng buộc kiến trúc

<!-- Layer nào bị ảnh hưởng, hướng phụ thuộc nào phải giữ, approval zone nào bị chạm (xem CLAUDE.md §2, §9). -->

## Tiêu chí hoàn tất

<!-- Điều kiện đo được để coi task là xong (test pass, build sạch, ...). -->

---

## Definition of Ready (§14.4) — phải tick hết trước khi bắt đầu

- [ ] Requirement đã rõ
- [ ] Miền ảnh hưởng đã xác định
- [ ] Contract đầu vào/đầu ra có thể kiểm chứng
- [ ] Phụ thuộc bên ngoài đã biết
- [ ] Tiêu chí hoàn tất có thể test được

## Definition of Done (§14.5) — phải tick hết trước khi merge

- [ ] Code đúng kiến trúc
- [ ] Test liên quan đã có và qua
- [ ] Không phá dependency direction
- [ ] Không thêm folder/file rỗng
- [ ] Không tạo import vòng hoặc import trái tầng
- [ ] Tài liệu/ADR cần thiết đã cập nhật

---

<!--
Ví dụ minh họa (rút gọn):

Mục tiêu: Thêm use case "đánh dấu từ đã thuộc" cho feature vocabulary.
Phạm vi file: features/vocabulary/domain/usecases/mark_word_learned.dart,
  features/vocabulary/application/vocabulary_notifier.dart (chỉ gọi use case, không thêm logic).
Đầu ra mong đợi: use case mới + unit test domain, notifier gọi use case qua application.
Ràng buộc kiến trúc: domain không import Riverpod/Drift; application không query DB trực tiếp.
Tiêu chí hoàn tất: unit test domain pass; notifier không chứa business rule.
-->
