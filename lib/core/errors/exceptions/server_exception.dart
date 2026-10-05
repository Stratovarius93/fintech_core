import 'package:flutter/foundation.dart';

/// Exception thrown when a network request fails or the server returns an error.
class ServerException implements Exception {
  const ServerException({
    required this.where,
    required this.statusCode,
    this.message = '',
    this.responseData,
    this.stackTrace,
    this.customKeys,
  });

  /// The name of the request or feature where the error occurred.
  final String where;

  /// The HTTP status code (e.g., 500, 404, or -1 for connection timeouts).
  final int statusCode;

  /// The error message provided by Dio or the Server.
  final dynamic message;

  /// The raw response data, useful for debugging backend validation errors.
  final Map<String, dynamic>? responseData;

  /// The stack trace to track the exact line of failure.
  final StackTrace? stackTrace;

  /// Additional metadata to log (e.g., request URI, HTTP method).
  final Map<String, String>? customKeys;

  @override
  String toString() {
    final logMessage =
        'ServerException(WHERE: $where, STATUS: $statusCode, MESSAGE: $message)';

    // In a real app, this is where you would send data to Datadog, Sentry, or Crashlytics.
    // For this technical test, we log it clearly to the console in debug mode.
    if (kDebugMode) {
      debugPrint('🔴 [NETWORK ERROR] $logMessage');
      if (customKeys != null && customKeys!.isNotEmpty) {
        debugPrint('   ↳ Metadata: $customKeys');
      }
    }

    return logMessage;
  }
}
