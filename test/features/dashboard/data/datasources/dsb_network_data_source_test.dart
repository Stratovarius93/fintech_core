import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintech_core/core/network/dio_client.dart';
import 'package:fintech_core/core/errors/exceptions/server_exception.dart';
import 'package:fintech_core/features/dashboard/data/datasources/dsb_network_data_source.dart';
import 'package:fintech_core/features/dashboard/data/models/dsb_summary_model.dart';

class MockDioClient extends Mock implements DioClient {}
class MockDio extends Mock implements Dio {}

void main() {
  late DsbNetworkDataSource dataSource;
  late MockDioClient mockDioClient;
  late MockDio mockDio;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.instance).thenReturn(mockDio);
    dataSource = DsbNetworkDataSource(client: mockDioClient);
  });

  group('getSummary', () {
    final tResponse = {
      'data': {
        'total_balance': 1000.0,
        'account_number': '123',
        'recent_transactions': []
      }
    };

    test('should return DsbSummaryModel when the response code is 200', () async {
      when(() => mockDio.get<dynamic>('/api/v1/dashboard/summary'))
          .thenAnswer(
        (_) async => Response(
          data: tResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.getSummary();

      expect(result, isA<DsbSummaryModel>());
      expect(result.totalBalance, 1000.0);
    });

    test('should throw ServerException when Dio throws DioException', () async {
      when(() => mockDio.get<dynamic>('/api/v1/dashboard/summary'))
          .thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      expect(
        () => dataSource.getSummary(),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
