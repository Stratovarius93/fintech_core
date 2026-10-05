import 'package:flutter_test/flutter_test.dart';
import 'package:fintech_core/features/dashboard/data/models/dsb_summary_model.dart';

void main() {
  group('DsbSummaryModel', () {
    final tJson = {
      'total_balance': 1000.50,
      'account_number': '0987654321',
      'recent_transactions': [
        {
          'id': 'tx1',
          'date': '2023-11-24T23:49:13-05:00',
          'amount': 50.0,
          'description': 'Supermarket',
          'is_credit': false,
        }
      ]
    };

    test('fromJson should parse correctly when all fields are present', () {
      final result = DsbSummaryModel.fromJson(tJson);

      expect(result.totalBalance, 1000.50);
      expect(result.accountNumber, '0987654321');
      expect(result.recentTransactions?.length, 1);
      
      final tx = result.recentTransactions!.first;
      expect(tx.id, 'tx1');
      expect(tx.amount, 50.0);
      expect(tx.description, 'Supermarket');
      expect(tx.isCredit, false);
      expect(tx.date, DateTime.parse('2023-11-24T23:49:13-05:00'));
    });

    test('fromJson should handle null fields gracefully', () {
      final result = DsbSummaryModel.fromJson(null);

      expect(result.totalBalance, null);
      expect(result.accountNumber, null);
      expect(result.recentTransactions, null);
    });
  });
}
