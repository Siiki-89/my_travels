import 'package:my_travels/data/tables/travel_table.dart';

abstract class StopPointTable {
  static const String tableName = 'StopPoint';
  static const String id = 'id';
  static const String travelId = 'travel_id';
  static const String stopOrder = 'stop_order';
  static const String locationName = 'location_name';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String description = 'description';
  static const String arrivalDate = 'arrival_date';
  static const String departureDate = 'departure_date';

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
      FOREIGN KEY ($travelId) REFERENCES ${TravelTable.tableName}(${TravelTable.id})
    );
  ''';
}
