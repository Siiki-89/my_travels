import 'package:my_travels/data/tables/travel_table.dart';
import 'package:my_travels/data/tables/traveler_table.dart';

/// Represents the join table between travels and travelers (many-to-many relationship).
///
/// This class defines the structure of the `TravelTraveler` table, which links
/// entries from the `Travel` and `Traveler` tables.
abstract class TravelTravelerTable {
  /// The name of the table in the database.
  static const String tableName = 'TravelTraveler';

  /// The name of the foreign key column referencing the travel table.
  static const String travelId = 'travel_id';

  /// The name of the foreign key column referencing the traveler table.
  static const String travelerId = 'traveler_id';

  /// The SQL statement to create the join table.
  ///
  /// It uses a composite primary key consisting of both `travelId` and `travelerId`
  /// to ensure each traveler is associated with a travel only once.
  static const String createTable =
      '''
    CREATE TABLE $tableName(
      $travelId INTEGER NOT NULL,
      $travelerId INTEGER NOT NULL,
      PRIMARY KEY ($travelId, $travelerId),
      FOREIGN KEY ($travelId)
       REFERENCES ${TravelTable.tableName}(${TravelTable.id}),
      FOREIGN KEY ($travelerId)
       REFERENCES ${TravelerTable.tableName}(${TravelerTable.id})
    );
  ''';
}
