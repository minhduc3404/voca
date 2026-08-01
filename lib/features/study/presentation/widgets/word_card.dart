import 'dart:async';

import 'package:flutter/material.dart';

import 'package:voca_app/app/theme/app_icon.dart';
import 'package:voca_app/app/theme/app_theme.dart';

import '../../domain/study_card.dart';

/// Hiển thị toàn bộ nội dung thẻ trên MỘT mặt — chế độ rảnh tay, không cần
/// chạm để lật: phiên âm, term, nghĩa, câu ví dụ hiện cùng lúc, theo layout
/// mockup Claude Design "Voca Memo - Memo Screen" (phonetic mono nhỏ → term
/// lớn đậm → nghĩa xanh → ví dụ in nghiêng mờ, căn giữa).
class WordCard extends StatelessWidget {
  const WordCard({
    required this.card,
    required this.onSpeak,
    this.speakingWordIndex,
    super.key,
  });

  final StudyCard card;

  /// Gọi khi bấm nút loa thủ công. `memo_screen.dart` còn tự động phát âm
  /// theo thời gian (2s, 6s) — đây là để nghe lại theo yêu cầu riêng.
  final VoidCallback onSpeak;

  /// Chỉ số từ (tách theo khoảng trắng trong `card.term`) đang được TTS đọc,
  /// `null` nếu không có từ nào đang đọc. Đây là `int?` thuần — widget không
  /// biết gì về TTS/riverpod, chỉ nhận số để tô sáng đúng từ (dumb widget,
  /// giống pattern `onSpeak`).
  final int? speakingWordIndex;

