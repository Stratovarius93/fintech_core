import '../../../../core/network/json_map.dart';

class AthUserModel {
  factory AthUserModel.fromJson(dynamic json) {
    final j = JsonMap(json as Map<String, dynamic>);
    return AthUserModel(
      id: j.mapToString(['id']),
      email: j.mapToString(['email']),
      token: j.mapToString(['token']),
      segment: j.mapToString(['segment']),
    );
  }

  const AthUserModel({
    required this.id,
    required this.email,
    required this.token,
    required this.segment,
  });

  final String id;
  final String email;
  final String token;
  final String segment;
}
