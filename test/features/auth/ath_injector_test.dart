import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintech_core/core/network/dio_client.dart';
import 'package:fintech_core/features/auth/ath_injector.dart';
import 'package:fintech_core/features/auth/domain/repositories/interfaces/ath_i_repository.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  group('athInjector', () {
    late MockDioClient mockDioClient;

    setUp(() {
      mockDioClient = MockDioClient();
    });

    test('correctly provides an AthIRepository', () {
      final providers = athInjector(mockDioClient);
      expect(providers.length, 1);

      final provider = providers.first;
      expect(provider, isA<RepositoryProvider<AthIRepository>>());
    });
  });
}
