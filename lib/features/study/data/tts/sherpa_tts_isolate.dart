import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

/// Kết quả synth thô trả về từ isolate (chỉ audio; tokenize/segment làm ở
/// main vì rất nhẹ).
class SherpaAudio {
  const SherpaAudio(this.samples, this.sampleRate);
  final Float32List samples;
  final int sampleRate;
}

/// Tham số khởi tạo engine, gửi sang isolate lúc spawn. Toàn field sendable.
class _InitMsg {
  const _InitMsg({
    required this.replyTo,
    required this.model,
    required this.tokens,
    required this.lexicon,
    required this.dataDir,
    required this.numThreads,
  });
  final SendPort replyTo;
  final String model;
  final String tokens;
  final String lexicon;
  final String dataDir;
  final int numThreads;
}

class _GenRequest {
  const _GenRequest(this.id, this.text, this.speed);
  final int id;
  final String text;
  final double speed;
}

class _GenOk {
  const _GenOk(this.id, this.samples, this.sampleRate);
  final int id;
  final Float32List samples;
  final int sampleRate;
}

class _GenErr {
  const _GenErr(this.id, this.error);
  final int id;
  final String error;
}

/// Bọc một isolate nền chạy sherpa-onnx: isolate tự gọi `initBindings()` và
/// dựng `OfflineTts` của riêng nó (bindings sherpa là per-isolate — đây là
/// lý do bọc `compute` một lần trước đây thất bại: worker isolate không có
/// bindings). Synth chạy trong isolate nên KHÔNG chặn UI thread.
class SherpaTtsIsolate {
  Isolate? _isolate;
  SendPort? _cmdPort;
  ReceivePort? _fromIsolate;
  final Completer<void> _ready = Completer<void>();
  final Map<int, Completer<SherpaAudio>> _pending = {};
  int _nextId = 0;
  bool _disposed = false;

  bool get isReady => _ready.isCompleted;

  /// Spawn isolate + chờ engine dựng xong. Model phải đã được giải nén ra
  /// disk trước (paths trỏ tới file thật).
  Future<void> start({
    required String model,
    required String tokens,
    required String lexicon,
    required String dataDir,
    required int numThreads,
  }) async {
    final fromIsolate = ReceivePort();
    _fromIsolate = fromIsolate;
    fromIsolate.listen(_onMessage);
    _isolate = await Isolate.spawn(
      _entry,
      _InitMsg(
        replyTo: fromIsolate.sendPort,
        model: model,
        tokens: tokens,
        lexicon: lexicon,
        dataDir: dataDir,
        numThreads: numThreads,
      ),
      debugName: 'sherpa-tts',
    );
    return _ready.future;
  }

  void _onMessage(dynamic message) {
    if (message is SendPort) {
      _cmdPort = message;
      if (!_ready.isCompleted) _ready.complete();
      return;
    }
    if (message is _GenOk) {
      _pending
          .remove(message.id)
          ?.complete(SherpaAudio(message.samples, message.sampleRate));
      return;
    }
    if (message is _GenErr) {
      _pending.remove(message.id)?.completeError(StateError(message.error));
      return;
    }
    if (message is String && message.startsWith('init-error:')) {
      // Lỗi dựng engine trong isolate — fail luôn cho caller đang chờ ready.
      if (!_ready.isCompleted) {
        _ready.completeError(StateError(message.substring('init-error:'.length)));
      }
    }
  }

  /// Yêu cầu isolate synth [text]. Trả về audio thô; ném nếu isolate lỗi.
  Future<SherpaAudio> generate(String text, double speed) {
    if (_disposed) {
      return Future.error(StateError('SherpaTtsIsolate đã dispose'));
    }
    final id = _nextId++;
    final completer = Completer<SherpaAudio>();
    _pending[id] = completer;
    _cmdPort!.send(_GenRequest(id, text, speed));
    return completer.future;
  }

  void dispose() {
    _disposed = true;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _fromIsolate?.close();
    _fromIsolate = null;
    for (final c in _pending.values) {
      if (!c.isCompleted) c.completeError(StateError('isolate disposed'));
    }
    _pending.clear();
  }

  /// Entry của isolate (phải là top-level/static). Dựng engine rồi phục vụ
  /// các yêu cầu synth cho tới khi bị kill.
  static void _entry(_InitMsg init) {
    final sherpa_onnx.OfflineTts tts;
    try {
      sherpa_onnx.initBindings();
      final vits = sherpa_onnx.OfflineTtsVitsModelConfig(
        model: init.model,
        tokens: init.tokens,
        lexicon: init.lexicon,
        dataDir: init.dataDir,
      );
      final modelConfig = sherpa_onnx.OfflineTtsModelConfig(
        vits: vits,
        numThreads: init.numThreads,
        debug: false,
      );
      tts = sherpa_onnx.OfflineTts(
        sherpa_onnx.OfflineTtsConfig(model: modelConfig, maxNumSenetences: 1),
      );
    } catch (error) {
      init.replyTo.send('init-error:$error');
      return;
    }

    final commands = ReceivePort();
    init.replyTo.send(commands.sendPort);
    commands.listen((message) {
      if (message is! _GenRequest) return;
      try {
        final audio = tts.generate(text: message.text, speed: message.speed);
        // Copy sang buffer Dart sở hữu để gửi an toàn qua isolate (tránh
        // gửi view trên bộ nhớ native có thể bị giải phóng).
        final samples = Float32List.fromList(audio.samples);
        init.replyTo.send(_GenOk(message.id, samples, audio.sampleRate));
      } catch (error) {
        init.replyTo.send(_GenErr(message.id, error.toString()));
      }
    });
  }
}
