/// Represents the traveler table in the database.
///
/// This class holds static constants for the table name, its columns,
/// and the SQL command to create it.
abstract class TravelerTable {
  /// The name of the table in the database.
  static const String tableName = 'Traveler';

  /// The name of the primary key column.
  static const String id = 'id';

  /// The name of the column for the traveler's name.
  static const String name = 'name';

  /// The name of the column for the traveler's age.
  static const String age = 'age';

  /// The name of the column for the traveler's photo file path.
  static const String photoPath = 'photoPath';

  /// The SQL statement to create the traveler table.
  static const String createTable =
      '''
        CREATE TABLE $tableName(
            $id INTEGER PRIMARY KEY AUTOINCREMENT,
            $name TEXT NOT NULL,
            $age INTEGER,
            $photoPath TEXT
        );
        ''';
}
