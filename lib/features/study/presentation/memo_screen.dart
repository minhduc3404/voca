import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voca_app/app/theme/app_icon.dart';
import 'package:voca_app/app/theme/app_theme.dart';
import 'package:voca_app/features/vocabulary/presentation/topic_list_screen.dart';
import 'package:voca_app/l10n/arb/app_localizations.dart';

import '../application/providers.dart';
import '../application/session_controller.dart';
import '../domain/study_rating.dart';
import 'tts_settings_screen.dart';
import 'widgets/remember_button.dart';
import 'widgets/word_card.dart';

/// Chế độ rảnh tay: mỗi thẻ hiện tối đa 10s (chia theo tốc độ đang chọn —
/// xem [_SessionBodyState._speedSteps]). TTS tự phát ở 20% và 60% thời
/// lượng đoạn hiện tại. Bấm "Đã nhớ" trong lúc đếm ngược = Good; hết giờ
/// không bấm = tự động Again rồi chuyển thẻ tiếp theo. Không đổi
/// domain/schema — chỉ là cách UI gọi `submitAnswer` (đã có sẵn từ trước).
const _autoAdvanceDuration = Duration(seconds: 10);
const _firstSpeakFraction = 0.2;
const _secondSpeakFraction = 0.6;

String _formatReviewDelay(Duration delay) {
  if (delay.inHours < 1) {
    final minutes = delay.inMinutes < 1 ? 1 : delay.inMinutes;
    return '$minutes phút';
  }
  if (delay.inHours < 24) {
    return '${delay.inHours} giờ';
  }
  return '${delay.inDays} ngày';
}

String _formatSpeed(double speed) {
  if (speed == speed.roundToDouble()) return speed.round().toString();
  return speed.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');
}

class MemoScreen extends ConsumerWidget {
  const MemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionControllerProvider);
    final session = sessionAsync.value;
    final showProgress =
        session != null && !session.isCompleted && session.total > 0;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: showProgress
            ? _ProgressHeader(position: session.position, total: session.total)
            : Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: AppColors.controlBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // TODO(icon): thay bằng SVG Reicon duotone theo ADR-009 khi có
              // asset — tạm dùng Material icon built-in cho đúng chức năng.
              icon: Icon(Icons.menu_book_outlined, color: AppColors.controlIcon),
              tooltip: 'Chủ đề từ vựng',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TopicListScreen()),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: AppColors.controlBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: AppIcon(
                'slider-vertical',
                size: 21,
                color: AppColors.controlIcon,
              ),
              tooltip: 'Cài đặt phát âm',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TtsSettingsScreen()),
              ),
            ),
          ),
        ],
        bottom: showProgress
            ? PreferredSize(
                preferredSize: const Size.fromHeight(10),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: session.position / session.total,
                      minHeight: 4,
                      backgroundColor: AppColors.progressTrack,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.accent,
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          const _AmbientGlow(),
          SafeArea(
            child: sessionAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Đã có lỗi khi tải thẻ học: $error')),
              data: (session) => _SessionBody(session: session),
            ),
          ),
        ],
      ),
    );
  }
}

/// "3 / 25 · còn 22 từ" — tự tính từ `session.position`/`session.total` đã
/// có sẵn, không cần field domain mới.
class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.position, required this.total});

  final int position;
  final int total;

  @override
  Widget build(BuildContext context) {
    final remaining = total - position;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$position / $total',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(width: 9),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.textDot,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          'còn $remaining từ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            color: AppColors.textFaint,
          ),
        ),
      ],
    );
  }
}

/// Quầng sáng trang trí phía sau thẻ từ, theo mockup Claude Design.
class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: const Alignment(0, -.35),
          child: Container(
            width: 420,
            height: 420,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentGlow,
                  AppColors.accentGlow.withValues(alpha: 0),
                ],
                stops: const [0, 1],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionBody extends ConsumerStatefulWidget {
  const _SessionBody({required this.session});

  final StudySessionState session;

  @override
  ConsumerState<_SessionBody> createState() => _SessionBodyState();
}

