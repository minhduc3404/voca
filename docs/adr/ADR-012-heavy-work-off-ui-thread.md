# ADR-012: Task nặng phải chạy ở background isolate, không chạy trên UI thread

Status: Accepted

## Context

Flutter chạy toàn bộ Dart của app trên **một isolate chính** (UI thread). Mọi công việc CPU-bound chạy trên isolate này sẽ chặn vòng lặp dựng frame → UI đơ, rớt frame.

Ca thực tế làm phát sinh ADR này: TTS offline dùng `sherpa_onnx.OfflineTts.generate` — tác vụ CPU-bound đồng bộ (~1–2s cho một từ, cộng thêm lần đầu phải nạp model ONNX ~40MB). Khi gọi trực tiếp trên isolate chính, log Android báo `Choreographer: Skipped N frames! The application may be doing too much work on its main thread` và UI khựng trong lúc đọc.

Đây không phải vấn đề riêng của TTS. Bất kỳ tác vụ CPU-bound nào (giải nén/nén archive, decode/xử lý audio–ảnh, parse/ý dữ liệu lớn, thuật toán nặng) nếu chạy trên UI thread đều gây stuck tương tự.

Một cạm bẫy đã gặp: bọc `compute()` quanh `tts.generate` **không** chạy được — binding FFI của sherpa-onnx là **per-isolate**, worker isolate của `compute` không có binding (chỉ isolate chính gọi `initBindings()`), nên trả audio rỗng mà **không ném lỗi** (im lặng, rất khó lần).

## Decision

Task nặng **bắt buộc** chạy ở background, không chạy trên UI thread:

- **CPU-bound một lần, thuần dữ liệu** (input/output sendable, không giữ state): dùng `Isolate.run` / `compute`.
- **Engine giữ state nặng** (nạp model, handle FFI/native, cần khởi tạo tốn kém): dùng **isolate thường trú** (persistent) giao tiếp qua `SendPort`/`ReceivePort`, khởi tạo một lần rồi phục vụ nhiều request — không spawn lại mỗi lần. Ví dụ chuẩn: `SherpaTtsIsolate` (data layer) tự gọi `initBindings()` + dựng `OfflineTts` bên trong isolate, main chỉ gửi `{text, speed}` và nhận `samples`.
- **Binding FFI/native là per-isolate**: isolate nền phải **tự** `initBindings()` và **tự** dựng handle native. **Không** truyền handle FFI (con trỏ) qua ranh giới isolate — sẽ chạy với binding chưa init, hỏng im lặng.
- **IO ràng buộc mạng/disk** (tải file, đọc/ghi) chỉ cần `async`/`await` là đủ (không chặn thread) — không bắt buộc isolate. Nhưng CPU-bound thì `async` **không** cứu được (vẫn chạy trên UI thread), phải isolate.
- **Đóng gói trong `data/`**: chi tiết threading/isolate nằm ở data layer; application/presentation không biết tác vụ chạy ở đâu (chỉ thấy `Future`).
- **Warm-up sớm**: chi phí khởi tạo nặng (nạp model, spawn isolate) nên kích hoạt lúc mở app / vào feature, để không rơi vào lần dùng đầu tiên của người dùng.

## Consequences

- Dữ liệu qua ranh giới isolate phải **sendable** và bị **copy** (vd `Float32List` audio) — cần cân nhắc kích thước; thiết kế protocol message rõ ràng (request có id, match response).
- Phức tạp hơn về vòng đời: spawn/kill isolate, xử lý lỗi init trong isolate, dedupe lời gọi đồng thời để không dựng nhiều engine.
- Đổi lại: UI luôn mượt kể cả khi synth/giải nén chạy nền; và tránh lớp lỗi "im lặng do binding per-isolate".
- Review: mọi tác vụ CPU-bound mới đặt trên UI thread = fail review. Nếu nghi ngờ một tác vụ có nặng không, đo (log thời gian / quan sát `Skipped frames`) trước khi quyết định để trên main.
- ADR này bổ khuyết cho ADR-001 (Riverpod Notifier chỉ điều phối, không chứa logic nặng) và mô tả kiến trúc TTS trong PLAN.md.
