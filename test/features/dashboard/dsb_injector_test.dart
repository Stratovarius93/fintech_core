import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintech_core/core/network/dio_client.dart';
import 'package:fintech_core/features/dashboard/dsb_injector.dart';
import 'package:fintech_core/features/dashboard/domain/repositories/interfaces/dsb_i_repository.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  group('dsbInjector', () {
    late MockDioClient mockDioClient;

    setUp(() {
      mockDioClient = MockDioClient();
    });

    test('correctly provides a DsbIRepository', () {
      final providers = dsbInjector(mockDioClient);
      expect(providers.length, 1);

      final provider = providers.first;
      expect(provider, isA<RepositoryProvider<DsbIRepository>>());
    });
  });
}
