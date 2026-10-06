import 'package:flutter/material.dart';
import 'package:fintech_core/core/services/push_notification_service.dart';

class FraudAlertSimulator {
  FraudAlertSimulator._internal();
  static final FraudAlertSimulator instance = FraudAlertSimulator._internal();

  Future<void> simulate(BuildContext context) async {
    final isGranted = await PushNotificationService.instance.requestPermission();
    if (!context.mounted) return;

    if (!isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifications are disabled. Please enable them in settings to simulate the alert.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulating external alert in 3 seconds...')),
    );
    
    await Future.delayed(const Duration(seconds: 3));
    
    PushNotificationService.instance.showNotification(
      title: '⚠️ Fraud Alert',
      body: 'An unusual charge of \$499.99 USD was detected. Tap to block your card.',
    );
  }
}
