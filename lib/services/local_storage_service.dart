import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/app_usage.dart';
import '../models/daily_stats.dart';
import '../models/focus_session.dart';
import '../models/session.dart';
import '../models/app_metadata.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  late Isar _isar;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  bool get isEncrypted => false; // Encryption currently disabled for compatibility

  /// Initializes the Isar database with encryption
  Future<void> init() async {
    if (_isInitialized) return;

    final dir = await getApplicationDocumentsDirectory();
    
    // Secure Key Management (Kept for potential re-activation, currently using unencrypted Isar open as per previous fix)
    /*
    final storage = FlutterSecureStorage();
    String? key = await storage.read(key: 'isar_encryption_key');
    if (key == null) {
      final random = Random.secure();
      final values = List<int>.generate(32, (i) => random.nextInt(256));
      key = base64UrlEncode(values);
      await storage.write(key: 'isar_encryption_key', value: key);
    }
    */

    _isar = await Isar.open(
      [
        SessionSchema,
        AppUsageSchema,
        DailyStatsSchema,
        FocusSessionSchema,
        AppMetadataSchema,
      ],
      directory: dir.path,
    );
    _isInitialized = true;
  }

  Isar get isar {
    if (!_isInitialized) {
      throw Exception(
        'LocalStorageService is not initialized. Call init() first.',
      );
    }
    return _isar;
  }

  // --- Session Methods ---

  Future<void> saveSessions(List<Session> sessions) async {
    await isar.writeTxn(() async {
      await isar.sessions.putAll(sessions);
    });
  }

  Future<List<Session>> getSessionsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return isar.sessions
        .filter()
        .startTimeBetween(start, end)
        .sortByStartTime()
        .findAll();
  }

  Future<void> clearOldSessions(DateTime beforeDate) async {
    await isar.writeTxn(() async {
      await isar.sessions.filter().startTimeLessThan(beforeDate).deleteAll();
    });
  }

  // --- AppUsage Methods ---

  Future<void> saveAppUsages(List<AppUsage> usages) async {
    await isar.writeTxn(() async {
      await isar.appUsages.putAll(usages);
    });
  }

  Future<List<AppUsage>> getAppUsageForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    return isar.appUsages.filter().dateEqualTo(startOfDay).findAll();
  }

  // --- DailyStats Methods ---

  Future<void> saveDailyStats(DailyStats stats) async {
    await isar.writeTxn(() async {
      await isar.dailyStats.put(stats);
    });
  }

  Future<DailyStats?> getDailyStatsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    return isar.dailyStats.filter().dateEqualTo(startOfDay).findFirst();
  }

  Future<List<DailyStats>> getDailyStatsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return isar.dailyStats
        .filter()
        .dateBetween(start, end)
        .sortByDate()
        .findAll();
  }

  // --- FocusSession Methods ---

  Future<void> saveFocusSession(FocusSession session) async {
    await isar.writeTxn(() async {
      await isar.focusSessions.put(session);
    });
  }

  Future<List<FocusSession>> getFocusSessionsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return isar.focusSessions
        .filter()
        .startTimeBetween(startOfDay, endOfDay)
        .sortByStartTimeDesc()
        .findAll();
  }

  Future<void> updateFocusSession(FocusSession session) async {
    await saveFocusSession(session);
  }
}
