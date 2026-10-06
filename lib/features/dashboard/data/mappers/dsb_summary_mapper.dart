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

extension DsbAccountModelX on DsbAccountModel {
  DsbAccountEntity toEntity() {
    return DsbAccountEntity(
      accountName: accountName ?? '',
      accountNumber: accountNumber ?? '',
      balance: balance ?? 0.0,
      createdAt: createdAt ?? DateTime.now(),
      isActive: isActive ?? false,
      transactions: transactions?.map((e) => e.toEntity()).toList() ?? [],
    );
  }
}

extension DsbSummaryModelX on DsbSummaryModel {
  DsbSummaryEntity toEntity() {
    return DsbSummaryEntity(
      accounts: accounts?.map((e) => e.toEntity()).toList() ?? [],
      dynamicBanner: dynamicBanner,
    );
  }
}
