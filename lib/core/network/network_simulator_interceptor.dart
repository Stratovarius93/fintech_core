import 'dart:math';
import 'package:dio/dio.dart';

/// Interceptor designed to simulate real-world degraded network conditions.
/// It injects random latency and occasional connection failures to ensure
/// the app handles edge cases smoothly as required by bank-grade standards.
class NetworkSimulatorInterceptor extends Interceptor {
  NetworkSimulatorInterceptor({
    this.enableSimulation = true,
    this.failureRate = 0.15, // 15% chance of network failure
  });

  final bool enableSimulation;
  final double failureRate;
  final _random = Random();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!enableSimulation) {
      return super.onRequest(options, handler);
    }

    // 1. Simulate high latency (1000ms to 3000ms delay)
    final delay = _random.nextInt(2000) + 1000;
    await Future.delayed(Duration(milliseconds: delay));

    // 2. Simulate partial unavailability or timeout
    final shouldFail = _random.nextDouble() < failureRate;

    if (shouldFail) {
      // Reject the request before it even reaches the real network
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
          error: 'Simulated connection timeout (Bank requirement test)',
        ),
      );
    }

    return super.onRequest(options, handler);
  }
}
