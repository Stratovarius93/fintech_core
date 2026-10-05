import 'package:dio/dio.dart';
import 'package:fintech_core/core/errors/exceptions/parse_exception.dart';
import 'package:fintech_core/core/errors/exceptions/server_exception.dart';

/// A unified mixin to handle both network requests and JSON parsing safely.
/// It catches Dio exceptions for network issues and format exceptions for parsing errors,
/// throwing custom exceptions that the Repository will later catch and turn into [Failure].
mixin NetworkHandler {
  Future<T> handleRequest<T>({
    required Future<Response> Function() request,
    required T Function(dynamic data) mapper,
    required String requestName,
  }) async {
    Response response;

    // 1. Execute Network Request
    try {
      response = await request();
    } on DioException catch (err, stackTrace) {
      // Create and throw a detailed ServerException for Crashlytics
      throw ServerException(
        statusCode: err.response?.statusCode ?? -1,
        message: err.message ?? 'Unknown Dio error',
        where: requestName,
        stackTrace: stackTrace,
        customKeys: {
          "http_uri": "${err.requestOptions.uri}",
          "http_method": err.requestOptions.method,
        },
      );
    } catch (err, stackTrace) {
      throw ServerException(
        statusCode: -1,
        message: err.toString(),
        where: requestName,
        stackTrace: stackTrace,
      );
    }

    // 2. Execute Data Parsing
    try {
      return mapper(response.data);
    } catch (err, stackTrace) {
      // Throw a specific exception if the JSON mapping fails
      throw ParseException(
        message: 'Failed to parse JSON model',
        where: requestName,
        stackTrace: stackTrace,
      );
    }
  }
}
