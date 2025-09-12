import 'package:my_travels/data/tables/comment_table.dart';

/// Represents the database table for comment photos.
///
/// This class contains static constants for the table name, column names,
/// and the SQL command to create the table.
abstract class CommentPhotoTable {
  /// The name of the table in the database.
  static const String tableName = 'CommentPhoto';

  /// The name of the primary key column.
  static const String id = 'id';

  /// The name of the foreign key column that references the comment table.
  static const String commentId = 'comment_id';

  /// The name of the column that stores the image path.
  static const String imagePath = 'image_path';

  /// The SQL statement to create the comment photo table.
  static const String createTable =
      '''
    CREATE TABLE $tableName(
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $commentId INTEGER NOT NULL,
      $imagePath TEXT NOT NULL,
      FOREIGN KEY ($commentId) 
        REFERENCES ${CommentTable.tableName}(${CommentTable.id})
    );
  ''';
}
