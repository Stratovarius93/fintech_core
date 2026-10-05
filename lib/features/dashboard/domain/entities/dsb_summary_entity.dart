import 'package:equatable/equatable.dart';
import 'package:fintech_core/core/sdui/sdui_node.dart';

class DsbTransactionEntity extends Equatable {
  const DsbTransactionEntity({
    required this.id,
    required this.date,
    required this.amount,
    required this.description,
    required this.isCredit,
  });

  final String id;
  final DateTime date;
  final double amount;
  final String description;
  final bool isCredit;

  @override
  List<Object?> get props => [id, date, amount, description, isCredit];
}

class DsbSummaryEntity extends Equatable {
  const DsbSummaryEntity({
    required this.totalBalance,
    required this.accountNumber,
    required this.recentTransactions,
    this.dynamicBanner,
  });

  final double totalBalance;
  final String accountNumber;
  final List<DsbTransactionEntity> recentTransactions;
  final SduiNode? dynamicBanner;

  @override
  List<Object?> get props => [totalBalance, accountNumber, recentTransactions, dynamicBanner];
}
