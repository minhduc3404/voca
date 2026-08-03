import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voca_app/l10n/arb/app_localizations.dart';
import 'package:voca_app/app/theme/app_theme.dart';
import 'package:voca_app/features/study/application/providers.dart';
import 'package:voca_app/features/study/presentation/onboarding_screen.dart';
import 'package:voca_app/features/study/presentation/main_scaffold.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Mockup "Voca Memo" chỉ định 1 dark theme cố định (không có biến thể
      // light) — không theo ThemeMode.system.
      themeMode: ThemeMode.dark,
      // Lần đầu hiện onboarding 3 màn, sau đó vào MainScaffold (bottom nav).
      home: const _Root(),
    );
  }
}

/// Quyết định màn đầu tiên: onboarding nếu chưa xem, ngược lại MainScaffold.
class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seenAsync = ref.watch(onboardingSeenProvider);
    return seenAsync.when(
      loading: () => const Scaffold(body: SizedBox.shrink()),
      error: (_, __) => const MainScaffold(),
      data: (seen) => seen ? const MainScaffold() : const OnboardingScreen(),
    );
  }
}
