import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:fintech_core/core/network/dio_client.dart';
import 'package:fintech_core/core/errors/exceptions/server_exception.dart';
import 'package:fintech_core/features/auth/data/datasources/ath_network_data_source.dart';
import 'package:fintech_core/features/auth/data/models/ath_user_model.dart';

class MockDioClient extends Mock implements DioClient {}
class MockDio extends Mock implements Dio {}

void main() {
  late AthNetworkDataSource dataSource;
  late MockDioClient mockDioClient;
  late MockDio mockDio;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.instance).thenReturn(mockDio);
    dataSource = AthNetworkDataSource(mockDioClient);
  });

  group('login network data source', () {
    const tEmail = 'test@bank.com';
    const tPassword = 'password';

    test('should return AthUserModel when the response code is 200', () async {
      final tResponse = Response(
        requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        statusCode: 200,
        data: {
          'data': {
            'id': '123',
            'email': tEmail,
            'token': 'token',
            'segment': 'VIP',
          }
        },
      );
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => tResponse);

      final result = await dataSource.login(tEmail, tPassword);

      expect(result, isA<AthUserModel>());
      expect(result.id, '123');
    });

    test('should throw ServerException when Dio throws DioException', () async {
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          statusCode: 401,
          data: {'message': 'Unauthorized'},
        ),
      ));

      final call = dataSource.login;

      expect(() => call(tEmail, tPassword), throwsA(isA<ServerException>()));
    });
  });
}
