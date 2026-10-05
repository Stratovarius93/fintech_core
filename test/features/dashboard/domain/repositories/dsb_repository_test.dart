import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintech_core/core/errors/failures.dart';
import 'package:fintech_core/core/errors/exceptions/server_exception.dart';
import 'package:fintech_core/core/errors/exceptions/parse_exception.dart';
import 'package:fintech_core/core/network/network_info.dart';
import 'package:fintech_core/features/dashboard/data/datasources/dsb_local_store.dart';
import 'package:fintech_core/features/dashboard/data/datasources/dsb_network_data_source.dart';
import 'package:fintech_core/features/dashboard/domain/repositories/dsb_repository.dart';
import 'package:fintech_core/features/dashboard/data/models/dsb_summary_model.dart';

class MockDsbNetworkDataSource extends Mock implements DsbNetworkDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}
class MockDsbLocalStore extends Mock implements DsbLocalStore {}

void main() {
  setUpAll(() {
    registerFallbackValue(const DsbSummaryModel());
  });

  late DsbRepository repository;
  late MockDsbNetworkDataSource mockDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late MockDsbLocalStore mockLocalStore;

  setUp(() {
    mockDataSource = MockDsbNetworkDataSource();
    mockNetworkInfo = MockNetworkInfo();
    mockLocalStore = MockDsbLocalStore();
    
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    when(() => mockLocalStore.saveSummary(any())).thenAnswer((_) async {});
    
    repository = DsbRepository(
      dataSource: mockDataSource,
      networkInfo: mockNetworkInfo,
      localStore: mockLocalStore,
    );
  });

  group('getSummary', () {
    const tModel = DsbSummaryModel(
      totalBalance: 100.0,
      accountNumber: '123',
      recentTransactions: [],
    );

    test(
      'should return Right(DsbSummaryEntity) when getSummary is successful',
      () async {
        when(() => mockDataSource.getSummary()).thenAnswer((_) async => tModel);

        final result = await repository.getSummary();

        expect(result.isRight(), true);
        result.fold((l) => fail('Should be Right'), (r) {
          expect(r.totalBalance, 100.0);
          expect(r.accountNumber, '123');
        });
      },
    );

    test(
      'should return Left(ServiceFailure) when ServerException occurs',
      () async {
        when(() => mockDataSource.getSummary()).thenThrow(
          const ServerException(
            where: 'summary',
            statusCode: 500,
            message: 'Error',
          ),
        );

        final result = await repository.getSummary();

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
        when(() => mockDataSource.getSummary()).thenThrow(
          const ParseException(where: 'summary', message: 'Parse error'),
        );

        final result = await repository.getSummary();

        expect(result.isLeft(), true);
        result.fold((l) {
          expect(l, isA<GeneralFailure>());
          expect(l.message, 'Parse error');
        }, (r) => fail('Should be Left'));
      },
    );

    test(
      'should return cached model when offline',
      () async {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(() => mockLocalStore.getSummary()).thenAnswer((_) async => tModel);

        final result = await repository.getSummary();

        expect(result.isRight(), true);
        result.fold((l) => fail('Should be Right'), (r) {
          expect(r.totalBalance, 100.0);
        });
      },
    );

    test(
      'should return Left(NotInternetFailure) when offline and no cache',
      () async {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(() => mockLocalStore.getSummary()).thenAnswer((_) async => null);

        final result = await repository.getSummary();

        expect(result.isLeft(), true);
        result.fold((l) {
          expect(l, isA<NotInternetFailure>());
          expect(l.message, 'No internet connection and no cached data available');
        }, (r) => fail('Should be Left'));
      },
    );
  });
}
