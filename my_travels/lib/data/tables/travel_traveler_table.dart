import 'package:my_travels/data/tables/travel_table.dart';
import 'package:my_travels/data/tables/traveler_table.dart';

abstract class TravelTravelerTable {
  static const String tableName = 'TravelTraveler';
  static const String travelId = 'travel_id';
  static const String travelerId = 'traveler_id';

  static const String createTable =
      '''
    CREATE TABLE $tableName(
      $travelId INTEGER NOT NULL,
      $travelerId INTEGER NOT NULL,
      PRIMARY KEY ($travelId, $travelerId),
      FOREIGN KEY ($travelId) REFERENCES ${TravelTable.tableName}(${TravelTable.id}),
      FOREIGN KEY ($travelerId) REFERENCES ${TravelerTable.tableName}(${TravelerTable.id})
    );
  ''';
}
