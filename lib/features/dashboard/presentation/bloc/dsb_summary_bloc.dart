import 'package:dartz/dartz.dart';
import 'package:fintech_core/core/data_async_value/base_async_value_bloc.dart';
import 'package:fintech_core/core/errors/failures.dart';
import 'package:fintech_core/features/dashboard/domain/entities/dsb_summary_entity.dart';
import 'package:fintech_core/features/dashboard/domain/repositories/interfaces/dsb_i_repository.dart';
import 'package:fintech_core/features/dashboard/presentation/bloc/dsb_summary_params.dart';

class DsbSummaryBloc extends BaseDataBloc<DsbSummaryEntity, DsbSummaryParams> {
  DsbSummaryBloc({required this.repository});

  final DsbIRepository repository;

  void getSummary() {
    call(const DsbSummaryParams());
  }

  @override
  Future<Either<Failure, DsbSummaryEntity>> repositoryCall(
    DsbSummaryParams? params,
  ) {
    return repository.getSummary();
  }
}
