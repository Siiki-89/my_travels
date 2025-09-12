import 'package:my_travels/data/tables/stop_point_table.dart';
import 'package:my_travels/data/tables/traveler_table.dart';

/// Represents the database table for comments.
///
/// This class provides static constants for the table name, column names,
/// and the SQL command used to create the table.
abstract class CommentTable {
  /// The name of the table in the database.
  static const String tableName = 'Comment';

  /// The name of the primary key column.
  static const String id = 'id';

  /// The name of the foreign key column referencing the stop point table.
  static const String stopPointId = 'stop_point_id';

  /// The name of the foreign key column referencing the traveler table.
  static const String travelerId = 'traveler_id';

  /// The name of the column that stores the comment text.
  static const String content = 'content';

  /// The SQL statement to create the comment table.
  static const String createTable =
      '''
    CREATE TABLE $tableName(
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $stopPointId INTEGER NOT NULL,
      $travelerId INTEGER NOT NULL,
      $content TEXT NOT NULL,
      FOREIGN KEY ($stopPointId)
       REFERENCES ${StopPointTable.tableName}(${StopPointTable.id}),
      FOREIGN KEY ($travelerId)
       REFERENCES ${TravelerTable.tableName}(${TravelerTable.id})
    );
  ''';
}
