abstract class TravelTable {
  static const String tableName = 'Travel';
  static const String id = 'id';
  static const String title = 'title';
  static const String startDate = 'start_date';
  static const String endDate = 'end_date';
  static const String vehicle = 'vehicle';
  static const String coverImagePath = 'cover_image_path';
  static const String isFinished = 'is_finished';

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
