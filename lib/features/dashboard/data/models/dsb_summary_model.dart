import 'package:equatable/equatable.dart';
import 'package:fintech_core/core/network/json_map.dart';
import 'package:fintech_core/core/sdui/sdui_node.dart';

class DsbTransactionModel extends Equatable {
  const DsbTransactionModel({
    this.id,
    this.date,
    this.amount,
    this.description,
    this.isCredit,
  });

  factory DsbTransactionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DsbTransactionModel();
    final jsonMap = JsonMap(json);
    return DsbTransactionModel(
      id: jsonMap.mapToStringOrNull(['id']),
      date: jsonMap.mapToDateTimeOrNull(['date']),
      amount: jsonMap.mapToDouble(['amount']),
      description: jsonMap.mapToStringOrNull(['description']),
      isCredit: jsonMap.mapToBool(['is_credit']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date?.toIso8601String(),
      'amount': amount,
      'description': description,
      'is_credit': isCredit,
    };
  }

  final String? id;
  final DateTime? date;
  final double? amount;
  final String? description;
  final bool? isCredit;

  @override
  List<Object?> get props => [id, date, amount, description, isCredit];
}

class DsbAccountModel extends Equatable {
  const DsbAccountModel({
    this.accountName,
    this.accountNumber,
    this.balance,
    this.createdAt,
    this.isActive,
    this.transactions,
  });

  factory DsbAccountModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DsbAccountModel();
    final jsonMap = JsonMap(json);
    return DsbAccountModel(
      accountName: jsonMap.mapToStringOrNull(['account_name']),
      accountNumber: jsonMap.mapToStringOrNull(['account_number']),
      balance: jsonMap.mapToDouble(['balance']),
      createdAt: jsonMap.mapToDateTimeOrNull(['created_at']),
      isActive: jsonMap.mapToBool(['is_active']),
      transactions: jsonMap.mapToList<DsbTransactionModel>(
        ['transactions'],
        (item) => DsbTransactionModel.fromJson(item as Map<String, dynamic>?),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_name': accountName,
      'account_number': accountNumber,
      'balance': balance,
      'created_at': createdAt?.toIso8601String(),
      'is_active': isActive,
      'transactions': transactions?.map((x) => x.toJson()).toList(),
    };
  }

  final String? accountName;
  final String? accountNumber;
  final double? balance;
  final DateTime? createdAt;
  final bool? isActive;
  final List<DsbTransactionModel>? transactions;

  @override
  List<Object?> get props => [accountName, accountNumber, balance, createdAt, isActive, transactions];
}

class DsbSummaryModel extends Equatable {
  const DsbSummaryModel({
    this.accounts,
    this.dynamicBanner,
  });

  factory DsbSummaryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DsbSummaryModel();
    final jsonMap = JsonMap(json);
    return DsbSummaryModel(
      accounts: jsonMap.mapToList<DsbAccountModel>(
        ['accounts'],
        (item) => DsbAccountModel.fromJson(item as Map<String, dynamic>?),
      ),
      dynamicBanner: jsonMap.mapIsExist('dynamic_banner')
          ? SduiNode.fromJson(jsonMap.mapToMap('dynamic_banner'))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accounts': accounts?.map((x) => x.toJson()).toList(),
      'dynamic_banner': dynamicBanner?.toJson(),
    };
  }

  final List<DsbAccountModel>? accounts;
  final SduiNode? dynamicBanner;

  @override
  List<Object?> get props => [accounts, dynamicBanner];
}
