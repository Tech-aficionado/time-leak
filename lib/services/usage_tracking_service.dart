import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'usage_stats_service.dart';
import 'local_storage_service.dart';
import 'package:isar/isar.dart';
import '../models/app_usage.dart';
import '../models/app_metadata.dart';
import '../models/session.dart';
import '../models/daily_stats.dart';
import '../models/focus_session.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'supabase_service.dart';

class AppDeepMetrics {
  final String packageName;
  final List<int> hourlyUsage; // 24 items
  final Map<String, int> triggerApps; // packageName -> count
  final Map<String, int> followUpApps; // packageName -> count
  final double leakFactor; // 0.0 to 1.0 (microLeaks / totalSessions)
  final Duration avgSessionLength;

  AppDeepMetrics({
    required this.packageName,
    required this.hourlyUsage,
    required this.triggerApps,
    required this.followUpApps,
    required this.leakFactor,
    required this.avgSessionLength,
  });
}

class DigitalVortex {
  final List<String> appChain; // List of packageNames
  final DateTime startTime;
  final Duration totalDuration;
  final String intensity; // 'High', 'Critical'

  DigitalVortex({
    required this.appChain,
    required this.startTime,
    required this.totalDuration,
    required this.intensity,
  });
}

class FlowPoint {
  final String packageName;
  final DateTime time;
  final bool isLeak;
  final int riskLevel; // 0: Safe, 1: Medium, 2: High

  FlowPoint({
    required this.packageName,
    required this.time,
    required this.isLeak,
    required this.riskLevel,
  });
}

/// Unified metrics for the Home perception layer
class HomeMetrics {
  final double focusScore;
  final int microLeaks;
  final int appSwitches;
  final int unlockFrequency;
  final Duration totalScreenTime;

  /// 24 items representing total usage minutes in each hour of the day
  final List<int> leakRadarHeatmap;
  final Map<int, Duration> categoryBreakdown;

  HomeMetrics({
    required this.focusScore,
    required this.microLeaks,
    required this.appSwitches,
    required this.unlockFrequency,
    required this.totalScreenTime,
    required this.leakRadarHeatmap,
    required this.categoryBreakdown,
    this.topLeakTrigger,
    required this.vortexes,
    required this.flowPoints,
  });

  final String? topLeakTrigger;
  final List<DigitalVortex> vortexes;
  final List<FlowPoint> flowPoints;
}

class UsageAppInfo {
  final String packageName;
  final String appName;
  final Duration usageDuration;
  final Uint8List? iconBytes;
  final int category;

  UsageAppInfo({
    required this.packageName,
    required this.appName,
    required this.usageDuration,
    this.iconBytes,
    this.category = -1,
  });

  double get usageMinutes => usageDuration.inSeconds / 60.0;
}

const List<String> _ignoredPackages = [
  'com.android.launcher',
  'com.android.launcher3',
  'com.google.android.apps.nexuslauncher',
  'com.sec.android.app.launcher',
  'com.miui.home',
  'com.oppo.launcher',
  'com.huawei.android.launcher',
  'com.bbk.launcher2',
  'com.oneplus.launcher',
  'com.google.android.inputmethod.latin',
];

class UsageTrackingService with WidgetsBindingObserver {
  static final UsageTrackingService _instance = UsageTrackingService._internal();
  factory UsageTrackingService() => _instance;
  
