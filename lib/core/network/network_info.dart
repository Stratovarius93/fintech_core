import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkInfo {
  // Singleton pattern implementation
  NetworkInfo._internal() {
    _checker = InternetConnection.createInstance(
      customCheckOptions: [
        InternetCheckOption(
          // Example of pinging a reliable service or the bank's own health endpoint
          uri: Uri.parse('https://api.bancointernacional.com.ec/health'),
          timeout: const Duration(seconds: 3),
        ),
      ],
    );
  }

  static NetworkInfo _instance = NetworkInfo._internal();
  static NetworkInfo get instance => _instance;

  @visibleForTesting
  static set instance(NetworkInfo value) => _instance = value;

  late final InternetConnection _checker;

  /// Returns true if there is an active internet connection according to the ping checks
  Future<bool> get isConnected => _checker.hasInternetAccess;
}
