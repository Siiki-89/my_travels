import 'package:my_travels/data/tables/comment_table.dart';

abstract class CommentPhotoTable {
  static const String tableName = 'CommentPhoto';
  static const String id = 'id';
  static const String commentId = 'comment_id';
  static const String imagePath = 'image_path';

  static const String createTable =
      '''
    CREATE TABLE $tableName(
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $commentId INTEGER NOT NULL,
      $imagePath TEXT NOT NULL,
      FOREIGN KEY ($commentId) REFERENCES ${CommentTable.tableName}(${CommentTable.id})
    );
  ''';
}
