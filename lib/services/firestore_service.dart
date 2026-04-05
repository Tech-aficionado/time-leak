import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/daily_stats.dart';
import '../models/app_usage.dart';
import '../models/session.dart';
import '../models/focus_session.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Initializes the user's profile document in Firestore
  Future<void> initializeUserProfile(User user) async {
    final userRef = _db.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } else {
      await userRef.update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Syncs daily stats for a specific user
  Future<void> syncDailyStats(String uid, DailyStats stats) async {
    final dateStr = stats.date.toIso8601String().split('T')[0];
    await _db
        .collection('users')
        .doc(uid)
        .collection('daily_stats')
        .doc(dateStr)
        .set({
      'date': stats.date,
      'totalScreenTimeMs': stats.totalScreenTimeMs,
      'unlockCount': stats.unlockCount,
      'totalMicroLeaksTimeMs': stats.totalMicroLeaksTimeMs,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Syncs an individual app usage record
  Future<void> syncAppUsage(String uid, AppUsage usage) async {
    final dateStr = usage.date.toIso8601String().split('T')[0];
    final docId = '${dateStr}_${usage.packageName.replaceAll('.', '_')}';

    await _db
        .collection('users')
        .doc(uid)
        .collection('app_usages')
        .doc(docId)
        .set({
      'date': usage.date,
      'packageName': usage.packageName,
      'totalTimeInForegroundMs': usage.totalTimeInForegroundMs,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Batch syncs app usages
  Future<void> syncAppUsages(String uid, List<AppUsage> usages) async {
    final batch = _db.batch();
    for (var usage in usages) {
      final dateStr = usage.date.toIso8601String().split('T')[0];
      final docId = '${dateStr}_${usage.packageName.replaceAll('.', '_')}';
      final ref = _db
          .collection('users')
          .doc(uid)
          .collection('app_usages')
          .doc(docId);
      batch.set(ref, {
        'date': usage.date,
        'packageName': usage.packageName,
        'totalTimeInForegroundMs': usage.totalTimeInForegroundMs,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  /// Syncs usage sessions (only syncing significant ones or all if needed)
  Future<void> syncSessions(String uid, List<Session> sessions) async {
    final batch = _db.batch();
    for (var session in sessions) {
      // Create a deterministic session ID based on start time and package
      final sessionId = '${session.packageName.replaceAll('.', '_')}_${session.startTime.millisecondsSinceEpoch}';
      final ref = _db
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .doc(sessionId);
      
      batch.set(ref, {
        'packageName': session.packageName,
        'startTime': session.startTime,
        'endTime': session.endTime,
        'isMicroLeak': session.isMicroLeak,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }
  /// Syncs a completed or interrupted focus session to Firestore
  Future<void> syncFocusSession(String uid, FocusSession session) async {
    final sessionId = 'focus_${session.startTime.millisecondsSinceEpoch}';
    await _db
        .collection('users')
        .doc(uid)
        .collection('focus_sessions')
        .doc(sessionId)
        .set({
      'startTime': session.startTime,
      'endTime': session.endTime,
      'plannedDurationMs': session.plannedDurationMs,
      'actualDurationMs': session.actualDurationMs,
      'isSuccessful': session.isSuccessful,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
