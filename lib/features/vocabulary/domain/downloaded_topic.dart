/// Trạng thái local — chủ đề nào đã tải về máy, ở version nào.
class DownloadedTopic {
  const DownloadedTopic({
    required this.topicId,
    required this.downloadedVersion,
    required this.downloadedAt,
  });

  final String topicId;
  final int downloadedVersion;
  final DateTime downloadedAt;
}
