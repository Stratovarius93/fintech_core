import 'package:flutter/material.dart';
import 'package:fintech_core/core/services/push_notification_service.dart';

class PermissionUtil {
  PermissionUtil._internal();
  static final PermissionUtil instance = PermissionUtil._internal();

  /// Requests push notification permissions and shows a warning SnackBar if denied.
  Future<void> requestPushPermissionWithWarning(BuildContext context) async {
    final isGranted = await PushNotificationService.instance.requestPermission();
    if (!context.mounted) return;

    if (!isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifications denied. We suggest enabling them in settings for better security.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
