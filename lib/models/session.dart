import 'package:isar/isar.dart';

part 'session.g.dart';

@collection
class Session {
  Id id = Isar.autoIncrement;

  late String packageName;

  @Index()
  late DateTime startTime;

  late DateTime endTime;

  @ignore
  Duration get duration => endTime.difference(startTime);

  @ignore
  bool get isMicroLeak => duration.inSeconds < 60;
}
