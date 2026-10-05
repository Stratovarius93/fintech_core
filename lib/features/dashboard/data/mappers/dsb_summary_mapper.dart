import 'package:fintech_core/features/dashboard/data/models/dsb_summary_model.dart';
import 'package:fintech_core/features/dashboard/domain/entities/dsb_summary_entity.dart';

extension DsbTransactionModelX on DsbTransactionModel {
  DsbTransactionEntity toEntity() {
    return DsbTransactionEntity(
      id: id ?? '',
      date: date ?? DateTime.now(),
      amount: amount ?? 0.0,
      description: description ?? '',
      isCredit: isCredit ?? false,
    );
  }
}

extension DsbSummaryModelX on DsbSummaryModel {
  DsbSummaryEntity toEntity() {
    return DsbSummaryEntity(
      totalBalance: totalBalance ?? 0.0,
      accountNumber: accountNumber ?? '',
      recentTransactions:
          recentTransactions?.map((e) => e.toEntity()).toList() ?? [],
      dynamicBanner: dynamicBanner,
    );
  }
}
