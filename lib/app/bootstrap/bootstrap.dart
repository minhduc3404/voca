import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voca_app/app/app.dart';
import 'package:voca_app/features/study/application/providers.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Web chưa có app Firebase đăng ký (chỉ mới thêm Android/iOS trong
  // console) — bỏ qua init trên web để tránh crash lúc start; catalog
  // từ vựng (feature/vocabulary) tạm thời chỉ hoạt động trên Android/iOS.
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0x00000000),
      systemNavigationBarContrastEnforced: false,
    ),
  );

  // Container tường minh để kích hoạt tải trước model TTS ngay khi mở app
  // (không chờ tới lượt phát đầu tiên mới tải 35MB).
  final container = ProviderContainer();
  // Đọc provider để bắt đầu tải nền; lỗi được giữ trong AsyncValue, không
  // ném ra ngoài làm crash bootstrap.
  container.read(ttsModelWarmupProvider);

  runApp(
    UncontrolledProviderScope(container: container, child: const App()),
  );
}
