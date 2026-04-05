import 'dart:async';
import 'package:flutter/material.dart';
import 'local_storage_service.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'supabase_service.dart';
import 'usage_tracking_service.dart';
import '../models/focus_session.dart';
import 'package:isar/isar.dart';
import 'neural_lock_service.dart';

enum FocusStatus { idle, active, completed, interrupted }

class FocusModeService with WidgetsBindingObserver {
  static final FocusModeService _instance = FocusModeService._internal();
  factory FocusModeService() => _instance;
  
  FocusModeService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  final LocalStorageService _storage = LocalStorageService();
  final NeuralLockService _lockService = NeuralLockService();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final SupabaseService _supabaseService = SupabaseService();
  final UsageTrackingService _trackingService = UsageTrackingService();
  
  FocusSession? _activeSession;
  Timer? _timer;
  
  final _statusController = StreamController<FocusStatus>.broadcast();
  Stream<FocusStatus> get statusStream => _statusController.stream;
  
  final _remainingController = StreamController<Duration>.broadcast();
  Stream<Duration> get remainingStream => _remainingController.stream;

  FocusStatus _currentStatus = FocusStatus.idle;
  FocusStatus get currentStatus => _currentStatus;
  
  bool? lastSessionSuccess;
  Duration lastSessionDuration = Duration.zero;
  
  FocusSession? get activeSession => _activeSession;
  bool strictMode = true;

  Future<void> init() async {
    // Check for unfinished sessions in Isar
    final unfinished = await _storage.isar.focusSessions
        .filter()
        .endTimeIsNull()
        .findFirst();
        
    if (unfinished != null) {
      final now = DateTime.now();
      final elapsed = now.difference(unfinished.startTime);
      final planned = Duration(milliseconds: unfinished.plannedDurationMs);
      
      if (elapsed < planned) {
        // Resume session
        _activeSession = unfinished;
        _currentStatus = FocusStatus.active;
        _startTimer(planned - elapsed);
      } else {
        // Mark as completed in the past
        unfinished.endTime = unfinished.startTime.add(planned);
        unfinished.actualDurationMs = unfinished.plannedDurationMs;
        unfinished.isSuccessful = true;
        await _storage.updateFocusSession(unfinished);
      }
    }
  }

  Future<void> startSession(Duration duration, bool strict) async {
    if (_activeSession != null) return;
    
    strictMode = strict;
    final session = FocusSession()
      ..startTime = DateTime.now()
      ..plannedDurationMs = duration.inMilliseconds
      ..isSuccessful = false;
      
    await _storage.saveFocusSession(session);
    
    if (strictMode) {
      await _lockService.enableLock();
    }
    
    _activeSession = session;
    _currentStatus = FocusStatus.active;
    _statusController.add(FocusStatus.active);
    
    _startTimer(duration);
  }

  void _startTimer(Duration duration) {
    _timer?.cancel();
    _remainingController.add(duration);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final elapsed = DateTime.now().difference(_activeSession!.startTime);
      final remaining = duration - elapsed;
      
      if (remaining.inSeconds <= 0) {
        timer.cancel();
        await completeSession();
      } else {
        _remainingController.add(remaining);
      }
    });
  }

  Future<void> completeSession() async {
    if (_activeSession == null) return;
    
    _timer?.cancel();
    _activeSession!.endTime = DateTime.now();
    _activeSession!.actualDurationMs = _activeSession!.plannedDurationMs;
    _activeSession!.isSuccessful = true;
    
    lastSessionSuccess = true;
    lastSessionDuration = Duration(milliseconds: _activeSession!.actualDurationMs!);
    
    await _storage.updateFocusSession(_activeSession!);
    
    if (strictMode) {
      await _lockService.disableLock();
    }
    
    _currentStatus = FocusStatus.completed;
    _statusController.add(FocusStatus.completed);
    final completedSession = _activeSession!;
    _activeSession = null;
    await _onSessionEnd(completedSession);
  }

  Future<void> interruptSession() async {
    if (_activeSession == null) return;
    
    _timer?.cancel();
    _activeSession!.endTime = DateTime.now();
    _activeSession!.actualDurationMs = _activeSession!.endTime!.difference(_activeSession!.startTime).inMilliseconds;
    _activeSession!.isSuccessful = false;
    
    lastSessionSuccess = false;
    lastSessionDuration = Duration(milliseconds: _activeSession!.actualDurationMs!);
    
    await _storage.updateFocusSession(_activeSession!);
    
    if (strictMode) {
      await _lockService.disableLock();
    }
    
    _currentStatus = FocusStatus.interrupted;
    _statusController.add(FocusStatus.interrupted);
    final interruptedSession = _activeSession!;
    _activeSession = null;
    await _onSessionEnd(interruptedSession);
  }

  /// Called after every session end (complete or interrupt).
  /// Triggers a global data refresh and syncs the session to Supabase + Firestore.
  Future<void> _onSessionEnd(FocusSession session) async {
    // 1. Trigger immediate data refresh so Home/Profile/Rank reflect new stats
    _trackingService.refreshData();

    // 2. Sync to cloud backends if logged in
    final user = _authService.currentUser;
    if (user != null) {
      // Primary: Supabase — uid sourced from the active Supabase session
      try {
        await _supabaseService.syncFocusSession(session);
      } catch (e) {
        debugPrint('[FocusModeService] Supabase focus session sync failed: $e');
      }
      // Secondary: Firestore (kept for backward compat)
      try {
        await _firestoreService.syncFocusSession(user.uid, session);
      } catch (e) {
        debugPrint('[FocusModeService] Firestore focus session sync failed: $e');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_currentStatus == FocusStatus.active) {
      if (strictMode) {
        // In strict (pinned) mode, we delegate breakout detection
        // to kioskModeStream in ActiveFocusModePage.
        // This avoids race conditions with system gestures.
        return;
      }
      
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        // User left the app during a non-strict focus session
        interruptSession();
      }
    }
  }

  void reset() {
    _currentStatus = FocusStatus.idle;
    _statusController.add(FocusStatus.idle);
    _activeSession = null;
    _timer?.cancel();
  }
}
