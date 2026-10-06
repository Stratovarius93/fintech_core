import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Interceptor designed to simulate real-world degraded network conditions.
/// It injects random latency and occasional connection failures to ensure
/// the app handles edge cases smoothly as required by bank-grade standards.
class NetworkSimulatorInterceptor extends Interceptor {
  NetworkSimulatorInterceptor({
    this.enableSimulation = true,
    this.failureRate = 0.15, // 15% chance of network failure
    this.minLatency = const Duration(milliseconds: 1000),
    this.maxLatency = const Duration(milliseconds: 3000),
  }) : assert(maxLatency >= minLatency);

  final bool enableSimulation;
  final double failureRate;

  /// Lower bound of the simulated latency.
  final Duration minLatency;

  /// Upper bound of the simulated latency.
  final Duration maxLatency;
  final _random = Random();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!enableSimulation) {
      return super.onRequest(options, handler);
    }

    // 1. Simulate high latency (between minLatency and maxLatency)
    final spread = maxLatency.inMilliseconds - minLatency.inMilliseconds;
    final delay =
        minLatency.inMilliseconds + (spread > 0 ? _random.nextInt(spread) : 0);
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

    // 3. Mock data for specific endpoints
    if (options.path.contains('/auth/login')) {
      final data = options.data as Map<String, dynamic>?;
      final email = data?['email']?.toString();
      final password = data?['password']?.toString();

      if (email == 'user@bank.com' && password == '123456') {
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'data': {
                'id': 'u_123',
                'email': email,
                'token': 'mock_jwt_token_12345',
              },
            },
          ),
        );
      } else {
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(statusCode: 401, requestOptions: options),
            error: 'Invalid credentials',
          ),
        );
      }
    }

    if (options.path.contains('/dashboard/summary')) {
      Map<String, dynamic>? dynamicBanner;
      try {
        // Fetch real Server-Driven UI from Google Sheets
        final dio = Dio();
        final sduiUrl = dotenv.env['SDUI_URL'];
        if (sduiUrl != null && sduiUrl.isNotEmpty) {
          final bannerResponse = await dio.get(sduiUrl);

          var responseData = bannerResponse.data;
          if (responseData is String) {
            responseData = jsonDecode(responseData);
          }

          if (responseData is Map<String, dynamic>) {
            dynamicBanner = responseData;
          } else if (responseData is List && responseData.isNotEmpty) {
            dynamicBanner = responseData.first as Map<String, dynamic>;
          }
        }
      } catch (e) {
        // Fallback banner in case of external network failure
        dynamicBanner = {
          'type': 'banner',
          'properties': {
            'title': 'Fallback Pre-approved Loan!',
            'subtitle': 'You have a pre-approved loan of \$10,000.',
          },
        };
      }

      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'data': {
              'accounts': [
                {
                  'account_name': 'Checking Account',
                  'account_number': '**** 1234',
                  'balance': 5432.10,
                  'created_at': '2023-01-15T10:00:00Z',
                  'is_active': true,
                  'transactions': [
                    {
                      'id': 'tx_1',
                      'date': DateTime.now().toIso8601String(),
                      'amount': 150.0,
                      'description': 'Grocery Store',
                      'is_credit': false,
                    },
                    {
                      'id': 'tx_2',
                      'date': DateTime.now()
                          .subtract(const Duration(days: 1))
                          .toIso8601String(),
                      'amount': 2000.0,
                      'description': 'Payroll Salary',
                      'is_credit': true,
                    },
                  ],
                },
                {
                  'account_name': 'Savings Account',
                  'account_number': '**** 5678',
                  'balance': 12500.50,
                  'created_at': '2021-06-20T14:30:00Z',
                  'is_active': true,
                  'transactions': [
                    {
                      'id': 'tx_3',
                      'date': DateTime.now()
                          .subtract(const Duration(days: 5))
                          .toIso8601String(),
                      'amount': 500.0,
                      'description': 'Transfer to Savings',
                      'is_credit': true,
                    },
                  ],
                },
              ],
              'dynamic_banner': dynamicBanner,
            },
          },
        ),
      );
    }

    return super.onRequest(options, handler);
  }
}
