# Kế hoạch kiến trúc Voca Flutter

## 1. Bối cảnh và phạm vi

- Repo hiện tại đang trống hoàn toàn, chưa có mã nguồn, chưa có cấu trúc thư mục, chưa có cấu hình build, chưa có dữ liệu di trú, chưa có test.
- Tài liệu này là bản kế hoạch triển khai kiến trúc cuối cùng cho Voca Flutter, dùng làm chuẩn điều phối giữa AI và con người trước khi bắt đầu code.
- Phạm vi chỉ bao gồm kiến trúc ứng dụng, cấu trúc thư mục, quy ước phụ thuộc, quy trình triển khai, chất lượng, và governance.
- Không bao gồm thiết kế tính năng chi tiết theo UI, nội dung nghiệp vụ từng màn hình, hay tối ưu hóa ngoài phạm vi nền tảng ban đầu.

## 2. Stack cuối cùng

- State management: `Riverpod 3`.
- Persistence cục bộ: `Drift` + `drift_flutter`.
- Lưu cấu hình nhẹ: `shared_preferences`.
- Điều hướng: `Navigator` với `push` / `pop`.
- Đa ngôn ngữ: `ARB` + `gen_l10n`.
- Font: TTF bundle trong ứng dụng.
- Không dùng baseline sau trong kiến trúc khởi điểm: `go_router`, `freezed`, `google_fonts`.

## 3. Nguyên tắc tổ chức

- Tổ chức theo feature-first, giới hạn tối đa 4 lớp trong mỗi feature.
- Không tạo thư mục rỗng chỉ để “dự phòng”. Chỉ thêm folder khi đã có ít nhất một file thật và có trách nhiệm rõ.
- Không dùng broad barrel files ở cấp rộng để tránh làm mờ hướng phụ thuộc. Ưu tiên import trực tiếp theo file hoặc theo module hẹp.
- Cần ưu tiên tính rõ phụ thuộc hơn mọi tranh luận về tối ưu build tool.

## 4. Cây thư mục chuẩn

```text
lib/
  app/
    app.dart
    bootstrap/
    routing/
    l10n/
    theme/
  core/
    errors/
    utils/
    widgets/
    services/
  features/
    <feature_name>/
      presentation/
      application/
      domain/
      data/
```

- `app/`: ghép ứng dụng, bootstrap, cấu hình toàn cục, l10n, theme, entry orchestration.
- `core/`: hạ tầng dùng chung thật sự, chỉ dành cho phần cắt qua nhiều feature.
- `features/<feature_name>/presentation`: widget, screen, controller UI, state view, event UI.
- `features/<feature_name>/application`: use case, facade, orchestration, converter phục vụ UI.
- `features/<feature_name>/domain`: entity, value object, repository contract, business rules thuần.
- `features/<feature_name>/data`: DTO, local datasource, mapper, repository implementation.

## 5. Hướng phụ thuộc bắt buộc

```text
presentation → application → domain ← data
```

- `presentation` được gọi `application`, không import ngược xuống `domain` trực tiếp khi có thể đi qua `application`.
- `application` chỉ làm việc với `domain` và các abstraction cần thiết.
- `domain` không phụ thuộc vào Flutter, Riverpod, Drift, `shared_preferences`, hay bất kỳ package UI/hạ tầng nào.
- `data` được phép phụ thuộc vào `domain` để triển khai contract, nhưng `domain` không được import `data`.
- `core` không được trở thành “bãi chứa” cho logic nghiệp vụ của feature.

## 6. Trách nhiệm và import bị cấm

### 6.1 Presentation

- Trách nhiệm: hiển thị, bắt sự kiện UI, gọi `application`, điều phối điều hướng qua `Navigator`.
- Được phép: widget, Riverpod provider cho UI, local UI state, localization lookup, navigation calls.
- Cấm import: `data` trực tiếp, repository implementation, SQL schema, storage implementation, logic domain thuần nếu đã có use case phù hợp.

### 6.2 Application

- Trách nhiệm: điều phối luồng, chuẩn hóa input/output, đóng vai trò cầu nối giữa UI và domain.
- Được phép: gọi use case/domain contract, compose state cho UI, map lỗi nghiệp vụ sang kết quả hiển thị.
- Cấm import: widget Flutter, `Navigator` trực tiếp, Drift table/query, `shared_preferences` API trực tiếp.

### 6.3 Domain

- Trách nhiệm: quy tắc nghiệp vụ, contract trừu tượng, bất biến của dữ liệu cốt lõi.
- Được phép: Dart thuần, interface repository, entity/value object, domain service nếu thật sự cần.
- Cấm import: Flutter SDK, Riverpod, Drift, `shared_preferences`, `Navigator`, generated localization.

### 6.4 Data

