/// Represents the main travel table in the database.
///
/// This class holds static constants for the table name, its columns,
/// and the SQL command to create it.
abstract class TravelTable {
  /// The name of the table in the database.
  static const String tableName = 'Travel';

  /// The name of the primary key column.
  static const String id = 'id';

  /// The name of the column for the travel's title.
  static const String title = 'title';

  /// The name of the column for the travel's start date.
  static const String startDate = 'start_date';

  /// The name of the column for the travel's end date.
  static const String endDate = 'end_date';

  /// The name of the column describing the vehicle used (e.g., car, plane).
  static const String vehicle = 'vehicle';

  /// The name of the column for the cover image file path.
  static const String coverImagePath = 'cover_image_path';

  /// The name of the column that flags if the travel is finished.
  ///
  /// Stored as an integer: 0 for false, 1 for true.
  static const String isFinished = 'is_finished';

  /// The SQL statement to create the travel table.
  static const String createTable =
      '''
    CREATE TABLE $tableName(
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $title TEXT NOT NULL,
      $startDate DATE,
      $endDate DATE,
      $vehicle TEXT,
      $coverImagePath TEXT,
      $isFinished INTEGER NOT NULL DEFAULT 0
    );
  ''';
}