  UsageTrackingService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Instantly refresh when the user returns to the app
      refreshData();
    }
  }

  final UsageStatsService _statsService = UsageStatsService();
  final LocalStorageService _storageService = LocalStorageService();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final SupabaseService _supabaseService = SupabaseService();

  final _usageStreamController = StreamController<List<UsageAppInfo>>.broadcast();
  Stream<List<UsageAppInfo>> get usageStream => _usageStreamController.stream;

  List<UsageAppInfo>? _lastUsage;
  List<UsageAppInfo>? get lastUsage => _lastUsage;

  final _metricsStreamController = StreamController<HomeMetrics>.broadcast();
  Stream<HomeMetrics> get metricsStream => _metricsStreamController.stream;

  HomeMetrics? _lastMetrics;
  HomeMetrics? get lastMetrics => _lastMetrics;

  // Broadcasts a DateTime every time a full data refresh completes.
  // Pages can listen to this to trigger their own async re-fetches.
  final _refreshTickController = StreamController<DateTime>.broadcast();
  Stream<DateTime> get refreshTick => _refreshTickController.stream;

  Timer? _refreshTimer;
  bool _isRefreshing = false;

  bool listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  /// Starts periodic refreshing of usage data (default: 10 seconds)
  void startAutoRefresh({Duration interval = const Duration(seconds: 10)}) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) => refreshData());
    refreshData(); // Immediate first fetch
  }

  /// Stops periodic refreshing
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Triggers a refresh and pushes to stream
  Future<void> refreshData() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      // 1. Fetch Local Data (Instant)
      final leaderboard = await getLeaderboardData();
      
      // Only emit leaderboard if it changed (simple length/first item check for perf)
      if (_lastUsage == null || 
          _lastUsage!.length != leaderboard.length || 
          (_lastUsage!.isNotEmpty && _lastUsage![0].packageName != leaderboard[0].packageName) ||
          (_lastUsage!.isNotEmpty && leaderboard.isNotEmpty && _lastUsage![0].usageDuration != leaderboard[0].usageDuration)) {
        _lastUsage = leaderboard;
        debugPrint('[UsageTrackingService] NEW leaderboard data received: ${leaderboard.length} apps');
        if (!_usageStreamController.isClosed) {
          _usageStreamController.add(leaderboard);
        }
      }
      
      final metrics = await getHomeMetrics();
      
      // Robust comparison to prevent re-triggering animations/rebuilds if data is same
      // We ignore minor sub-minute changes in totalScreenTime to prevent every-tick flickering
      bool hasChanged = _lastMetrics == null ||
          metrics.focusScore != _lastMetrics!.focusScore ||
          metrics.microLeaks != _lastMetrics!.microLeaks ||
          metrics.appSwitches != _lastMetrics!.appSwitches ||
          metrics.unlockFrequency != _lastMetrics!.unlockFrequency ||
          metrics.totalScreenTime.inMinutes != _lastMetrics!.totalScreenTime.inMinutes ||
          !listEquals(metrics.leakRadarHeatmap, _lastMetrics!.leakRadarHeatmap) ||
          metrics.vortexes.length != _lastMetrics!.vortexes.length;

      if (hasChanged) {
        _lastMetrics = metrics;
        if (!_metricsStreamController.isClosed) {
          debugPrint('[UsageTrackingService] Pushing NEW metrics to stream: Score=${metrics.focusScore.toStringAsFixed(1)}%, Time=${metrics.totalScreenTime}');
          _metricsStreamController.add(metrics);
        }
      } else {
        // debugPrint('[UsageTrackingService] Data unchanged, skipping stream push.');
      }

      // 2. Signal all listeners that a refresh attempt was made
      if (!_refreshTickController.isClosed) {
        _refreshTickController.add(DateTime.now());
      }
      
      // 3. Sync with cloud backends (Fire-and-forget)
      unawaited(_syncWithCloud());

    } catch (e) {
      debugPrint('[UsageTrackingService] Refresh failed: $e');
    } finally {
      _isRefreshing = false;
    }
  }


  /// Syncs today's data to Supabase (primary store) and Firestore (profile layer).
  Future<void> _syncWithCloud() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      // 1. Fetch all of today's data from local Isar store
      final dailyStats = await _storageService.isar.dailyStats
          .filter()
          .dateEqualTo(startOfDay)
          .findFirst();
      final usages = await _storageService.isar.appUsages
          .filter()
          .dateEqualTo(startOfDay)
          .findAll();
      final sessions = await _storageService.isar.sessions
          .filter()
          .startTimeGreaterThan(startOfDay)
          .findAll();

      // 2. Sync to Supabase — uid is read from the Supabase session internally.
      //    Daily stats + app usages are cooldown-gated (15s).
      //    App sessions and profile always go through (high value, low volume).
      await _supabaseService.syncUserProfile(
        firebaseUid: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
      );
      if (dailyStats != null) {
        await _supabaseService.syncDailyStats(dailyStats);
      }
      if (usages.isNotEmpty) {
        await _supabaseService.syncAppUsages(usages);
      }
      if (sessions.isNotEmpty) {
        await _supabaseService.syncAppSessions(sessions);
      }

      // 3. Keep Firestore daily stats in sync (profile/leaderboard reads)
      if (dailyStats != null) {
        await _firestoreService.syncDailyStats(user.uid, dailyStats);
      }
    } catch (e) {
      debugPrint('[UsageTrackingService] Cloud sync failed: $e');
    }
  }


  // Simple in-memory cache for app info to complement Isar
  static final Map<String, String> _appNameCache = {};
  static final Map<String, Uint8List?> _appIconCache = {};

  /// Computes individual sessions from raw app switch events (onResume, onPause)
  /// Uses a wider time window to catch sessions overlapping midnight.
  Future<List<Session>> getAppSessions() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    // Query from 24h ago to catch sessions starting before midnight
    final queryStart = startOfDay.subtract(const Duration(days: 1));

    final events = await _statsService.getAppSwitches(queryStart, now);

    // Sort events by timestamp
    events.sort((a, b) => (a['timeStamp'] ?? 0).compareTo(b['timeStamp'] ?? 0));

    List<Session> sessions = [];
    Map<String, DateTime> activeAppStarts = {};

    for (var event in events) {
      final String packageName = event['packageName'] ?? '';
      if (_ignoredPackages.contains(packageName)) continue;

      final int eventType = event['eventType'] ?? 0;
      final int timeStampMs = event['timeStamp'] ?? 0;
      final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(timeStampMs);

      // 1: MOVE_TO_FOREGROUND
      if (eventType == 1) {
        activeAppStarts[packageName] = timestamp;
      }
      // 2: MOVE_TO_BACKGROUND
      else if (eventType == 2) {
        if (activeAppStarts.containsKey(packageName)) {
          DateTime startTime = activeAppStarts.remove(packageName)!;
          DateTime endTime = timestamp;

          // Only keep sessions that end after today started
          if (endTime.isAfter(startOfDay)) {
            // Clip start time to midnight if it started yesterday
            if (startTime.isBefore(startOfDay)) {
              startTime = startOfDay;
            }
            sessions.add(
              Session()
                ..packageName = packageName
                ..startTime = startTime
                ..endTime = endTime,
            );
          }
        }
      }
    }

    // Close any currently active sessions
    activeAppStarts.forEach((packageName, startTime) {
      DateTime finalStartTime = startTime;
      if (finalStartTime.isBefore(startOfDay)) {
        finalStartTime = startOfDay;
      }
      if (now.isAfter(finalStartTime)) {
        sessions.add(
          Session()
            ..packageName = packageName
            ..startTime = finalStartTime
            ..endTime = now,
        );
      }
    });

    final isar = _storageService.isar;
    await isar.writeTxn(() async {
      final oldSessions = await isar.sessions.filter().startTimeGreaterThan(startOfDay).findAll();
      await isar.sessions.deleteAll(oldSessions.map((e) => e.id).toList());
      await isar.sessions.putAll(sessions);
    });
    return sessions;
  }

  /// Fetches the precise aggregated app usage for today by summarizing exact sessions
  Future<List<AppUsage>> getTodayUsage() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    // 1. Fetch exact sessions (this calculation is more accurate for live "Today" stats)
    final sessions = await getAppSessions();
    
    // 2. Aggregate sessions into packageName -> totalDuration
    Map<String, Duration> aggregatedUsage = {};
    for (var session in sessions) {
      aggregatedUsage[session.packageName] = (aggregatedUsage[session.packageName] ?? Duration.zero) + session.duration;
    }

    // 3. Map to AppUsage model
    final List<AppUsage> usages = aggregatedUsage.entries.map((e) {
      return AppUsage()
        ..date = startOfDay
        ..packageName = e.key
        ..totalTimeInForeground = e.value;
    }).toList();

    // 4. Optionally cross-reference with native aggregates if we have them
    // (This helps catch background services that don't trigger app-switch events)
    try {
      final nativeStats = await _statsService.getUsageStats(startOfDay, now);
      debugPrint('[UsageTrackingService] Native discovered ${nativeStats.length} potential apps');
      
      int addedFromNative = 0;
      for (var stat in nativeStats) {
        final pkg = stat['packageName'] as String? ?? '';
        if (pkg.isEmpty || _ignoredPackages.contains(pkg)) continue;
        
        // Android totalTimeInForeground is in milliseconds
        final nativeTime = Duration(milliseconds: stat['totalTimeInForeground'] as int? ?? 0);
        
        // Find existing or add new
        int existingIndex = usages.indexWhere((u) => u.packageName == pkg);
        if (existingIndex != -1) {
          // If native time is significantly higher (>5s diff), trust it more
          if (nativeTime.inSeconds > usages[existingIndex].totalTimeInForeground.inSeconds + 5) {
            usages[existingIndex].totalTimeInForeground = nativeTime;
          }
        } else if (nativeTime.inSeconds > 0) {
          usages.add(
            AppUsage()
              ..date = startOfDay
              ..packageName = pkg
              ..totalTimeInForeground = nativeTime,
          );
          addedFromNative++;
        }
      }
      debugPrint('[UsageTrackingService] Native added $addedFromNative new apps to list');
    } catch (e) {
      debugPrint('[UsageTrackingService] Native cross-ref failed: $e');
    }

    debugPrint('[UsageTrackingService] Final unique apps for today: ${usages.length}');

    // 5. Persist to local Isar store
    final isar = _storageService.isar;
    await isar.writeTxn(() async {
      final existing = await isar.appUsages.filter().dateEqualTo(startOfDay).findAll();
      await isar.appUsages.deleteAll(existing.map((e) => e.id).toList());
      await isar.appUsages.putAll(usages);
    });

    return usages;
  }

  /// Detects short phone usage bursts ("micro-leaks")
  Future<List<Session>> getMicroLeaks() async {
    final sessions = await getAppSessions();
    return sessions.where((session) => session.isMicroLeak).toList();
  }

  /// Fetches exact sessions for a specific app today
  Future<List<Session>> getSessionsForApp(String packageName) async {
    final sessions = await getAppSessions();
    return sessions.where((s) => s.packageName == packageName).toList();
  }

  /// Gets the number of times the device was unlocked today
  Future<int> getUnlockCount() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final events = await _statsService.getAppSwitches(startOfDay, now);

    int unlockCount = 0;

    for (var event in events) {
      final int eventType = event['eventType'] ?? 0;

      // 18: KEYGUARD_HIDDEN (Device unlocked)
      if (eventType == 18) {
        unlockCount++;
      }
    }

    // Calculate and save daily stats
    final usages = await getTodayUsage();
    final sessions = await getAppSessions();
    final microLeaks = sessions.where((s) => s.isMicroLeak).toList();

    int totalScreenTimeMs = usages.fold(
      0,
      (sum, usage) => sum + usage.totalTimeInForegroundMs,
    );
    int totalMicroLeaksTimeMs = microLeaks.fold(
      0,
      (sum, session) => sum + session.duration.inMilliseconds,
    );

    final dailyStats = DailyStats()
      ..date = startOfDay
      ..totalScreenTimeMs = totalScreenTimeMs
      ..unlockCount = unlockCount
      ..totalMicroLeaksTimeMs = totalMicroLeaksTimeMs;

    await _storageService.saveDailyStats(dailyStats);

    return unlockCount;
  }

  /// Calculates all unified metrics for the Home Experience
  Future<HomeMetrics> getHomeMetrics() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    // 1. Fetch exact sessions (this also saves them)
    final sessions = await getAppSessions();

    // 2. Count unlocks (strictly from start of day)
    final events = await _statsService.getAppSwitches(startOfDay, now);
    int unlockCount = 0;
    for (var event in events) {
      if (event['eventType'] == 18) unlockCount++;
    }

    // 3. Fetch exact aggregated usages (this also saves them)
    final usages = await getTodayUsage();
    final microLeaksList = sessions.where((s) => s.isMicroLeak).toList();

    int totalScreenTimeMs = usages.fold(0, (sum, u) => sum + u.totalTimeInForegroundMs);
    int totalMicroLeaksTimeMs = microLeaksList.fold(0, (sum, s) => sum + s.duration.inMilliseconds);

    // 4. Save daily stats
    final dailyStats = DailyStats()
      ..date = startOfDay
      ..totalScreenTimeMs = totalScreenTimeMs
      ..unlockCount = unlockCount
      ..totalMicroLeaksTimeMs = totalMicroLeaksTimeMs;

    await _storageService.saveDailyStats(dailyStats);

    // 5. Calculate final display metrics
    int microLeaksCount = microLeaksList.length;
    int appSwitches = sessions.length;

    double focusScore = 100.0 - (appSwitches / 2.0) - microLeaksCount - (unlockCount * 2.0);
    if (focusScore < 0.0) focusScore = 0.0;
    if (focusScore > 100.0) focusScore = 100.0;

    // Category breakdown
    Map<int, Duration> categoryMap = {};
    final isar = _storageService.isar;
    for (var usage in usages) {
      if (_ignoredPackages.contains(usage.packageName)) continue;
      
      final metadata = await isar.appMetadatas.filter().packageNameEqualTo(usage.packageName).findFirst();
      final category = metadata?.category ?? -1;
      
      categoryMap[category] = (categoryMap[category] ?? Duration.zero) + usage.totalTimeInForeground;
    }

    List<int> heatmap = List.filled(24, 0);
    for (var session in sessions) {
      final hour = session.startTime.hour;
      heatmap[hour] += session.duration.inMinutes;
    }

    // Find Top Leak Trigger (App opened before a micro leak)
    Map<String, int> triggerCount = {};
    for (var i = 1; i < sessions.length; i++) {
        if (sessions[i].isMicroLeak) {
            final trigger = sessions[i-1].packageName;
            triggerCount[trigger] = (triggerCount[trigger] ?? 0) + 1;
        }
    }
    String? topTrigger;
    if (triggerCount.isNotEmpty) {
        topTrigger = triggerCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    final vortexes = await detectVortexes();
    final flowPoints = await getDailyFlow();

    return HomeMetrics(
      focusScore: focusScore,
      microLeaks: microLeaksCount,
      appSwitches: appSwitches,
      unlockFrequency: unlockCount,
      totalScreenTime: Duration(milliseconds: totalScreenTimeMs),
      leakRadarHeatmap: heatmap,
      categoryBreakdown: categoryMap,
      topLeakTrigger: topTrigger,
      vortexes: vortexes,
      flowPoints: flowPoints,
    );
  }

  /// Calculates metrics for a specific historical date by querying Isar.
  /// If today is requested, it uses the live [getHomeMetrics] logic.
  Future<HomeMetrics> getHomeMetricsForDate(DateTime date) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate.isAtSameMomentAs(today)) {
      return getHomeMetrics();
    }

    final isar = _storageService.isar;
    final nextDay = targetDate.add(const Duration(days: 1));

    // 1. Fetch historical data from Isar
    final dailyStats = await isar.dailyStats.filter().dateEqualTo(targetDate).findFirst();
    final sessions = await isar.sessions.filter().startTimeBetween(targetDate, nextDay).sortByStartTime().findAll();
    final usages = await isar.appUsages.filter().dateEqualTo(targetDate).findAll();

    if (dailyStats == null && sessions.isEmpty && usages.isEmpty) {
      return HomeMetrics(
        focusScore: 0.0,
        microLeaks: 0,
        appSwitches: 0,
        unlockFrequency: 0,
        totalScreenTime: Duration.zero,
        leakRadarHeatmap: List.filled(24, 0),
        categoryBreakdown: {},
        vortexes: [],
        flowPoints: [],
      );
    }

    int microLeaksCount = sessions.where((s) => s.isMicroLeak).length;
    int unlockCount = dailyStats?.unlockCount ?? 0;
    int appSwitches = sessions.length;
    int totalScreenTimeMs = dailyStats?.totalScreenTimeMs ?? 0;

    // Use same focus score formula
    double focusScore = 100.0 - (appSwitches / 2.0) - microLeaksCount - (unlockCount * 2.0);
    focusScore = focusScore.clamp(0.0, 100.0);

    Map<int, Duration> categoryMap = {};
    for (var usage in usages) {
      if (_ignoredPackages.contains(usage.packageName)) continue;
      final metadata = await isar.appMetadatas.filter().packageNameEqualTo(usage.packageName).findFirst();
      categoryMap[metadata?.category ?? -1] = (categoryMap[metadata?.category ?? -1] ?? Duration.zero) + usage.totalTimeInForeground;
    }

    List<int> heatmap = List.filled(24, 0);
    for (var session in sessions) {
      heatmap[session.startTime.hour] += session.duration.inMinutes;
    }

    final vortexes = await detectVortexes(date: targetDate);
    final flowPoints = await getDailyFlow(date: targetDate);

    return HomeMetrics(
      focusScore: focusScore,
      microLeaks: microLeaksCount,
      appSwitches: appSwitches,
      unlockFrequency: unlockCount,
      totalScreenTime: Duration(milliseconds: totalScreenTimeMs),
      leakRadarHeatmap: heatmap,
      categoryBreakdown: categoryMap,
      vortexes: vortexes,
      flowPoints: flowPoints,
    );
  }

  /// Gets leaderboard data sorted by usage time
  Future<List<UsageAppInfo>> getLeaderboardData() async {
    final usages = await getTodayUsage();

    // Sort by duration descending
    usages.sort(
      (a, b) => b.totalTimeInForeground.compareTo(a.totalTimeInForeground),
    );

    List<UsageAppInfo> leaderboard = [];
    final isar = _storageService.isar;

    for (var usage in usages) {
      final pkg = usage.packageName;

      // Skip ignored packages in leaderboard
      if (_ignoredPackages.contains(pkg)) continue;

      String? appName = _appNameCache[pkg];
      Uint8List? iconBytes = _appIconCache[pkg];
      int category = -1;

      // If not in memory, check Isar persistent cache
      if (appName == null || iconBytes == null) {
        final metadata = await isar.appMetadatas.filter().packageNameEqualTo(pkg).findFirst();
        
        if (metadata != null) {
          appName = metadata.appName;
          iconBytes = metadata.iconBytes != null ? Uint8List.fromList(metadata.iconBytes!) : null;
          category = metadata.category ?? -1;
          
          // Update memory cache
          _appNameCache[pkg] = appName;
          _appIconCache[pkg] = iconBytes;
        }
      }

      // If still not found or need update (e.g. name is same as package), fetch from platform
      if (appName == null || appName == pkg || iconBytes == null) {
        // Fetch App Name
        final fetchedName = await _statsService.getAppLabel(pkg);
        appName = fetchedName;
        
        // Fetch Icon
        final fetchedIcon = await _statsService.getAppIcon(pkg);
        iconBytes = fetchedIcon;

        // Fetch Category
        category = await _statsService.getAppCategory(pkg);

        // Update memory cache
        _appNameCache[pkg] = appName;
        _appIconCache[pkg] = iconBytes;

        // Update persistent cache
        await isar.writeTxn(() async {
          final existing = await isar.appMetadatas.filter().packageNameEqualTo(pkg).findFirst();
          final metadata = existing ?? AppMetadata()..packageName = pkg;
          metadata.appName = appName!;
          metadata.iconBytes = iconBytes;
          metadata.category = category;
          metadata.lastUpdated = DateTime.now();
          await isar.appMetadatas.put(metadata);
        });
      }

      leaderboard.add(
        UsageAppInfo(
          packageName: pkg,
          appName: appName,
          usageDuration: usage.totalTimeInForeground,
          iconBytes: iconBytes,
          category: category,
        ),
      );
    }

    return leaderboard;
  }

  /// Gets historical usage data for the last 7 days
  Future<List<DailyStats>> getWeeklyTrends() async {
    final now = DateTime.now();
    final sevenDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
    
    return _storageService.getDailyStatsForDateRange(sevenDaysAgo, now);
  }

  /// Gets deep metrics for a specific app
  Future<AppDeepMetrics> getAppDeepMetrics(String packageName) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Get all sessions for today to analyze sequences
    final allSessions = await _storageService.isar.sessions
        .filter()
        .startTimeBetween(startOfDay, endOfDay)
        .sortByStartTime()
        .findAll();
    
    // Sort correctly
    allSessions.sort((a, b) => a.startTime.compareTo(b.startTime));

    final appSessions = allSessions.where((s) => s.packageName == packageName).toList();
    
    List<int> hourlyUsage = List.filled(24, 0);
    Map<String, int> triggerApps = {};
    Map<String, int> followUpApps = {};
    int microLeaks = 0;
    int totalMillis = 0;

    for (var i = 0; i < allSessions.length; i++) {
        final session = allSessions[i];
        if (session.packageName == packageName) {
            // Hourly usage
            hourlyUsage[session.startTime.hour] += session.duration.inMinutes;

            // Micro leaks
            if (session.isMicroLeak) microLeaks++;
            totalMillis += session.duration.inMilliseconds;

            // Sequence analysis
            if (i > 0) {
                final prev = allSessions[i - 1];
                if (prev.packageName != packageName) {
                    triggerApps[prev.packageName] = (triggerApps[prev.packageName] ?? 0) + 1;
                }
            }
            if (i < allSessions.length - 1) {
                final next = allSessions[i + 1];
                if (next.packageName != packageName) {
                    followUpApps[next.packageName] = (followUpApps[next.packageName] ?? 0) + 1;
                }
            }
        }
    }

    return AppDeepMetrics(
      packageName: packageName,
      hourlyUsage: hourlyUsage,
      triggerApps: triggerApps,
      followUpApps: followUpApps,
      leakFactor: appSessions.isEmpty ? 0 : microLeaks / appSessions.length,
      avgSessionLength: appSessions.isEmpty ? Duration.zero : Duration(milliseconds: totalMillis ~/ appSessions.length),
    );
  }

  /// Detects "Digital Vortexes" (sequences of high-risk apps)
  Future<List<DigitalVortex>> detectVortexes({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final sessions = await _storageService.isar.sessions
        .filter()
        .startTimeBetween(startOfDay, endOfDay)
        .sortByStartTime()
        .findAll();

    List<DigitalVortex> vortexes = [];
    List<Session> currentChain = [];
    
    // Risk mapping
    final isar = _storageService.isar;

    for (var session in sessions) {
      final metadata = await isar.appMetadatas.filter().packageNameEqualTo(session.packageName).findFirst();
      final category = metadata?.category ?? -1;
      
      // High risk: Games(0), Video(2), Social(4)
      final bool isHighRisk = [0, 2, 4].contains(category) || session.isMicroLeak;

      if (isHighRisk) {
        if (currentChain.isEmpty) {
          currentChain.add(session);
        } else {
          final lastSession = currentChain.last;
          if (session.startTime.difference(lastSession.endTime).inMinutes < 10) {
            currentChain.add(session);
          } else {
            if (currentChain.length >= 3) {
               vortexes.add(_createVortex(currentChain));
            }
            currentChain = [session];
          }
        }
      } else {
        if (currentChain.length >= 3) {
          vortexes.add(_createVortex(currentChain));
        }
        currentChain = [];
      }
    }

    if (currentChain.length >= 3) {
      vortexes.add(_createVortex(currentChain));
    }

    return vortexes;
  }

  DigitalVortex _createVortex(List<Session> chain) {
    return DigitalVortex(
      appChain: chain.map((s) => s.packageName).toList(),
      startTime: chain.first.startTime,
      totalDuration: Duration(milliseconds: chain.fold(0, (sum, s) => sum + s.duration.inMilliseconds)),
      intensity: chain.length > 5 ? 'Critical' : 'High',
    );
  }

  /// Gets aggregate "Career Stats" for the Profile page
  Future<Map<String, dynamic>> getCareerStats() async {
    final isar = _storageService.isar;
    
    // 1. Fetch historical data from Isar
    final allDailyStats = await isar.dailyStats.where().findAll();
    int totalTimeMs = allDailyStats.fold(0, (sum, s) => sum + s.totalScreenTimeMs);
    int totalLeaksMs = allDailyStats.fold(0, (sum, s) => sum + s.totalMicroLeaksTimeMs);
    int totalUnlocks = allDailyStats.fold(0, (sum, s) => sum + s.unlockCount);

    // 2. Include TODAY's live metrics
    final todayMetrics = await getHomeMetrics();
    totalTimeMs += todayMetrics.totalScreenTime.inMilliseconds;
    totalLeaksMs += todayMetrics.microLeaks * 60000; // Estimate 1 min per leak if no duration stored
    totalUnlocks += todayMetrics.unlockFrequency;

    // 3. Focus Sessions
    final allFocusSessions = await isar.focusSessions.where().findAll();
    int successfulSessions = 0;
    int totalFocusMs = 0;
    int avgSessionMinutes = 0;
    
    if (allFocusSessions.isNotEmpty) {
      successfulSessions = allFocusSessions.where((s) => s.isSuccessful).length;
      totalFocusMs = allFocusSessions.fold(0, (sum, s) => sum + (s.actualDurationMs ?? 0));
      avgSessionMinutes = (totalFocusMs ~/ allFocusSessions.length) ~/ 60000;
    }
    
    // 4. Efficiency & Rank
    double efficiencyValue = allFocusSessions.isEmpty 
        ? 0.0 
        : (successfulSessions / allFocusSessions.length);
    
    String rankValue = 'Beginner';
    if (successfulSessions >= 50) {
      rankValue = 'Elite';
    } else if (successfulSessions >= 25) {
      rankValue = 'Grandmaster';
    } else if (successfulSessions >= 10) {
      rankValue = 'Focused';
    }

    return {
      'totalTime': Duration(milliseconds: totalTimeMs),
      'totalLeaks': Duration(milliseconds: totalLeaksMs),
      'totalUnlocks': totalUnlocks,
      'successfulFocusSessions': successfulSessions,
      'totalFocusTime': Duration(milliseconds: totalFocusMs),
      'avgFocusDuration': Duration(minutes: avgSessionMinutes),
      'systemRank': rankValue,
      'efficiency': efficiencyValue,
    };
  }

  /// Gets coordinates for the daily flow timeline
  Future<List<FlowPoint>> getDailyFlow({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final sessions = await _storageService.isar.sessions
        .filter()
        .startTimeBetween(startOfDay, endOfDay)
        .sortByStartTime()
        .findAll();

    final isar = _storageService.isar;
    List<FlowPoint> points = [];

    for (var session in sessions) {
        final metadata = await isar.appMetadatas.filter().packageNameEqualTo(session.packageName).findFirst();
        final category = metadata?.category ?? -1;
        
        int risk = 0;
        if ([0, 2, 4].contains(category)) {
            risk = 2; // High
        } else if ([3, 5].contains(category)) {
            risk = 1; // Medium
        }

        points.add(FlowPoint(
            packageName: session.packageName,
            time: session.startTime,
            isLeak: session.isMicroLeak,
            riskLevel: risk,
        ));
    }
    return points;
  }
  /// Manually force a sync with all cloud backends
  Future<void> forceSyncWithCloud() async {
    await _syncWithCloud();
  }

  /// Calculates aggregate lifetime profile statistics for the Profile Screen
  Future<Map<String, dynamic>> getProfileStats() async {
    final dailyStatsList = await _storageService.isar.dailyStats.where().sortByDateDesc().findAll();
    
    int streak = 0;
    
    // Streak Calculation (Start looking from today/yesterday)
    DateTime expected = DateTime.now();
    expected = DateTime(expected.year, expected.month, expected.day);
    
    for (var stat in dailyStatsList) {
      // If the stat is today/expected, or if we haven't started counting and it's yesterday
      if (stat.date.isAtSameMomentAs(expected) || (streak == 0 && stat.date.isBefore(expected))) {
        streak++;
        expected = stat.date.subtract(const Duration(days: 1));
      } else if (stat.date.isBefore(expected)) {
        break; // Streak broken
      }
    }

    int totalScreenTimeMs = 0;
    for (var stat in dailyStatsList) {
      totalScreenTimeMs += stat.totalScreenTimeMs;
    }
    
    Duration avgScreen = dailyStatsList.isEmpty 
        ? Duration.zero 
        : Duration(milliseconds: totalScreenTimeMs ~/ dailyStatsList.length);
    
    // Time saved calculation (Baseline assumes 4.5 hours per day)
    final double baselineMs = 4.5 * 60 * 60 * 1000;
    int savedMs = 0;
    for (var stat in dailyStatsList) {
      final double diff = baselineMs - stat.totalScreenTimeMs;
      if (diff > 0) savedMs += diff.toInt();
    }
    
    String focusLevel = 'Novice';
    if (streak >= 30) {
      focusLevel = 'Elite';
    } else if (streak >= 14) {
      focusLevel = 'Pro';
    } else if (streak >= 7) {
      focusLevel = 'Focused';
    } else if (streak >= 3) {
      focusLevel = 'Starter';
    }

    return {
      'streak': streak,
      'avgScreen': avgScreen,
      'timeSaved': Duration(milliseconds: savedMs),
      'focusLevel': focusLevel,
    };
  }
}