- Trách nhiệm: hiện thực hóa repository, truy cập DB, truy cập preference, mapper, migration.
- Được phép: Drift, `drift_flutter`, `shared_preferences`, JSON/DTO, file/IO.
- Cấm import: widget, screen, UI controller, và business rule thuần để tránh đẩy nghiệp vụ xuống tầng hạ tầng.

## 7. Riverpod 3

- Dùng `Notifier` và `AsyncNotifier` theo phong cách hiện đại của Riverpod 3 cho state quản lý trong application/presentation.
- Không viết kiến trúc mới theo kiểu transitional patterns cũ; thay vào đó chuẩn hóa quanh `Notifier`/`AsyncNotifier`, provider rõ ràng, và state bất biến ở tầng phù hợp.
- Provider phải có tên mô tả chức năng, không đặt theo kiểu chung chung khó đọc.
- Quy tắc migration: nếu có mã kế thừa từ style cũ, chuyển từng feature sang conventions mới theo lớp, không trộn hai phong cách trong cùng một module nếu tránh được.
- Tránh nhồi logic nghiệp vụ vào notifier; notifier chỉ điều phối, gọi use case, và xuất state cho UI.

## 8. Drift và `drift_flutter`

- `Drift` là nguồn chính cho dữ liệu bền vững cục bộ.
- `drift_flutter` chỉ là gói hỗ trợ tích hợp runtime Flutter cho phần cấu hình/kết nối, không đồng nghĩa rằng có thể bỏ qua thiết kế schema, migration, hay kiểm soát lifecycle.
- Phải định nghĩa schema, versioning, và migration path ngay từ đầu.
- Migration bắt buộc có chiến lược rõ: tăng version có kiểm soát, viết migration code, và kiểm tra khả năng đọc dữ liệu cũ.
- Query phức tạp, transaction, và mapping phải nằm ở `data`.
- Không để UI gọi trực tiếp query hay biết chi tiết bảng.

## 9. `shared_preferences`

- Chỉ dùng cho dữ liệu nhẹ, dạng cấu hình người dùng, lựa chọn UI, cờ tính năng cục bộ, hoặc trạng thái không mang tính nghiệp vụ lõi.
- Không dùng `shared_preferences` để lưu dữ liệu domain chính, dữ liệu cần query phức tạp, hoặc trạng thái cần migration có tính cấu trúc cao.
- Truy cập preference phải được bọc qua abstraction trong `data` hoặc service riêng, không rải lệnh đọc/ghi khắp app.

## 10. Điều hướng

- Khởi đầu dùng `Navigator.push` / `Navigator.pop` làm chuẩn.
- Không đưa `go_router` vào baseline.
- Cần xem xét lại chiến lược navigation nếu xuất hiện một hoặc nhiều tín hiệu sau:
  - Luồng deep link thực sự cần route declaration trung tâm.
  - App phát sinh nhiều nhánh điều hướng dựa trên auth/onboarding/phân quyền phức tạp.
  - Số màn hình và stack pattern tăng đến mức điều hướng tay làm giảm độ rõ ràng.
  - Cần route restoration, nested navigation, hoặc redirection logic có cấu trúc hơn mức `Navigator` thuần.

## 11. SRS và miền nghiệp vụ критical

- SRS phải xác định rõ các miền nghiệp vụ critical trước khi code feature tương ứng.
- Với miền critical, contract cần chặt: input/output, bất biến, lỗi hợp lệ, hành vi lưu trữ, hành vi hiển thị tối thiểu.
- Không cho phép “tự hiểu ngầm” ở các luồng critical; mọi giả định phải được ghi vào SRS hoặc ADR.
- Mỗi miền critical phải có test matrix tối thiểu gồm:
  - Domain unit test cho bất biến và rule.
  - Application test cho orchestration và mapping.
  - Data test cho repository/DAO/migration logic.
  - Widget/integration test cho luồng người dùng trọng yếu.

## 12. Quy tắc `core` và two-feature rule

- `core` chỉ nhận một module khi nó được chứng minh là dùng chung cho ít nhất hai feature thật sự.
- Nếu chưa đạt two-feature rule, để mã ở feature cụ thể hoặc `app/` thay vì đẩy sớm vào `core`.
- Khi một phần tử trong `core` được thêm vào, phải có lý do tái sử dụng đã nhìn thấy, không phải giả định tương lai.

## 13. Arrow import và barrel files

- Không tạo barrel files rộng chỉ để rút ngắn import.
- Mục tiêu chính là độ rõ ràng của phụ thuộc và khả năng review, không phải câu chuyện performance build tool.
- Nếu có barrel file hẹp thì phải có lý do rõ ràng, phạm vi nhỏ, và không che khuất biên giới domain/data/presentation.

## 14. AI-human governance

### 14.1 Vai trò

