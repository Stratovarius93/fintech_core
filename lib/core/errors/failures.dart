import 'package:equatable/equatable.dart';

/// Base class for handling controlled failures across the app.
/// Using a sealed class allows exhaustive pattern matching (switch statements)
/// ensuring no error state is left unhandled in the presentation layer.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Used for unexpected or generic application errors.
class GeneralFailure extends Failure {
  const GeneralFailure(super.message);
}

/// Used for API/Network errors (e.g., server crashes, timeouts, or simulated network chaos).
class ServiceFailure extends Failure {
  const ServiceFailure(super.message, {required this.code});

  final int code;

  @override
  List<Object?> get props => [message, code];
}

/// Used for local storage or cache errors (e.g., Hive database read/write issues).
class LocalFailure extends Failure {
  const LocalFailure(super.msg);
}

/// Specific failure for third-party analytics/engagement tools.
class CleverTapFailure extends Failure {
  const CleverTapFailure(super.msg);
}

/// Used when the API returns a 429 status code.
class RateLimitExceededFailure extends Failure {
  const RateLimitExceededFailure(super.msg);
}

/// Used for 400 status codes (e.g., invalid parameters sent to the API).
class BadRequestFailure extends Failure {
  const BadRequestFailure(super.msg);
}

/// Used to pass informational messages that are treated as soft failures
/// (e.g., specific business rule violations).
class InformativeFailure extends Failure {
  const InformativeFailure(super.msg);
}

/// Used when client/device information is invalid or missing.
class IncorrectClientInfoFailure extends Failure {
  const IncorrectClientInfoFailure(super.msg);
}

/// Used when there is no active internet connection and no cached data is available.
class NotInternetFailure extends Failure {
  const NotInternetFailure([super.message = 'No internet connection available']);
}
