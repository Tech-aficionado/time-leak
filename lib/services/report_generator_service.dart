import 'package:intl/intl.dart';
import 'usage_stats_service.dart';

class ReportGeneratorService {
  final UsageStatsService _usageStatsService = UsageStatsService();

  Future<String> generateDailyPrompt(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    final stats = await _usageStatsService.getUsageStats(startOfDay, endOfDay);
    
    // Sort and get top apps
    stats.sort((a, b) => (b['totalTimeInForeground'] as int).compareTo(a['totalTimeInForeground'] as int));
    
    final topApps = stats.take(5).toList();
    int totalMinutes = 0;
    
    final appDetails = await Future.wait(topApps.map((app) async {
      final label = await _usageStatsService.getAppLabel(app['packageName']);
      final minutes = (app['totalTimeInForeground'] as int) ~/ 60000;
      totalMinutes += minutes;
      return '- $label: $minutes minutes';
    }));

    final dateStr = DateFormat('EEEE, MMMM d, y').format(date);
    
    return '''
Analyze the following Android app usage data for $dateStr:
Total Recorded Screen Time: $totalMinutes minutes (Top 5 apps)

App Breakdown:
${appDetails.join('\n')}

Based on this data, provide a concise, high-performance "Neural Hygiene Report". 
Acknowledge any potential "time leaks" (distracting apps) and suggest one focus optimization for the next cycle. 
Maintain a sleek, professional, instrument-like tone. Keep it under 100 words.
''';
  }

  Future<Map<String, dynamic>> getDailyHomeData(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    final stats = await _usageStatsService.getUsageStats(startOfDay, endOfDay);
    
    int totalMs = 0;
    List<Map<String, dynamic>> apps = [];

    for (var stat in stats) {
      final time = stat['totalTimeInForeground'] as int;
      if (time > 0) {
        totalMs += time;
        apps.add({
          'packageName': stat['packageName'],
          'timeMs': time,
        });
      }
    }

    // Sort by time
    apps.sort((a, b) => (b['timeMs'] as int).compareTo(a['timeMs'] as int));

    return {
      'totalTimeMs': totalMs,
      'topApps': apps.take(10).toList(),
      'date': date,
    };
  }
}
