import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sf;
import '../models/daily_stats.dart';
import '../models/app_usage.dart';
import '../models/focus_session.dart';
import '../models/session.dart';

/// Manages all Supabase data operations for Time Leak.
///
/// ═══════════════════════════════════════════════════════════════════════════
/// AUTHENTICATION MODEL
/// ═══════════════════════════════════════════════════════════════════════════
/// Firebase Auth is the identity provider.  After Google Sign-In the app
/// also calls `supabase.auth.signInWithIdToken(provider: OAuthProvider.google)`
/// with the SAME Google ID token.  Supabase validates it via Google's JWKS,
/// creates a real session, and exposes `auth.uid()` in RLS policies — the
/// Supabase UUID is this service's primary user identifier.
///
/// The Firebase UID is stored as a reference column (`firebase_uid`) in the
/// `users` table so you can cross-reference both consoles.
///
/// ═══════════════════════════════════════════════════════════════════════════
/// SMART SYNC RULES
/// ═══════════════════════════════════════════════════════════════════════════
///  - 15-second cooldown on periodic syncs (matches the tracking refresh interval).
///  - Focus sessions and individual app sessions always bypass the cooldown.
///  - Zero-duration app usages are silently filtered before sending.
///  - All methods guard against a missing Supabase session and skip cleanly.
///
/// ═══════════════════════════════════════════════════════════════════════════
/// SUPABASE SQL SCHEMA  (run once in Supabase SQL Editor)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// -- ── Users (linked to Supabase Auth) ──────────────────────────────────
/// CREATE TABLE users (
///   id           UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
///   firebase_uid TEXT UNIQUE NOT NULL,
///   display_name TEXT,
///   email        TEXT,
///   photo_url    TEXT,
///   created_at   TIMESTAMPTZ DEFAULT now(),
///   last_seen    TIMESTAMPTZ DEFAULT now()
/// );
///
/// -- ── Daily aggregate stats ─────────────────────────────────────────────
/// CREATE TABLE daily_stats (
///   id                    BIGSERIAL PRIMARY KEY,
///   user_id               TEXT NOT NULL,          -- Supabase UUID as text
///   date                  DATE NOT NULL,
///   total_screen_time_ms  BIGINT DEFAULT 0,
///   unlock_count          INT    DEFAULT 0,
///   total_micro_leaks_ms  BIGINT DEFAULT 0,
///   updated_at            TIMESTAMPTZ DEFAULT now(),
///   UNIQUE(user_id, date)
/// );
///
/// -- ── Per-app daily usage ────────────────────────────────────────────────
/// CREATE TABLE app_usages (
///   id                       BIGSERIAL PRIMARY KEY,
///   user_id                  TEXT NOT NULL,
///   date                     DATE NOT NULL,
///   package_name             TEXT NOT NULL,
///   total_time_foreground_ms BIGINT DEFAULT 0,
///   updated_at               TIMESTAMPTZ DEFAULT now(),
///   UNIQUE(user_id, date, package_name)
/// );
///
/// -- ── Individual app sessions (raw switch events) ───────────────────────
/// CREATE TABLE app_sessions (
///   id           BIGSERIAL PRIMARY KEY,
///   user_id      TEXT NOT NULL,
///   session_key  TEXT NOT NULL UNIQUE,   -- packageName_startTimeMs
///   package_name TEXT NOT NULL,
///   start_time   TIMESTAMPTZ NOT NULL,
///   end_time     TIMESTAMPTZ NOT NULL,
///   duration_ms  BIGINT NOT NULL,
///   is_micro_leak BOOLEAN DEFAULT false,
///   date         DATE NOT NULL,           -- derived for easy filtering
///   updated_at   TIMESTAMPTZ DEFAULT now()
/// );
///
/// -- ── Focus sessions ─────────────────────────────────────────────────────
/// CREATE TABLE focus_sessions (
///   id                   BIGSERIAL PRIMARY KEY,
///   user_id              TEXT NOT NULL,
///   session_key          TEXT NOT NULL UNIQUE,
///   start_time           TIMESTAMPTZ NOT NULL,
///   end_time             TIMESTAMPTZ,
///   planned_duration_ms  BIGINT,
///   actual_duration_ms   BIGINT,
///   is_successful        BOOLEAN DEFAULT false,
///   updated_at           TIMESTAMPTZ DEFAULT now()
/// );
///
/// -- ── Indexes ────────────────────────────────────────────────────────────
/// CREATE INDEX ON daily_stats   (user_id, date);
/// CREATE INDEX ON app_usages    (user_id, date);
/// CREATE INDEX ON app_sessions  (user_id, date);
/// CREATE INDEX ON focus_sessions(user_id);
///
/// -- ── Row-Level Security (auth.uid() enforced by Supabase session) ───────
/// ALTER TABLE users         ENABLE ROW LEVEL SECURITY;
/// ALTER TABLE daily_stats   ENABLE ROW LEVEL SECURITY;
/// ALTER TABLE app_usages    ENABLE ROW LEVEL SECURITY;
/// ALTER TABLE app_sessions  ENABLE ROW LEVEL SECURITY;
/// ALTER TABLE focus_sessions ENABLE ROW LEVEL SECURITY;
///
/// CREATE POLICY "own_profile" ON users
///   FOR ALL USING (id = auth.uid()) WITH CHECK (id = auth.uid());
///
/// CREATE POLICY "own_data" ON daily_stats
///   FOR ALL USING (user_id = auth.uid()::text)
///   WITH CHECK   (user_id = auth.uid()::text);
///
/// CREATE POLICY "own_data" ON app_usages
///   FOR ALL USING (user_id = auth.uid()::text)
///   WITH CHECK   (user_id = auth.uid()::text);
///
/// CREATE POLICY "own_data" ON app_sessions
///   FOR ALL USING (user_id = auth.uid()::text)
///   WITH CHECK   (user_id = auth.uid()::text);
///
/// CREATE POLICY "own_data" ON focus_sessions
///   FOR ALL USING (user_id = auth.uid()::text)
///   WITH CHECK   (user_id = auth.uid()::text);
/// ────────────────────────────────────────────────────────────────────────────
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  sf.SupabaseClient get _db => sf.Supabase.instance.client;

  /// The authenticated Supabase user UUID (null if no session).
  String? get _uid => _db.auth.currentUser?.id;

  /// Whether a valid Supabase session exists.
  bool get isAuthenticated => _uid != null;

  /// Last time a periodic sync completed — enforces the cooldown.
  DateTime? _lastPeriodicSync;
  static const _syncCooldown = Duration(seconds: 15);

  bool get _cooldownExpired {
    if (_lastPeriodicSync == null) return true;
    return DateTime.now().difference(_lastPeriodicSync!) >= _syncCooldown;
  }

  void _markSynced() => _lastPeriodicSync = DateTime.now();

  // ─────────────────────────────────────────────────────────────────────────
  // User Profile
  // ─────────────────────────────────────────────────────────────────────────

  /// Upserts the user's profile into the Supabase `users` table.
  /// The Supabase UUID (from the active session) is the primary key.
  /// The Firebase UID is stored as a reference column.
  Future<void> syncUserProfile({
    required String firebaseUid,
    required String? displayName,
    required String? email,
    required String? photoUrl,
  }) async {
    final uid = _uid;
    if (uid == null) {
      debugPrint('[SupabaseService] syncUserProfile skipped — no session');
      return;
    }
    try {
      await _db.from('users').upsert(
        {
          'id': uid,
          'firebase_uid': firebaseUid,
          'display_name': displayName,
          'email': email,
          'photo_url': photoUrl,
          'last_seen': _nowUtc(),
        },
        onConflict: 'id',
      );
    } catch (e) {
      debugPrint('[SupabaseService] syncUserProfile error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Daily Stats
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> syncDailyStats(DailyStats stats, {bool force = false}) async {
    final uid = _uid;
    if (uid == null) return;
    if (!force && !_cooldownExpired) return;
    try {
      await _db.from('daily_stats').upsert(
        {
          'user_id': uid,
          'date': _toDateStr(stats.date),
          'total_screen_time_ms': stats.totalScreenTimeMs,
          'unlock_count': stats.unlockCount,
          'total_micro_leaks_ms': stats.totalMicroLeaksTimeMs,
          'updated_at': _nowUtc(),
        },
        onConflict: 'user_id,date',
      );
    } catch (e) {
      debugPrint('[SupabaseService] syncDailyStats error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // App Usages
  // ─────────────────────────────────────────────────────────────────────────

  /// Batch-upserts per-app usage records. Filters out zero-duration entries.
  Future<void> syncAppUsages(List<AppUsage> usages, {bool force = false}) async {
    final uid = _uid;
    if (uid == null) return;
    if (!force && !_cooldownExpired) return;
    if (usages.isEmpty) return;

    try {
      final rows = usages
          .where((u) => u.totalTimeInForegroundMs > 0)
          .map((u) => {
                'user_id': uid,
                'date': _toDateStr(u.date),
                'package_name': u.packageName,
                'total_time_foreground_ms': u.totalTimeInForegroundMs,
                'updated_at': _nowUtc(),
              })
          .toList();

      if (rows.isEmpty) return;
      await _db.from('app_usages').upsert(
        rows,
        onConflict: 'user_id,date,package_name',
      );
      _markSynced();
    } catch (e) {
      debugPrint('[SupabaseService] syncAppUsages error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // App Sessions  (raw individual usage sessions — new)
  // ─────────────────────────────────────────────────────────────────────────

  /// Batch-upserts today's raw app switch sessions.
  /// Always bypasses cooldown because sessions are ephemeral and high-value.
  Future<void> syncAppSessions(List<Session> sessions) async {
    final uid = _uid;
    if (uid == null) return;
    if (sessions.isEmpty) return;

    try {
      final rows = sessions.map((s) {
        final key =
            '${s.packageName.replaceAll('.', '_')}_${s.startTime.millisecondsSinceEpoch}';
        return {
          'user_id': uid,
          'session_key': key,
          'package_name': s.packageName,
          'start_time': s.startTime.toUtc().toIso8601String(),
          'end_time': s.endTime.toUtc().toIso8601String(),
          'duration_ms': s.duration.inMilliseconds,
          'is_micro_leak': s.isMicroLeak,
          'date': _toDateStr(s.startTime),
          'updated_at': _nowUtc(),
        };
      }).toList();

      await _db.from('app_sessions').upsert(
        rows,
        onConflict: 'session_key',
      );
    } catch (e) {
      debugPrint('[SupabaseService] syncAppSessions error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Focus Sessions
  // ─────────────────────────────────────────────────────────────────────────

  /// Always forced — we never want to lose a focus session record.
  Future<void> syncFocusSession(FocusSession session) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final sessionKey = 'focus_${session.startTime.millisecondsSinceEpoch}';
      await _db.from('focus_sessions').upsert(
        {
          'user_id': uid,
          'session_key': sessionKey,
          'start_time': session.startTime.toUtc().toIso8601String(),
          'end_time': session.endTime?.toUtc().toIso8601String(),
          'planned_duration_ms': session.plannedDurationMs,
          'actual_duration_ms': session.actualDurationMs,
          'is_successful': session.isSuccessful,
          'updated_at': _nowUtc(),
        },
        onConflict: 'session_key',
      );
    } catch (e) {
      debugPrint('[SupabaseService] syncFocusSession error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Read helpers
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchDailyStats({
    required DateTime from,
    required DateTime to,
  }) async {
    final uid = _uid;
    if (uid == null) return [];
    try {
      final response = await _db
          .from('daily_stats')
          .select()
          .eq('user_id', uid)
          .gte('date', _toDateStr(from))
          .lte('date', _toDateStr(to))
          .order('date', ascending: true);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('[SupabaseService] fetchDailyStats error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchAppUsagesForDate(DateTime date) async {
    final uid = _uid;
    if (uid == null) return [];
    try {
      final response = await _db
          .from('app_usages')
          .select()
          .eq('user_id', uid)
          .eq('date', _toDateStr(date))
          .order('total_time_foreground_ms', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('[SupabaseService] fetchAppUsagesForDate error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  String _toDateStr(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  String _nowUtc() => DateTime.now().toUtc().toIso8601String();
}
