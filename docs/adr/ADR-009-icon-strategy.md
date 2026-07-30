# ADR-009: Chiến lược icon dùng Reicon (duotone) qua SVG asset thủ công

Status: Accepted

## Context

Voca cần một bộ icon nhất quán, chất lượng cao cho toàn app. Reicon.dev cung cấp hơn 3.900 icon SVG theo 3 weight: Outline, Filled, Duotone — và duotone là weight được chọn cho ứng dụng. Hai package Flutter chính thức của Reicon hiện có là `reicons` (v1.0.3, icon font TTF) và `reicon_flutter` (v1.0.1, sinh chuỗi SVG runtime) — cả hai hiện chỉ hỗ trợ Outline và Filled, chưa có duotone. Do đó không có package nào hiện đáp ứng được yêu cầu duotone.

## Decision

Icon duotone được lấy thủ công từng cái từ tính năng download/copy SVG trên reicon.dev và vendor làm asset SVG cục bộ trong app, render qua package `flutter_svg`. Cách làm này tương tự việc PLAN.md §2/§4 đã xử lý font (bundle TTF trực tiếp thay vì dùng package tải font động).

Quy ước:
- Icon asset đặt tại `assets/icons/<kebab-case-name>.svg`, tên file theo đúng slug icon của reicon.dev.
- Chỉ thêm icon vào `assets/icons/` khi có feature thật sự cần icon đó — không import hàng loạt cả bộ 3.900 icon để dự phòng. Nguyên tắc này đồng nhất với "không tạo thư mục/nội dung rỗng hoặc dự phòng" đã nêu ở PLAN.md §3.
- `pubspec.yaml` chỉ khai báo section `assets:` trỏ tới `assets/icons/` khi icon đầu tiên thực sự được thêm, không khai báo trước khi có nội dung.

## Consequences

- Không phụ thuộc vào package bên thứ ba chưa hỗ trợ duotone, tránh phải chờ upstream hoặc dùng weight sai (Outline/Filled) trái với quyết định thiết kế.
- Phải vendor thủ công từng icon SVG khi cần, tốn thao tác thủ công hơn so với dùng icon font, nhưng kiểm soát được đúng weight và nội dung.
- Nếu `reicons` hoặc `reicon_flutter` sau này ra bản hỗ trợ duotone, cần xem lại ADR này để cân nhắc chuyển sang dùng package chính thức thay vì asset thủ công — không thiết kế sẵn migration path ở giai đoạn này.
