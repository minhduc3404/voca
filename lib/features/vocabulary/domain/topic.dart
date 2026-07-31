/// Metadata 1 chủ đề trong catalog remote — lấy từ `topics.json`.
/// Không chứa nội dung từ (xem [CatalogWord]) — chỉ đủ để hiển thị danh
/// sách chủ đề trước khi người dùng chọn tải.
class Topic {
  const Topic({
    required this.id,
    required this.name,
    required this.wordCount,
    required this.version,
  });

  /// ID ổn định, duy nhất trong catalog (vd `"travel"`).
  final String id;

  final String name;

  /// Số từ trong chủ đề — hiển thị UI trước khi tải, không đảm bảo khớp
  /// tuyệt đối với `words.length` thật trong file chi tiết (do người
  /// biên soạn catalog tự khai).
  final int wordCount;

  /// Tăng dần mỗi lần nội dung chủ đề đổi — so với
  /// [DownloadedTopic.downloadedVersion] để biết có bản cập nhật không.
  final int version;
}
