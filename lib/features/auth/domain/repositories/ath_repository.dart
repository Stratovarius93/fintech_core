import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions/parse_exception.dart';
import '../../../../core/errors/exceptions/server_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/interfaces/ath_i_network_data_source.dart';
import '../../data/mappers/ath_user_mapper.dart';
import '../entities/ath_user_entity.dart';
import 'interfaces/ath_i_repository.dart';

class AthRepository implements AthIRepository {
  final AthINetworkDataSource _networkDataSource;

  AthRepository(this._networkDataSource);

  @override
  Future<Either<Failure, AthUserEntity>> login(String email, String password) async {
    try {
      final userModel = await _networkDataSource.login(email, password);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServiceFailure(e.message, code: e.statusCode));
    } on ParseException catch (e) {
      return Left(GeneralFailure(e.message));
    } catch (e) {
      return Left(const ServiceFailure('Unexpected error occurred', code: 500));
    }
  }
}
