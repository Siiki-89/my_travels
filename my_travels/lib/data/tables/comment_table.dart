import 'package:my_travels/data/tables/stop_point_table.dart';
import 'package:my_travels/data/tables/traveler_table.dart';

abstract class CommentTable {
  static const String tableName = 'Comment';
  static const String id = 'id';
  static const String stopPointId = 'stop_point_id';
  static const String travelerId = 'traveler_id';
  static const String content = 'content';

  static const String createTable =
      '''
    CREATE TABLE $tableName(
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $stopPointId INTEGER NOT NULL,
      $travelerId INTEGER NOT NULL,
      $content TEXT NOT NULL,
      FOREIGN KEY ($stopPointId) REFERENCES ${StopPointTable.tableName}(${StopPointTable.id}),
      FOREIGN KEY ($travelerId) REFERENCES ${TravelerTable.tableName}(${TravelerTable.id})
    );
  ''';
}
