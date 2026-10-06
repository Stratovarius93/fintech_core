import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintech_core/core/data_async_value/base_async_value_bloc.dart';
import 'package:fintech_core/features/dashboard/domain/entities/dsb_summary_entity.dart';
import 'package:fintech_core/features/dashboard/domain/repositories/interfaces/dsb_i_repository.dart';
import 'package:fintech_core/features/dashboard/presentation/bloc/dsb_summary_bloc.dart';

class MockDsbIRepository extends Mock implements DsbIRepository {}

void main() {
  group('DsbSummaryBloc', () {
    late MockDsbIRepository repository;
    late DsbSummaryBloc bloc;
    
    final tDate = DateTime.now();
    final tSummary = DsbSummaryEntity(
      accounts: [
        DsbAccountEntity(
          accountName: 'Test Account',
          accountNumber: '123456',
          balance: 100.0,
          createdAt: tDate,
          isActive: true,
          transactions: const [],
        )
      ]
    );

    setUp(() {
      repository = MockDsbIRepository();
      bloc = DsbSummaryBloc(repository: repository);
    });

    test('Initial state is correct', () {
      expect(
        bloc.state,
        equals(const BaseAsyncValueState<DsbSummaryEntity>()),
      );
    });

    blocTest<DsbSummaryBloc, BaseAsyncValueState<DsbSummaryEntity>>(
      'Emits loading and loaded states when getSummary is successful',
      setUp: () => when(() => repository.getSummary())
          .thenAnswer((_) async => Right(tSummary)),
      build: () => bloc,
      act: (bloc) => bloc.getSummary(),
      expect: () => [
        const BaseAsyncValueState<DsbSummaryEntity>(
          status: ScreenStatusType.loading,
        ),
        BaseAsyncValueState<DsbSummaryEntity>(
          status: ScreenStatusType.success,
          value: tSummary,
        ),
      ],
    );
  });
}
