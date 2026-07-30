import 'package:flutter/material.dart';

import 'package:voca_app/l10n/arb/app_localizations.dart';
import 'package:voca_app/app/theme/app_theme.dart';
import 'package:voca_app/features/study/presentation/memo_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      home: const MemoScreen(),
    );
  }
}
