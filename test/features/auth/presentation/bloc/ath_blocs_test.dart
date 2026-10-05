import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintech_core/features/auth/domain/repositories/interfaces/ath_i_repository.dart';
import 'package:fintech_core/features/auth/presentation/bloc/ath_blocs.dart';
import 'package:fintech_core/features/auth/presentation/bloc/ath_auth_bloc.dart';

class MockAthIRepository extends Mock implements AthIRepository {}

void main() {
  late MockAthIRepository mockRepository;

  setUp(() {
    mockRepository = MockAthIRepository();
  });

  Widget createTestWidget() {
    return RepositoryProvider<AthIRepository>(
      create: (context) => mockRepository,
      child: MultiBlocProvider(
        providers: athBlocs(),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final athAuthBloc = context.read<AthAuthBloc>();

                expect(athAuthBloc, isA<AthAuthBloc>());

                return const Text('Test Widget');
              },
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('athBlocs correctly sets up BlocProviders', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
  });
}
