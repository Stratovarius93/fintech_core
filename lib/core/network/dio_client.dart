import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'network_simulator_interceptor.dart';

/// Centralized HTTP client configured with base options, logging,
/// and the network chaos simulator for testing resilience.
class DioClient {
  /// [simulator] can be injected to control latency/failure rate
  /// (e.g. deterministic E2E tests). Defaults to the random chaos simulator.
  DioClient({NetworkSimulatorInterceptor? simulator}) {
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('API_BASE_URL is not configured in the environment variables.');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add the chaos simulator (you can toggle this via environment variables later)
    _dio.interceptors.add(simulator ?? NetworkSimulatorInterceptor());

    // Add standard logging for debugging requests and responses
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[DIO LOG] $obj'),
      ),
    );
  }

  late final Dio _dio;

  Dio get instance => _dio;
}
