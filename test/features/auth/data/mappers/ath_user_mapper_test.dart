import 'package:flutter_test/flutter_test.dart';
import 'package:fintech_core/features/auth/data/models/ath_user_model.dart';
import 'package:fintech_core/features/auth/data/mappers/ath_user_mapper.dart';
import 'package:fintech_core/features/auth/domain/entities/ath_user_entity.dart';

void main() {
  test('AthUserMapper should correctly convert AthUserModel to AthUserEntity', () {
    const model = AthUserModel(
      id: '1',
      email: 'a@b.com',
      token: 'token',
      segment: 'NORMAL',
    );

    final entity = model.toEntity();

    expect(entity, isA<AthUserEntity>());
    expect(entity.id, '1');
    expect(entity.email, 'a@b.com');
    expect(entity.token, 'token');
    expect(entity.segment, 'NORMAL');
  });
}
