import 'package:flutter_test/flutter_test.dart';

import 'package:fintech_core/main.dart';
import 'package:fintech_core/features/auth/presentation/pages/ath_login_page.dart';

void main() {
  testWidgets('MyApp mounts and shows AthLoginPage smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Pump and settle to allow any initial animations or FutureBuilders to finish.
    await tester.pumpAndSettle();

    // Verify that the initial route mounts the AthLoginPage successfully.
    expect(find.byType(AthLoginPage), findsOneWidget);
  });
}
