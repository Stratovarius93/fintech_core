import 'package:dartz/dartz.dart';
import 'package:fintech_core/core/errors/failures.dart';
import 'package:fintech_core/core/errors/exceptions/server_exception.dart';
import 'package:fintech_core/core/errors/exceptions/parse_exception.dart';
import 'package:fintech_core/features/dashboard/data/datasources/dsb_network_data_source.dart';
import 'package:fintech_core/features/dashboard/data/mappers/dsb_summary_mapper.dart';
import 'package:fintech_core/features/dashboard/domain/entities/dsb_summary_entity.dart';
import 'package:fintech_core/features/dashboard/domain/repositories/interfaces/dsb_i_repository.dart';

class DsbRepository implements DsbIRepository {
  const DsbRepository({required this.dataSource});

  final DsbNetworkDataSource dataSource;

  @override
  Future<Either<Failure, DsbSummaryEntity>> getSummary() async {
    try {
      final model = await dataSource.getSummary();
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServiceFailure(e.message, code: e.statusCode));
    } on ParseException catch (e) {
      return Left(GeneralFailure(e.message));
    } catch (e) {
      return Left(const ServiceFailure('Unexpected error occurred', code: 500));
    }
  }
}
