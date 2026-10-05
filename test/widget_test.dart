import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fintech_core/core/sdui/sdui_registry.dart';

import 'package:fintech_core/main.dart';
import 'package:fintech_core/features/auth/presentation/pages/ath_login_page.dart';

void main() {
  setUpAll(() async {
    dotenv.loadFromString(envString: 'API_BASE_URL=https://mock.url');
    Hive.init('test_hive');
    SduiRegistry.instance.init();
  });
  testWidgets('MyApp mounts and shows AthLoginPage smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Pump and settle to allow any initial animations or FutureBuilders to finish.
    await tester.pumpAndSettle();

    // Verify that the initial route mounts the AthLoginPage successfully.
    expect(find.byType(AthLoginPage), findsOneWidget);
  });
}