  /// Tách `term` theo khoảng trắng — điểm ngắt tự nhiên sẵn có trong từ
  /// vựng, không cần thêm dữ liệu nào để biết ranh giới từng từ.
  List<String> get _termWords =>
      RegExp(r'\S+').allMatches(card.term).map((m) => m.group(0)!).toList();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                card.partOfSpeech == null
                    ? card.phonetic
                    : '${card.phonetic} · ${card.partOfSpeech}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  letterSpacing: .5,
                  color: AppColors.phonetic,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                key: const Key('word-card-speak-button'),
                icon: AppIcon('volume-up', size: 18, color: AppColors.phonetic),
                visualDensity: VisualDensity.compact,
                tooltip: 'Nghe phát âm',
                onPressed: onSpeak,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final entry in _termWords.indexed)
                _AnimatedTermWord(
                  text: entry.$2,
                  // Chỉ áp dụng nhấn theo âm tiết khi term là 1 từ đơn —
                  // `card.phonetic` mô tả phát âm của CẢ term, với cụm nhiều
                  // từ (tương lai) không tách được theo từng từ trong cụm
                  // nên giữ hành vi cũ (tô sáng cả từ khi active).
                  phonetic: _termWords.length == 1 ? card.phonetic : '',
                  isActive: entry.$1 == speakingWordIndex,
                  style: textTheme.displaySmall,
                ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            card.definition,
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              '"${card.exampleSentence}"',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 15,
                height: 1.5,
                color: AppColors.textFainter,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Trọng số thời lượng của 1 âm tiết trong `phonetic` — âm tiết mang trọng
/// âm chính (ˈ) giữ lâu hơn khi đọc, trọng âm phụ (ˌ) trung bình, còn lại là
/// âm tiết thường. Dùng `contains` chứ không phải `startsWith` — dấu trọng
/// âm đứng trước NGUYÊN ÂM được nhấn, không nhất thiết ở đầu đoạn tách theo
/// dấu chấm (vd `ɪˈfem.ər.əl` — dấu `ˈ` nằm giữa đoạn "ɪˈfem" đầu tiên).
double _syllableWeight(String ipaSyllable) {
  if (ipaSyllable.contains('ˈ')) return 2;
  if (ipaSyllable.contains('ˌ')) return 1.4;
  return 1;
}

/// Tách phần IPA trong `phonetic` (vd `/ɪˈfem.ər.əl/`) thành trọng số từng
/// âm tiết theo dấu chấm — điểm ngắt âm tiết đã có sẵn trong dữ liệu phiên
/// âm, không cần thêm field nào. Rỗng/không có dấu chấm → coi là 1 âm tiết.
List<double> _parseSyllableWeights(String phonetic) {
  final ipa = phonetic.replaceAll(RegExp(r'[/\[\]]'), '');
  final syllables = ipa.split('.').where((s) => s.isNotEmpty).toList();
  if (syllables.isEmpty) return const [1];
  return syllables.map(_syllableWeight).toList();
}

/// Chia `word` thành `chunkCount` đoạn ký tự liền nhau, dài gần bằng nhau —
/// xấp xỉ ranh giới âm tiết theo chính tả (không có ánh xạ IPA↔chữ cái chính
/// xác tuyệt đối, nhưng đủ để tạo hiệu ứng chạy theo âm tiết hợp lý).
List<String> _splitIntoChunks(String word, int chunkCount) {
  if (chunkCount <= 1 || word.length < chunkCount) return [word];
  final base = word.length ~/ chunkCount;
  final remainder = word.length % chunkCount;
  final chunks = <String>[];
  var start = 0;
  for (var i = 0; i < chunkCount; i++) {
    final len = base + (i < remainder ? 1 : 0);
    chunks.add(word.substring(start, start + len));
    start += len;
  }
  return chunks;
}

/// Một từ trong `term` — phóng nhẹ + đổi màu accent khi đang được TTS đọc.
/// Nếu có `phonetic` (từ đơn), chạy tiếp hiệu ứng nhấn theo từng âm tiết bên
/// trong từ, thời lượng mỗi âm tiết suy từ trọng âm trong phiên âm IPA —
/// đây là ước lượng hiển thị (không đồng bộ 100% với audio thật, engine TTS
/// không có event ở mức âm tiết) chạy song song với event active thật.
class _AnimatedTermWord extends StatefulWidget {
  const _AnimatedTermWord({
    required this.text,
    required this.phonetic,
    required this.isActive,
    required this.style,
  });

  final String text;
  final String phonetic;
  final bool isActive;
  final TextStyle? style;

  @override
  State<_AnimatedTermWord> createState() => _AnimatedTermWordState();
}

class _AnimatedTermWordState extends State<_AnimatedTermWord> {
  late List<String> _chunks;
  late List<Duration> _chunkDurations;
  int _activeChunk = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _prepareChunks();
    // Không gọi `_startCycle()` (có setState) ở đây — `_activeChunk` đã mặc
    // định là 0, chỉ cần lên lịch timer đầu tiên nếu đang active sẵn.
    if (widget.isActive) _scheduleNextChunk();
  }

  @override
  void didUpdateWidget(covariant _AnimatedTermWord oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.phonetic != widget.phonetic) {
      _prepareChunks();
    }
    if (widget.isActive && !oldWidget.isActive) {
      _startCycle();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopCycle();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _prepareChunks() {
    final weights = _parseSyllableWeights(widget.phonetic);
    _chunks = _splitIntoChunks(widget.text, weights.length);
    final avgWeight = weights.reduce((a, b) => a + b) / weights.length;
    _chunkDurations = [
      for (final weight in weights)
        Duration(milliseconds: (220 * weight / avgWeight).round()),
    ];
    _activeChunk = 0;
  }

  void _startCycle() {
    _timer?.cancel();
    setState(() => _activeChunk = 0);
    _scheduleNextChunk();
  }

  void _stopCycle() {
    _timer?.cancel();
    _timer = null;
    setState(() => _activeChunk = 0);
  }

  void _scheduleNextChunk() {
    if (_chunks.length <= 1) return;
    _timer = Timer(_chunkDurations[_activeChunk], () {
      if (!mounted || !widget.isActive) return;
      setState(() => _activeChunk = (_activeChunk + 1) % _chunks.length);
      _scheduleNextChunk();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lúc không active, hiện cả từ liền như bình thường — chỉ tách thành
    // các đoạn âm tiết riêng khi thật sự đang được TTS đọc (đỡ vỡ layout
    // câu chữ lúc tĩnh, và không cần tách khi không có gì để nhấn theo).
    if (!widget.isActive || _chunks.length <= 1) {
      return _SyllableSpan(
        text: widget.text,
        isActive: widget.isActive,
        style: widget.style,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final entry in _chunks.indexed)
          _SyllableSpan(
            text: entry.$2,
            isActive: widget.isActive && entry.$1 == _activeChunk,
            style: widget.style,
          ),
      ],
    );
  }
}

class _SyllableSpan extends StatelessWidget {
  const _SyllableSpan({
    required this.text,
    required this.isActive,
    required this.style,
  });

  final String text;
  final bool isActive;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1.08 : 1,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        style: isActive
            ? (style ?? const TextStyle()).copyWith(color: AppColors.accent)
            : style ?? const TextStyle(),
        child: Text(text),
      ),
    );
  }
}
