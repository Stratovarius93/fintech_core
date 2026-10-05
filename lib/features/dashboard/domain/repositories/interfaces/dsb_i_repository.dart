import 'package:dartz/dartz.dart';
import 'package:fintech_core/core/errors/failures.dart';
import 'package:fintech_core/features/dashboard/domain/entities/dsb_summary_entity.dart';

abstract class DsbIRepository {
  Future<Either<Failure, DsbSummaryEntity>> getSummary();
}
