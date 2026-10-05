import '../../../../../core/data_async_value/params/base_async_value_params.dart';

class AthAuthParams extends BaseAsyncValueParams {
  const AthAuthParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}
