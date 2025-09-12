import 'package:my_travels/data/tables/travel_table.dart';

/// Represents the database table for stop points within a travel itinerary.
///
/// This class holds static constants for the table name, column names,
/// and the SQL command for its creation.
abstract class StopPointTable {
  /// The name of the table in the database.
  static const String tableName = 'StopPoint';

  /// The name of the primary key column.
  static const String id = 'id';

  /// The name of the foreign key column that references the travel table.
  static const String travelId = 'travel_id';

  /// The name of the column that defines the order of the stop in the travel sequence.
  static const String stopOrder = 'stop_order';

  /// The name of the column for the stop point's location name.
  static const String locationName = 'location_name';

  /// The name of the column for the geographic latitude.
  static const String latitude = 'latitude';

  /// The name of the column for the geographic longitude.
  static const String longitude = 'longitude';

  /// The name of the column for a text description of the stop point.
  static const String description = 'description';

  /// The name of the column for the arrival date and time.
  static const String arrivalDate = 'arrival_date';

  /// The name of the column for the departure date and time.
  static const String departureDate = 'departure_date';

  /// The SQL statement to create the stop point table.
  static const String createTable =
      '''
    CREATE TABLE $tableName(
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $travelId INTEGER NOT NULL,
      $stopOrder INTEGER,
      $locationName TEXT NOT NULL,
      $latitude REAL,
      $longitude REAL,
      $description TEXT,
      $arrivalDate DATETIME,
      $departureDate DATETIME,
      FOREIGN KEY ($travelId)
       REFERENCES ${TravelTable.tableName}(${TravelTable.id})
    );
  ''';
}
