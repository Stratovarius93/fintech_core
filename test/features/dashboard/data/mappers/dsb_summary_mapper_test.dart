import 'package:flutter_test/flutter_test.dart';
import 'package:fintech_core/features/dashboard/data/models/dsb_summary_model.dart';
import 'package:fintech_core/features/dashboard/data/mappers/dsb_summary_mapper.dart';

void main() {
  group('DsbSummaryMapper', () {
    test('should correctly convert DsbSummaryModel to DsbSummaryEntity', () {
      final tDate = DateTime.now();
      final tModel = DsbSummaryModel(
        accounts: [
          DsbAccountModel(
            accountName: 'Test Account',
            accountNumber: '111',
            balance: 150.0,
            createdAt: tDate,
            isActive: true,
            transactions: [
              DsbTransactionModel(
                id: '1',
                amount: 20.0,
                date: tDate,
                description: 'Test',
                isCredit: true,
              ),
            ],
          )
        ]
      );

      final entity = tModel.toEntity();

      expect(entity.accounts.length, 1);
      final account = entity.accounts.first;
      
      expect(account.balance, 150.0);
      expect(account.accountNumber, '111');
      expect(account.transactions.length, 1);
      
      final tx = account.transactions.first;
      expect(tx.id, '1');
      expect(tx.amount, 20.0);
      expect(tx.date, tDate);
      expect(tx.description, 'Test');
      expect(tx.isCredit, true);
    });

    test('should provide default values for null fields in Model', () {
      const tModel = DsbSummaryModel(
        accounts: [
          DsbAccountModel(
            accountName: null,
            accountNumber: null,
            balance: null,
            createdAt: null,
            isActive: null,
            transactions: [
              DsbTransactionModel(
                id: null,
                amount: null,
                date: null,
                description: null,
                isCredit: null,
              ),
            ],
          )
        ]
      );

      final entity = tModel.toEntity();

      expect(entity.accounts.length, 1);
      final account = entity.accounts.first;
      
      expect(account.balance, 0.0);
      expect(account.accountNumber, '');
      expect(account.transactions.length, 1);
      
      final tx = account.transactions.first;
      expect(tx.id, '');
      expect(tx.amount, 0.0);
      expect(tx.description, '');
      expect(tx.isCredit, false);
      expect(tx.date, isA<DateTime>());
    });
  });
}
