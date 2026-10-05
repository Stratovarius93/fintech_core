import 'package:equatable/equatable.dart';

class AthUserEntity extends Equatable {
  final String id;
  final String email;
  final String token;
  final String segment;

  const AthUserEntity({
    required this.id,
    required this.email,
    required this.token,
    required this.segment,
  });

  @override
  List<Object?> get props => [id, email, token, segment];
}
