import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../entities/ath_user_entity.dart';

abstract class AthIRepository {
  Future<Either<Failure, AthUserEntity>> login(String email, String password);
}
