import '../../models/ath_user_model.dart';

abstract class AthINetworkDataSource {
  Future<AthUserModel> login(String email, String password);
}
