import 'package:flutter_test/flutter_test.dart';
import 'package:fintech_core/features/auth/data/models/ath_user_model.dart';

void main() {
  group('AthUserModel', () {
    test('fromJson should parse correctly when all fields are present', () {
      final json = {
        'id': '123',
        'email': 'test@bank.com',
        'token': 'abc.def.ghi',
        'segment': 'PREMIUM',
      };

      final result = AthUserModel.fromJson(json);

      expect(result.id, '123');
      expect(result.email, 'test@bank.com');
      expect(result.token, 'abc.def.ghi');
      expect(result.segment, 'PREMIUM');
    });

    test('fromJson should handle null fields gracefully using JsonMap', () {
      final json = {
        'id': null,
        'email': null,
      };

      final result = AthUserModel.fromJson(json);

      expect(result.id, '');
      expect(result.email, '');
      expect(result.token, '');
      expect(result.segment, '');
    });
  });
}
