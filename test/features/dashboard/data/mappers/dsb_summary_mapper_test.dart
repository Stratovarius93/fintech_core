import 'package:flutter_test/flutter_test.dart';
import 'package:fintech_core/features/dashboard/data/models/dsb_summary_model.dart';
import 'package:fintech_core/features/dashboard/data/mappers/dsb_summary_mapper.dart';

void main() {
  group('DsbSummaryMapper', () {
    test('should correctly convert DsbSummaryModel to DsbSummaryEntity', () {
      final tDate = DateTime.now();
      final tModel = DsbSummaryModel(
        totalBalance: 150.0,
        accountNumber: '111',
        recentTransactions: [
          DsbTransactionModel(
            id: '1',
            amount: 20.0,
            date: tDate,
            description: 'Test',
            isCredit: true,
          ),
        ],
      );

      final entity = tModel.toEntity();

      expect(entity.totalBalance, 150.0);
      expect(entity.accountNumber, '111');
      expect(entity.recentTransactions.length, 1);
      
      final tx = entity.recentTransactions.first;
      expect(tx.id, '1');
      expect(tx.amount, 20.0);
      expect(tx.date, tDate);
      expect(tx.description, 'Test');
      expect(tx.isCredit, true);
    });

    test('should provide default values for null fields in Model', () {
      const tModel = DsbSummaryModel(
        totalBalance: null,
        accountNumber: null,
        recentTransactions: [
          DsbTransactionModel(
            id: null,
            amount: null,
            date: null,
            description: null,
            isCredit: null,
          ),
        ],
      );

      final entity = tModel.toEntity();

      expect(entity.totalBalance, 0.0);
      expect(entity.accountNumber, '');
      expect(entity.recentTransactions.length, 1);
      
      final tx = entity.recentTransactions.first;
      expect(tx.id, '');
      expect(tx.amount, 0.0);
      expect(tx.description, '');
      expect(tx.isCredit, false);
      expect(tx.date, isA<DateTime>());
    });
  });
}
