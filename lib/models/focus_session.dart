import 'package:isar/isar.dart';

part 'focus_session.g.dart';

@collection
class FocusSession {
  Id id = Isar.autoIncrement;

  late DateTime startTime;
  DateTime? endTime;

  /// Duration planned for the focus session (in milliseconds)
  late int plannedDurationMs;

  /// Actual duration focused (in milliseconds)
  int? actualDurationMs;

  /// Whether the focus session was successfully completed without breaking rules
  bool isSuccessful = false;

  /// Blocked packages during this focus session
  List<String> blockedPackages = [];
}
