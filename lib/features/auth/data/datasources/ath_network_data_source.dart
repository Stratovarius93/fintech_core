import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_handler.dart';
import '../models/ath_user_model.dart';
import 'interfaces/ath_i_network_data_source.dart';

class AthNetworkDataSource with NetworkHandler implements AthINetworkDataSource {
  final DioClient _dioClient;

  AthNetworkDataSource(this._dioClient);

  @override
  Future<AthUserModel> login(String email, String password) async {
    return handleRequest<AthUserModel>(
      request: () => _dioClient.instance.post('/api/v1/auth/login', data: {
        'email': email,
        'password': password,
      }),
      mapper: (data) => AthUserModel.fromJson(data['data']),
      requestName: 'AUTH_LOGIN',
    );
  }
}
