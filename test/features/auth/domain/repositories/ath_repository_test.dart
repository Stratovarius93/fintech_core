import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintech_core/core/errors/failures.dart';
import 'package:fintech_core/core/errors/exceptions/server_exception.dart';
import 'package:fintech_core/core/errors/exceptions/parse_exception.dart';
import 'package:fintech_core/features/auth/data/datasources/interfaces/ath_i_network_data_source.dart';
import 'package:fintech_core/features/auth/data/models/ath_user_model.dart';
import 'package:fintech_core/features/auth/domain/repositories/ath_repository.dart';

class MockAthNetworkDataSource extends Mock implements AthINetworkDataSource {}

void main() {
  late AthRepository repository;
  late MockAthNetworkDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAthNetworkDataSource();
    repository = AthRepository(mockDataSource);
  });

  group('login repository', () {
    const tEmail = 'test@test.com';
    const tPassword = 'password';
    const tUserModel = AthUserModel(
      id: '1',
      email: tEmail,
      token: 'token',
      segment: 'NORMAL',
    );

    test(
      'should return Right(AthUserEntity) when login is successful',
      () async {
        when(
          () => mockDataSource.login(tEmail, tPassword),
        ).thenAnswer((_) async => tUserModel);

        final result = await repository.login(tEmail, tPassword);

        expect(result.isRight(), true);
        result.fold((l) => fail('Should be Right'), (r) {
          expect(r.id, '1');
          expect(r.email, tEmail);
        });
      },
    );

    test(
      'should return Left(ServiceFailure) when ServerException occurs',
      () async {
        when(() => mockDataSource.login(tEmail, tPassword)).thenThrow(
          ServerException(
            where: 'login',
            statusCode: 400,
            message: 'Error',
          ),
        );

        final result = await repository.login(tEmail, tPassword);

        expect(result.isLeft(), true);
        result.fold((l) {
          expect(l, isA<ServiceFailure>());
          expect(l.message, 'Error');
        }, (r) => fail('Should be Left'));
      },
    );

    test(
      'should return Left(GeneralFailure) when ParseException occurs',
      () async {
        when(() => mockDataSource.login(tEmail, tPassword)).thenThrow(
          ParseException(where: 'login', message: 'Parse error'),
        );

        final result = await repository.login(tEmail, tPassword);

        expect(result.isLeft(), true);
        result.fold((l) {
          expect(l, isA<GeneralFailure>());
          expect(l.message, 'Parse error');
        }, (r) => fail('Should be Left'));
      },
    );
  });
}
