import 'package:isar/isar.dart';

part 'daily_stats.g.dart';

@collection
class DailyStats {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late DateTime date;

  /// Total screen time in milliseconds
  late int totalScreenTimeMs;

  late int unlockCount;

  /// Total micro-leaks duration in milliseconds
  late int totalMicroLeaksTimeMs;

  @ignore
  Duration get totalScreenTime => Duration(milliseconds: totalScreenTimeMs);

  @ignore
  Duration get totalMicroLeaksTime =>
      Duration(milliseconds: totalMicroLeaksTimeMs);
}
