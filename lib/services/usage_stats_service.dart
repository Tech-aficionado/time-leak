import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class UsageStatsService {
  static const MethodChannel _channel = MethodChannel(
    'com.timeleak/usage_stats',
  );

  /// Checks if the PACKAGE_USAGE_STATS permission is granted
  Future<bool> checkPermission() async {
    try {
      final bool hasPerm = await _channel.invokeMethod('checkPermission');
      return hasPerm;
    } on PlatformException catch (e) {
      debugPrint("Failed to check permission: '${e.message}'.");
      return false;
    }
  }

  /// Redirects user to the system settings to grant Usage Access
  Future<bool> requestPermission() async {
    try {
      final bool requested = await _channel.invokeMethod('requestPermission');
      return requested;
    } on PlatformException catch (e) {
      debugPrint("Failed to request permission: '${e.message}'.");
      return false;
    }
  }

  /// Get the usage stats for the given time range
  Future<List<Map<String, dynamic>>> getUsageStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final List<dynamic> stats = await _channel.invokeMethod('getUsageStats', {
        'startTime': startDate.millisecondsSinceEpoch,
        'endTime': endDate.millisecondsSinceEpoch,
      });
      return stats.map((e) => Map<String, dynamic>.from(e)).toList();
    } on PlatformException catch (e) {
      debugPrint("Failed to get usage stats: '${e.message}'.");
      return [];
    }
  }

  /// Get detailed app switch events (onResume, onPause) for the time range
  Future<List<Map<String, dynamic>>> getAppSwitches(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final List<dynamic> events = await _channel
          .invokeMethod('getAppSwitches', {
            'startTime': startDate.millisecondsSinceEpoch,
            'endTime': endDate.millisecondsSinceEpoch,
          });
      return events.map((e) => Map<String, dynamic>.from(e)).toList();
    } on PlatformException catch (e) {
      debugPrint("Failed to get app switches: '${e.message}'.");
      return [];
    }
  }

  /// Gets the human-readable label for a package
  Future<String> getAppLabel(String packageName) async {
    try {
      final String label = await _channel.invokeMethod('getAppLabel', {
        'packageName': packageName,
      });
      return label;
    } on PlatformException catch (e) {
      debugPrint("Failed to get app label for $packageName: '${e.message}'.");
      return packageName;
    }
  }

  /// Gets the app icon as a Uint8List (PNG bytes)
  Future<Uint8List?> getAppIcon(String packageName) async {
    try {
      final Uint8List? icon = await _channel.invokeMethod('getAppIcon', {
        'packageName': packageName,
      });
      return icon;
    } on PlatformException catch (e) {
      debugPrint("Failed to get app icon for $packageName: '${e.message}'.");
      return null;
    }
  }

  /// Gets the category of an app (integer constant from Android)
  Future<int> getAppCategory(String packageName) async {
    try {
      final int category = await _channel.invokeMethod('getAppCategory', {
        'packageName': packageName,
      });
      return category;
    } on PlatformException catch (e) {
      debugPrint("Failed to get app category for $packageName: '${e.message}'.");
      return -1;
    }
  }

  /// Start Android Strict Focus Mode (Screen Pinning / Lock Task)
  Future<bool> startFocusMode() async {
    try {
      final bool success = await _channel.invokeMethod('startFocusMode');
      return success;
    } on PlatformException catch (e) {
      debugPrint("Failed to start focus mode: '${e.message}'.");
      return false;
    }
  }

  /// Stop Android Strict Focus Mode
  Future<bool> stopFocusMode() async {
    try {
      final bool success = await _channel.invokeMethod('stopFocusMode');
      return success;
    } on PlatformException catch (e) {
      debugPrint("Failed to stop focus mode: '${e.message}'.");
      return false;
    }
  }
}
