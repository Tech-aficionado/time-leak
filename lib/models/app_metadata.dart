import 'package:isar/isar.dart';

part 'app_metadata.g.dart';

@collection
class AppMetadata {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String packageName;

  late String appName;

  late int? category;

  List<int>? iconBytes;

  late DateTime lastUpdated;
}
