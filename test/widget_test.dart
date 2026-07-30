// Basic smoke test verifying the app boots and shows the localized title.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voca_app/app/app.dart';

void main() {
  testWidgets('App shows the localized app title', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.text('Voca'), findsWidgets);
  });
}
