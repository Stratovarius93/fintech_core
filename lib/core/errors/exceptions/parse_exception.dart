import 'package:flutter/foundation.dart';
import '../../services/crashlytics_service.dart';

/// Exception thrown when the application fails to parse a JSON payload into a Dart model.
class ParseException implements Exception {
  ParseException({
    required this.where,
    this.message = 'Failed to parse JSON data',
    this.stackTrace,
  }) {
    CrashlyticsService.instance.recordError(this, stackTrace, reason: 'JSON Parse Error in $where');
  }

  /// The name of the request or feature where the parsing failed.
  final String where;

  /// A descriptive message about the parsing failure.
  final String message;

  /// The stack trace to track the exact line of the parsing failure.
  final StackTrace? stackTrace;

  @override
  String toString() {
    final logMessage = 'ParseException(WHERE: $where, MESSAGE: $message)';

    if (kDebugMode) {
      debugPrint('🟠 [PARSE ERROR] $logMessage');
      if (stackTrace != null) {
        debugPrint('   ↳ StackTrace: $stackTrace');
      }
    }

    return logMessage;
  }
}
