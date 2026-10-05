import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/network/dio_client.dart';
import 'features/auth/ath_injector.dart';
import 'features/auth/presentation/bloc/ath_blocs.dart';
import 'features/auth/presentation/pages/ath_login_page.dart';
import 'features/dashboard/dsb_injector.dart';
import 'features/dashboard/presentation/bloc/dsb_blocs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize DioClient (which includes the NetworkSimulatorInterceptor)
    final dioClient = DioClient();

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