class _SessionBodyState extends ConsumerState<_SessionBody>
    with SingleTickerProviderStateMixin {
  static const _speedSteps = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  static const _defaultSpeedIndex = 2; // 1.0x — giống hành vi gốc.

  bool _showSaved = false;
  int? _currentCardId;
  int _speedIndex = _defaultSpeedIndex;
  bool _isPaused = false;
  bool _spokeFirst = false;
  bool _spokeSecond = false;

  Timer? _speakTimer1;
  Timer? _speakTimer2;
  Timer? _autoAdvanceTimer;
  bool? _wakelockEnabled;
  // Không khai báo type tường minh (`WakelockService`) — presentation không
  // được import `data/` trực tiếp (CLAUDE.md §2); type suy ra qua provider.
  late final _wakelockService = ref.read(wakelockServiceProvider);

  late final AnimationController _progress;
  Duration _totalDuration = _autoAdvanceDuration;

  double get _speed => _speedSteps[_speedIndex];

  Duration get _segmentDuration => Duration(
    microseconds: (_autoAdvanceDuration.inMicroseconds / _speed).round(),
  );

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: _totalDuration);
    _maybeSyncTimers();
    _syncWakelock();
  }

  @override
  void didUpdateWidget(covariant _SessionBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeSyncTimers();
    _syncWakelock();
  }

  @override
  void dispose() {
    _cancelTimers();
    _progress.dispose();
    if (_wakelockEnabled ?? false) {
      unawaited(_wakelockService.disable());
    }
    super.dispose();
  }

  /// Giữ màn hình sáng trong lúc còn thẻ để ôn — chế độ rảnh tay không có
  /// thao tác chạm thường xuyên nên Android/iOS sẽ tự dim/tắt màn hình theo
  /// timeout OS nếu không có wakelock. Tắt lại khi ôn xong.
  void _syncWakelock() {
    final shouldEnable = !widget.session.isCompleted;
    if (_wakelockEnabled == shouldEnable) return;
    _wakelockEnabled = shouldEnable;
    unawaited(shouldEnable ? _wakelockService.enable() : _wakelockService.disable());
  }

  /// Bắt đầu lại bộ đếm cho thẻ hiện tại — chỉ khi thẻ thực sự đổi và
  /// không đang hiện màn "Đã lưu!" (tránh đếm ngược lúc thẻ chưa hiện ra).
  void _maybeSyncTimers() {
    if (_showSaved) return;
    final card = widget.session.currentCard;
    if (card == null || card.id == _currentCardId) return;

    _currentCardId = card.id;
    _startCard(card.term);
  }

  void _startCard(String term) {
    _cancelTimers();
    _spokeFirst = false;
    _spokeSecond = false;
    _isPaused = false;
    _totalDuration = _segmentDuration;
    _progress
      ..duration = _totalDuration
      ..value = 0;
    _progress.forward();
    _scheduleTimers(term);
  }

  /// (Re)lên lịch 3 timer còn lại dựa trên thời gian đã trôi qua
  /// (`_totalDuration * _progress.value`) — dùng cả lúc bắt đầu thẻ (value
  /// = 0) lẫn lúc resume sau khi tạm dừng/đổi tốc độ.
  void _scheduleTimers(String term) {
    _speakTimer1?.cancel();
    _speakTimer2?.cancel();
    _autoAdvanceTimer?.cancel();

    final elapsed = _totalDuration * _progress.value;

    if (!_spokeFirst) {
      final remaining = (_totalDuration * _firstSpeakFraction) - elapsed;
      if (remaining > Duration.zero) {
        _speakTimer1 = Timer(remaining, () {
          _spokeFirst = true;
          _speak(term);
        });
      }
    }
    if (!_spokeSecond) {
      final remaining = (_totalDuration * _secondSpeakFraction) - elapsed;
      if (remaining > Duration.zero) {
        _speakTimer2 = Timer(remaining, () {
          _spokeSecond = true;
          _speak(term);
        });
      }
    }
    final remainingAdvance = _totalDuration - elapsed;
    if (remainingAdvance > Duration.zero) {
      _autoAdvanceTimer = Timer(
        remainingAdvance,
        () => _handleRating(StudyRating.again),
      );
    }
  }

  void _speak(String text) => ref.read(ttsServiceProvider).speak(text);

  void _cancelTimers() {
    _speakTimer1?.cancel();
    _speakTimer2?.cancel();
    _autoAdvanceTimer?.cancel();
    _speakTimer1 = null;
    _speakTimer2 = null;
    _autoAdvanceTimer = null;
  }

  void _togglePause() {
    if (_showSaved) return;
    final card = widget.session.currentCard;
    if (card == null) return;

    final pausing = !_isPaused;
    setState(() => _isPaused = pausing);
    if (pausing) {
      _progress.stop();
      _speakTimer1?.cancel();
      _speakTimer2?.cancel();
      _autoAdvanceTimer?.cancel();
    } else {
      final remaining = _totalDuration - (_totalDuration * _progress.value);
      _progress.animateTo(
        1,
        duration: remaining > Duration.zero ? remaining : Duration.zero,
      );
      _scheduleTimers(card.term);
    }
  }

  /// Đổi tốc độ đếm ngược/tự phát — giữ nguyên thời gian ĐÃ trôi qua, chỉ
  /// co giãn phần thời gian CÒN LẠI theo tốc độ mới (không đổi domain/SRS,
  /// chỉ là nhịp phát của UI rảnh tay).
  void _changeSpeed(int delta) {
    if (_showSaved) return;
    final card = widget.session.currentCard;
    if (card == null) return;

    final newIndex = (_speedIndex + delta)
        .clamp(0, _speedSteps.length - 1)
        .toInt();
    if (newIndex == _speedIndex) return;

    final elapsed = _totalDuration * _progress.value;
    setState(() => _speedIndex = newIndex);
    _totalDuration = _segmentDuration;
    final fraction = _totalDuration.inMicroseconds == 0
        ? 0.0
        : (elapsed.inMicroseconds / _totalDuration.inMicroseconds)
              .clamp(0.0, 1.0)
              .toDouble();
    _progress.value = fraction;

    if (!_isPaused) {
      final remaining = _totalDuration - (_totalDuration * fraction);
      _progress.animateTo(
        1,
        duration: remaining > Duration.zero ? remaining : Duration.zero,
      );
      _scheduleTimers(card.term);
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 900),
          content: Text('Tốc độ x${_formatSpeed(_speed)}'),
        ),
      );
  }

  Future<void> _handleRating(StudyRating rating) async {
    _cancelTimers();
    _progress.stop();
    setState(() => _showSaved = true);
    await ref.read(sessionControllerProvider.notifier).submitAnswer(rating);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _showSaved = false);
    _maybeSyncTimers();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.session.currentCard;

    if (card == null) {
      return _CompletionView(
        onReload: () =>
            ref.read(sessionControllerProvider.notifier).reload(),
      );
    }

    if (_showSaved) {
      return const _SavedTransition();
    }

    final now = DateTime.now();
    final previews = ref
        .read(sessionControllerProvider.notifier)
        .previewOutcomes(now);
    final goodOutcome = previews[StudyRating.good];
    final goodLabel = goodOutcome == null
        ? null
        : _formatReviewDelay(goodOutcome.nextReview.difference(now));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
          child: AnimatedBuilder(
            animation: _progress,
            builder: (context, _) => ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: 1 - _progress.value,
                minHeight: 4,
                backgroundColor: AppColors.progressTrack,
                valueColor: const AlwaysStoppedAnimation(AppColors.accent),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, .02),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: WordCard(
                key: ValueKey(card.id),
                card: card,
                onSpeak: () => ref.read(ttsServiceProvider).speak(card.term),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Row(
            children: [
              _TransportButton(
                icon: 'skip-prev',
                tooltip: 'Giảm tốc độ',
                enabled: _speedIndex > 0,
                onPressed: () => _changeSpeed(-1),
              ),
              const SizedBox(width: 10),
              _TransportButton(
                icon: _isPaused ? 'play' : 'pause',
                tooltip: _isPaused ? 'Tiếp tục' : 'Tạm dừng',
                onPressed: _togglePause,
              ),
              const SizedBox(width: 10),
              _TransportButton(
                icon: 'skip-next',
                tooltip: 'Tăng tốc độ',
                enabled: _speedIndex < _speedSteps.length - 1,
                onPressed: () => _changeSpeed(1),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: RememberButton(
                  onPressed: () => _handleRating(StudyRating.good),
                  previewLabel: goodLabel,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransportButton extends StatelessWidget {
  const _TransportButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.enabled = true,
  });

  /// Slug icon Reicon trong `assets/icons/` (vd `skip-prev`, `pause`).
  final String icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        style: IconButton.styleFrom(
          backgroundColor: enabled
              ? AppColors.controlBg
              : AppColors.controlBgDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: AppIcon(
          icon,
          size: 22,
          color: enabled ? AppColors.controlIcon : AppColors.controlIconDisabled,
        ),
        tooltip: tooltip,
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}

class _SavedTransition extends StatelessWidget {
  const _SavedTransition();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon('check-circle', size: 56, color: AppColors.accent),
          const SizedBox(height: 12),
          const Text(
            'Đã lưu!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text('Cùng tiến lên nào 💪', style: TextStyle(color: AppColors.textFaint)),
        ],
      ),
    );
  }
}

class _CompletionView extends StatelessWidget {
  const _CompletionView({required this.onReload});

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppIcon('confetti', size: 64, color: AppColors.accent),
            const SizedBox(height: 16),
            const Text(
              'Đã ôn hết thẻ đến hạn hôm nay',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Quay lại vào ngày mai hoặc thêm từ mới.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textFaint),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onReload,
              child: const Text('Ôn lại từ mới'),
            ),
          ],
        ),
      ),
    );
  }
}
