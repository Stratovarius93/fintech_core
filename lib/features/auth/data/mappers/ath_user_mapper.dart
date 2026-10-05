import '../../domain/entities/ath_user_entity.dart';
import '../models/ath_user_model.dart';

extension AthUserMapper on AthUserModel {
  AthUserEntity toEntity() => AthUserEntity(
        id: id,
        email: email,
        token: token,
        segment: segment,
      );
}
