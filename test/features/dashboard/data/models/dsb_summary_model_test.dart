import 'package:flutter_test/flutter_test.dart';
import 'package:fintech_core/features/dashboard/data/models/dsb_summary_model.dart';

void main() {
  group('DsbSummaryModel', () {
    final tJson = {
      'accounts': [
        {
          'account_name': 'Test Account',
          'account_number': '0987654321',
          'balance': 1000.50,
          'created_at': '2023-11-24T23:49:13.000-05:00',
          'is_active': true,
          'transactions': [
            {
              'id': 'tx1',
              'date': '2023-11-24T23:49:13.000-05:00',
              'amount': 50.0,
              'description': 'Supermarket',
              'is_credit': false,
            }
          ]
        }
      ]
    };

    test('fromJson should parse correctly when all fields are present', () {
      final result = DsbSummaryModel.fromJson(tJson);

      expect(result.accounts?.length, 1);
      
      final account = result.accounts!.first;
      expect(account.balance, 1000.50);
      expect(account.accountNumber, '0987654321');
      expect(account.transactions?.length, 1);
      
      final tx = account.transactions!.first;
      expect(tx.id, 'tx1');
      expect(tx.amount, 50.0);
      expect(tx.description, 'Supermarket');
      expect(tx.isCredit, false);
      expect(tx.date, DateTime.parse('2023-11-24T23:49:13.000-05:00'));
    });

    test('fromJson should handle null fields gracefully', () {
      final result = DsbSummaryModel.fromJson(null);

      expect(result.accounts, null);
    });
  });
}
