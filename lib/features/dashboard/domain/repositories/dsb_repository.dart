import 'package:dartz/dartz.dart';
import 'package:fintech_core/core/errors/failures.dart';
import 'package:fintech_core/core/errors/exceptions/server_exception.dart';
import 'package:fintech_core/core/errors/exceptions/parse_exception.dart';
import 'package:fintech_core/core/network/network_info.dart';
import 'package:fintech_core/features/dashboard/data/datasources/dsb_local_store.dart';
import 'package:fintech_core/features/dashboard/data/datasources/dsb_network_data_source.dart';
import 'package:fintech_core/features/dashboard/data/mappers/dsb_summary_mapper.dart';
import 'package:fintech_core/features/dashboard/domain/entities/dsb_summary_entity.dart';
import 'package:fintech_core/features/dashboard/domain/repositories/interfaces/dsb_i_repository.dart';

class DsbRepository implements DsbIRepository {
  DsbRepository({
    required this.dataSource,
    required this.networkInfo,
    required this.localStore,
  });

  final DsbNetworkDataSource dataSource;
  final NetworkInfo networkInfo;
  final DsbLocalStore localStore;

  @override
  Future<Either<Failure, DsbSummaryEntity>> getSummary() async {
    if (await networkInfo.isConnected) {
      try {
        final model = await dataSource.getSummary();
        
        // Save the latest successful response to local cache
        localStore.saveSummary(model);
        
        return Right(model.toEntity());
      } on ServerException catch (e) {
        return Left(ServiceFailure(e.message, code: e.statusCode));
      } on ParseException catch (e) {
        return Left(GeneralFailure(e.message));
      } catch (e) {
        return Left(const ServiceFailure('Unexpected error occurred', code: 500));
      }
    } else {
      // Attempt to retrieve from local cache when offline
      final cachedModel = await localStore.getSummary();
      if (cachedModel != null) {
        return Right(cachedModel.toEntity());
      } else {
        return Left(const NotInternetFailure('No internet connection and no cached data available'));
      }
    }
  }
}
