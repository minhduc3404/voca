import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voca_app/app/app.dart';

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

  runApp(const ProviderScope(child: App()));
}
