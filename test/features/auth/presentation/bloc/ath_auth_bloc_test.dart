import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintech_core/core/data_async_value/base_async_value_bloc.dart';
import 'package:fintech_core/features/auth/domain/entities/ath_user_entity.dart';
import 'package:fintech_core/features/auth/domain/repositories/interfaces/ath_i_repository.dart';
import 'package:fintech_core/features/auth/presentation/bloc/ath_auth_bloc.dart';

class MockAthIRepository extends Mock implements AthIRepository {}

void main() {
  group('AthAuthBloc', () {
    late MockAthIRepository repository;
    late AthAuthBloc bloc;
    
    const tEmail = 'test@bank.com';
    const tPassword = 'password';
    const tUser = AthUserEntity(
      id: '123',
      email: tEmail,
      token: 'abc',
      segment: 'VIP',
    );

    setUp(() {
      repository = MockAthIRepository();
      bloc = AthAuthBloc(repository: repository);
    });

    test('Initial state is correct', () {
      expect(
        bloc.state,
        equals(const BaseAsyncValueState<AthUserEntity>()),
      );
    });

    blocTest<AthAuthBloc, BaseAsyncValueState<AthUserEntity>>(
      'Emits loading and loaded states when login is successful',
      setUp: () => when(() => repository.login(tEmail, tPassword))
          .thenAnswer((_) async => const Right(tUser)),
      build: () => bloc,
      act: (bloc) => bloc.login(tEmail, tPassword),
      expect: () => [
        const BaseAsyncValueState<AthUserEntity>(
          status: ScreenStatusType.loading,
        ),
        const BaseAsyncValueState<AthUserEntity>(
          status: ScreenStatusType.success,
          value: tUser,
        ),
      ],
    );
  });
}
