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

class DsbSummaryModel extends Equatable {
  const DsbSummaryModel({
    this.totalBalance,
    this.accountNumber,
    this.recentTransactions,
    this.dynamicBanner,
  });

  factory DsbSummaryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DsbSummaryModel();
    final jsonMap = JsonMap(json);
    return DsbSummaryModel(
      totalBalance: jsonMap.mapToDouble(['total_balance']),
      accountNumber: jsonMap.mapToStringOrNull(['account_number']),
      recentTransactions: jsonMap.mapToList<DsbTransactionModel>(
        ['recent_transactions'],
        (item) => DsbTransactionModel.fromJson(item as Map<String, dynamic>?),
      ),
      dynamicBanner: jsonMap.mapIsExist('dynamic_banner')
          ? SduiNode.fromJson(jsonMap.mapToMap('dynamic_banner'))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_balance': totalBalance,
      'account_number': accountNumber,
      'recent_transactions': recentTransactions?.map((x) => x.toJson()).toList(),
      'dynamic_banner': dynamicBanner?.toJson(),
    };
  }

  final double? totalBalance;
  final String? accountNumber;
  final List<DsbTransactionModel>? recentTransactions;
  final SduiNode? dynamicBanner;

  @override
  List<Object?> get props => [totalBalance, accountNumber, recentTransactions, dynamicBanner];
}
