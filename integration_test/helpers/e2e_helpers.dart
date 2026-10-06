import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fintech_core/core/network/network_info.dart';
import 'package:fintech_core/core/utils/permission_util.dart';

/// Controllable connectivity used to simulate going offline / back online
/// during the E2E flow without touching the device radio.
class FakeNetworkInfo implements NetworkInfo {
  bool connected = true;

  @override
  Future<bool> get isConnected async => connected;
}

/// Skips the native push-permission dialog, which integration tests
/// cannot interact with (it is rendered by the OS, not by Flutter).
class FakePermissionUtil implements PermissionUtil {
  @override
  Future<void> requestPushPermissionWithWarning(BuildContext context) async {}
}

extension PumpUntilX on WidgetTester {
  /// Pumps frames (real time in integration tests) until [finder] matches.
  /// Prefer this over `pumpAndSettle` when the simulator adds latency or
  /// infinite animations (e.g. progress indicators) are on screen.
  Future<void> pumpUntilFound(
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await pump(const Duration(milliseconds: 100));
      if (any(finder)) return;
    }
    throw TestFailure('Timed out after $timeout waiting for: $finder');
  }

  /// Pumps frames until [finder] no longer matches anything.
  Future<void> pumpUntilGone(
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await pump(const Duration(milliseconds: 100));
      if (!any(finder)) return;
    }
    throw TestFailure('Timed out after $timeout waiting to disappear: $finder');
  }
}
