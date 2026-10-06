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

class DsbAccountEntity extends Equatable {
  const DsbAccountEntity({
    required this.accountName,
    required this.accountNumber,
    required this.balance,
    required this.createdAt,
    required this.isActive,
    required this.transactions,
  });

  final String accountName;
  final String accountNumber;
  final double balance;
  final DateTime createdAt;
  final bool isActive;
  final List<DsbTransactionEntity> transactions;

  @override
  List<Object?> get props => [accountName, accountNumber, balance, createdAt, isActive, transactions];
}

class DsbSummaryEntity extends Equatable {
  const DsbSummaryEntity({
    required this.accounts,
    this.dynamicBanner,
  });

  final List<DsbAccountEntity> accounts;
  final SduiNode? dynamicBanner;

  @override
  List<Object?> get props => [accounts, dynamicBanner];
}
