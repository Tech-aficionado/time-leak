import 'package:isar/isar.dart';

part 'app_usage.g.dart';

@collection
class AppUsage {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;

  late String packageName;

  /// Duration in milliseconds
  late int totalTimeInForegroundMs;

  @ignore
  Duration get totalTimeInForeground =>
      Duration(milliseconds: totalTimeInForegroundMs);

  set totalTimeInForeground(Duration duration) {
    totalTimeInForegroundMs = duration.inMilliseconds;
  }
}
