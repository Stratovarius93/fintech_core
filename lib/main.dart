import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/sdui/sdui_registry.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/crashlytics_service.dart';
import 'core/network/dio_client.dart';
import 'features/auth/ath_injector.dart';
import 'features/auth/presentation/bloc/ath_blocs.dart';
import 'features/auth/presentation/pages/ath_login_page.dart';
import 'features/dashboard/dsb_injector.dart';
import 'features/dashboard/presentation/bloc/dsb_blocs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  
  // Initialize Core Services
  SduiRegistry.instance.init();
  await PushNotificationService.instance.init();
  await AnalyticsService.instance.init();
  await CrashlyticsService.instance.init();

  FlutterError.onError = (details) {
    CrashlyticsService.instance.recordError(details.exception, details.stack);
  };
  
  final dioClient = DioClient();
  runApp(MyApp(dioClient: dioClient));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.dioClient});

  /// Optional HTTP client override (used by E2E tests to control the
  /// network simulator). When null, the default chaos-enabled client is used.
  final DioClient dioClient;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        ...athInjector(dioClient),
        ...dsbInjector(dioClient),
      ],
      child: MultiBlocProvider(
        providers: [
          ...athBlocs(),
          ...dsbBlocs(),
        ],
        child: MaterialApp(
          title: 'Fintech Core',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const AthLoginPage(),
        ),
      ),
    );
  }
}
