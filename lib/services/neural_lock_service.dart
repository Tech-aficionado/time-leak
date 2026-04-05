import 'package:do_not_disturb/do_not_disturb.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'dart:async';
import 'dart:io';

class NeuralLockService {
  static final NeuralLockService _instance = NeuralLockService._internal();
  factory NeuralLockService() => _instance;
  NeuralLockService._internal();

  final _dndPlugin = DoNotDisturbPlugin();
  bool _isLocked = false;
  bool get isLocked => _isLocked;

  /// Check if we have notification policy access (required for DND)
  Future<bool> hasDndAccess() async {
    if (!Platform.isAndroid) return true;
    return await _dndPlugin.isNotificationPolicyAccessGranted();
  }

  /// Open system settings for DND access
  Future<void> requestDndAccess() async {
    if (Platform.isAndroid) {
      await _dndPlugin.openNotificationPolicyAccessSettings();
    }
  }

  /// Enable full lockdown: Priority DND + App Pinning
  Future<void> enableLock() async {
    if (_isLocked) return;
    
    // 1. Enable DND (Priority Only)
    // This allows favorites if configured in system settings
    if (Platform.isAndroid && await hasDndAccess()) {
      await _dndPlugin.setInterruptionFilter(InterruptionFilter.priority);
    }
    
    // 2. Enable Kiosk Mode (App Pinning)
    try {
      await startKioskMode();
    } catch (e) {
      // Might fail if not supported or user cancels
      // Graceful fail
    }
    
    _isLocked = true;
  }

  /// Disable lockdown and restore system state
  Future<void> disableLock() async {
    // If not locked, we still try a "safe" unpin just in case the system 
    // got pinned without our internal flag being updated.
    if (!_isLocked) {
      try {
        await stopKioskMode();
      } catch (_) {}
      return;
    }
    
    // 1. Restore DND (Allow All)
    try {
      if (Platform.isAndroid && await hasDndAccess()) {
        await _dndPlugin.setInterruptionFilter(InterruptionFilter.all);
      }
    } catch (e) {
      // Restoration fail
    }
    
    // 2. Disable Kiosk Mode (Unpin)
    try {
      await stopKioskMode();
      // Small delay to allow OS to process the unpinning event
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      // Disable fail
    }
    
    _isLocked = false;
  }

  /// Monitor if the user unpinned the app
  Stream<KioskMode> get kioskModeStream => watchKioskMode();
}