- AI: đề xuất, sinh mã, phân tích tác động, soát chéo quy tắc kiến trúc, và chỉ thực hiện thay đổi khi task contract cho phép.
- Con người: chốt yêu cầu, phê duyệt phạm vi, quyết định trade-off kiến trúc, và ký off cho các vùng nhạy cảm.

### 14.2 Approval zones

- Phải xin duyệt trước khi thay đổi:
  - Domain contract.
  - Persistence schema và migration.
  - Điều hướng cấp ứng dụng.
  - Localization keys dùng chung.
  - Bất kỳ quyết định nào ảnh hưởng nhiều feature.

### 14.3 Task contract

- Mỗi task phải ghi rõ: mục tiêu, phạm vi file, đầu ra mong đợi, ràng buộc kiến trúc, và tiêu chí hoàn tất.
- Task không được mơ hồ kiểu “làm đẹp”, “dọn dẹp”, hoặc “cải thiện tổng thể” nếu không có tiêu chí đo được.

### 14.4 Definition of Ready

- Requirement đã rõ.
- Miền ảnh hưởng đã xác định.
- Contract đầu vào/đầu ra có thể kiểm chứng.
- Phụ thuộc bên ngoài đã biết.
- Tiêu chí hoàn tất có thể test được.

### 14.5 Definition of Done

- Code đúng kiến trúc.
- Test liên quan đã có và qua.
- Không phá dependency direction.
- Không thêm folder/file rỗng.
- Không tạo import vòng hoặc import trái tầng.
- Tài liệu/ADR cần thiết đã cập nhật.

### 14.6 Quality gates

- Không merge nếu còn vi phạm tầng phụ thuộc.
- Không merge nếu migration chưa được kiểm thử.
- Không merge nếu luồng critical thiếu test.
- Không merge nếu navigation/persistence contract chưa được reviewer xác nhận.

## 15. Kế hoạch triển khai 0-6

### Phase 0 - Khởi tạo khung

- Tạo cấu trúc `lib/`, cấu hình Flutter cơ bản, l10n, assets, fonts, tooling.
- Exit criteria: app chạy được, build sạch, không có folder rỗng không cần thiết.

### Phase 1 - Nền tảng kiến trúc

- Thiết lập feature-first tree, chuẩn dependency direction, template provider pattern, abstract contracts.
- Exit criteria: một feature mẫu đi qua đủ `presentation → application → domain ← data`.

### Phase 2 - Persistence nền

- Thiết lập Drift database, schema ban đầu, migration strategy, repository implementation mẫu.
- Exit criteria: có lưu/đọc thật, migration test được, UI không chạm trực tiếp DB.

### Phase 3 - State và luồng chính

- Chuyển luồng chính sang Riverpod 3 với `Notifier`/`AsyncNotifier`, chuẩn hóa error/loading state.
- Exit criteria: state management nhất quán, không còn style cũ lẫn lộn trong luồng đã chuyển.

### Phase 4 - Localization và tài nguyên

- Hoàn thiện ARB/gen_l10n, tích hợp font TTF, chuẩn hóa text key và fallback.
- Exit criteria: đa ngôn ngữ build được, không hardcode text ở nơi đã có key.

### Phase 5 - Đóng gói feature lõi

- Triển khai các feature cốt lõi theo two-feature rule cho core, viết test matrix cho miền critical.
- Exit criteria: feature trọng yếu chạy end-to-end, test đủ lớp, không phá kiến trúc.

### Phase 6 - Stabilization

- Dọn technical debt đã ghi nhận, bổ sung ADR còn thiếu, rà soát navigation/persistence, chốt release candidate.
- Exit criteria: quality gates đạt, tài liệu đầy đủ, chỉ còn thay đổi theo bugfix hoặc product refinement.

## 16. ADR bắt buộc

- ADR-001: Chọn `Riverpod 3` và conventions `Notifier`/`AsyncNotifier`.
- ADR-002: Chọn `Drift` + `drift_flutter` cho persistence cục bộ.
- ADR-003: Chọn `shared_preferences` chỉ cho cấu hình nhẹ.
- ADR-004: Chọn `Navigator push/pop` làm baseline navigation.
- ADR-005: Chọn ARB + `gen_l10n` cho localization.
- ADR-006: Chọn bundled TTF cho font.
- ADR-007: Chọn feature-first, tối đa 4 lớp, không barrel rộng.
- ADR-008: Chọn SRS contract và test matrix cho miền critical.

## 17. Tài liệu tham chiếu có thẩm quyền

- Flutter official docs.
- Riverpod official docs.
- Drift official docs.
- `shared_preferences` official docs.
- Flutter internationalization docs (`gen_l10n`, ARB).
- Flutter navigation docs cho `Navigator`.
- Nội bộ: SRS của sản phẩm, ADR đã duyệt, quyết định kiến trúc được ký xác nhận.
