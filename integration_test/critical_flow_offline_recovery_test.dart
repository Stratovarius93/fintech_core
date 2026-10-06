import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fintech_core/core/network/dio_client.dart';
import 'package:fintech_core/core/network/network_info.dart';
import 'package:fintech_core/core/network/network_simulator_interceptor.dart';
import 'package:fintech_core/core/sdui/sdui_registry.dart';
import 'package:fintech_core/core/utils/permission_util.dart';
import 'package:fintech_core/features/dashboard/data/datasources/dsb_local_store.dart';
import 'package:fintech_core/main.dart';

import 'helpers/e2e_helpers.dart';

/// Critical E2E flow: resilience of the account dashboard under degraded
/// connectivity.
///
/// login → dashboard (online) → offline → saved data → retry → recovery
///
/// Connectivity is controlled through [FakeNetworkInfo] and the network
/// simulator runs with a fixed latency and 0% random failures, so the flow is
/// deterministic while still exercising the real UI, BLoCs, repositories,
/// Dio pipeline and Hive cache on a device.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeNetworkInfo network;

  // Finders shared across scenarios.
  final emailField = find.byKey(const Key('ath_email_field'));
  final passwordField = find.byKey(const Key('ath_password_field'));
  final loginButton = find.byKey(const Key('ath_login_button'));
  final refreshButton = find.byKey(const Key('dsb_refresh_button'));
  final offlineBanner = find.byKey(const Key('dsb_offline_banner'));
  final offlineBannerRetry =
      find.byKey(const Key('dsb_offline_banner_retry_button'));
  final noInternetView = find.byKey(const Key('dsb_no_internet_view'));
  final noInternetRetry =
      find.byKey(const Key('dsb_no_internet_retry_button'));
  final checkingAccount = find.text('Checking Account');
  final checkingBalance = find.text('\$5432.10');

  setUpAll(() async {
    // No SDUI_URL on purpose: keeps the flow independent of the external
    // Google Sheets service (covered separately), avoiding flaky E2E runs.
    dotenv.loadFromString(envString: 'API_BASE_URL=https://api.test.bank/v1');
    await Hive.initFlutter();
    SduiRegistry.instance.init();
    PermissionUtil.instance = FakePermissionUtil();
  });

  setUp(() async {
    network = FakeNetworkInfo();
    NetworkInfo.instance = network;
    await DsbLocalStore.instance.clear();
  });

  Future<void> launchApp(WidgetTester tester) async {
    final dioClient = DioClient(
      simulator: NetworkSimulatorInterceptor(
        failureRate: 0, // deterministic: no random chaos
        minLatency: const Duration(milliseconds: 400),
        maxLatency: const Duration(milliseconds: 400),
      ),
    );
    await tester.pumpWidget(MyApp(dioClient: dioClient));
    await tester.pumpAndSettle();
  }

  Future<void> login(WidgetTester tester) async {
    expect(loginButton, findsOneWidget);
    await tester.enterText(emailField, 'user@bank.com');
    await tester.enterText(passwordField, '123456');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(loginButton);
  }

  group('Critical flow – dashboard resilience', () {
    testWidgets(
      'login → dashboard → offline → saved data → retry → recovery',
      (tester) async {
        await launchApp(tester);

        // 1. Login with valid credentials.
        await login(tester);

        // 2. Dashboard loads fresh data from the network (and caches it).
        await tester.pumpUntilFound(checkingAccount);
        expect(checkingBalance, findsOneWidget);
        expect(offlineBanner, findsNothing);

        // 3. Connectivity drops and the user refreshes.
        network.connected = false;
        await tester.tap(refreshButton);

        // 4. Saved data is shown, flagged as offline.
        await tester.pumpUntilFound(offlineBanner);
        expect(checkingAccount, findsOneWidget);
        expect(checkingBalance, findsOneWidget);

        // 5. Retrying while still offline keeps the saved data visible
        //    (no blank screen, no data loss).
        await tester.tap(offlineBannerRetry);
        await tester.pumpAndSettle();
        expect(offlineBanner, findsOneWidget);
        expect(checkingBalance, findsOneWidget);

        // 6. Connectivity is restored and the user retries.
        network.connected = true;
        await tester.tap(offlineBannerRetry);

        // 7. Recovery: fresh data replaces the cached one and the banner goes.
        await tester.pumpUntilGone(offlineBanner);
        await tester.pumpUntilFound(checkingAccount);
        expect(checkingBalance, findsOneWidget);
        expect(offlineBanner, findsNothing);
      },
    );

    testWidgets(
      'offline without saved data → offline state → retry → recovery',
      (tester) async {
        await launchApp(tester);

        // Device is offline and there is no cache yet (first session).
        network.connected = false;
        await login(tester);

        // The user gets an explicit offline state instead of a broken screen.
        await tester.pumpUntilFound(noInternetView);
        expect(checkingAccount, findsNothing);

        // Connectivity comes back and the user retries.
        network.connected = true;
        await tester.tap(noInternetRetry);

        // Recovery with fresh data and no offline indicators.
        await tester.pumpUntilFound(checkingAccount);
        expect(checkingBalance, findsOneWidget);
        expect(noInternetView, findsNothing);
        expect(offlineBanner, findsNothing);
      },
    );
  });
}
