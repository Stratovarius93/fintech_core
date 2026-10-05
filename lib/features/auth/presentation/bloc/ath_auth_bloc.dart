import 'package:dartz/dartz.dart';

import '../../../../core/data_async_value/base_async_value_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ath_user_entity.dart';
import '../../domain/repositories/interfaces/ath_i_repository.dart';
import 'ath_auth_params.dart';

class AthAuthBloc extends BaseDataBloc<AthUserEntity, AthAuthParams> {
  AthAuthBloc({required this.repository});

  final AthIRepository repository;

  void login(String email, String password) {
    call(AthAuthParams(email: email, password: password));
  }

  @override
  Future<Either<Failure, AthUserEntity>> repositoryCall(
    AthAuthParams? params,
  ) =>
      repository.login(params!.email, params.password);
}
