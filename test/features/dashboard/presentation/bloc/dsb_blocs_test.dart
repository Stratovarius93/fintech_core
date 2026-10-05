import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintech_core/features/dashboard/domain/repositories/interfaces/dsb_i_repository.dart';
import 'package:fintech_core/features/dashboard/presentation/bloc/dsb_blocs.dart';
import 'package:fintech_core/features/dashboard/presentation/bloc/dsb_summary_bloc.dart';

class MockDsbIRepository extends Mock implements DsbIRepository {}

void main() {
  late MockDsbIRepository mockRepository;

  setUp(() {
    mockRepository = MockDsbIRepository();
  });

  Widget createTestWidget() {
    return RepositoryProvider<DsbIRepository>(
      create: (context) => mockRepository,
      child: MultiBlocProvider(
        providers: dsbBlocs(),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final bloc = context.read<DsbSummaryBloc>();
                expect(bloc, isA<DsbSummaryBloc>());
                return const Text('Test Widget');
              },
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('dsbBlocs correctly sets up BlocProviders', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
  });
}
