import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/local/database_service.dart';
import 'package:my_travels/data/tables/stop_point_table.dart';
import 'package:my_travels/data/tables/travel_table.dart';
import 'package:my_travels/data/tables/travel_traveler_table.dart';
import 'package:my_travels/data/tables/traveler_table.dart';

class TravelRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<void> insertTravel(Travel travel) async {
    final db = await _dbService.database;

    await db.transaction((txn) async {
      final travelId = await txn.insert(TravelTable.tableName, travel.toMap());

      for (final stopPoint in travel.stopPoints) {
        final stopPointMap = stopPoint.toMap();
        stopPointMap['travel_id'] = travelId;
        await txn.insert(StopPointTable.tableName, stopPointMap);
      }

      for (final traveler in travel.travelers) {
        if (traveler.id != null) {
          final link = {'travel_id': travelId, 'traveler_id': traveler.id};
          await txn.insert(TravelTravelerTable.tableName, link);
        }
      }
    });
  }


  Future<List<Travel>> getTravels() async {
    final db = await _dbService.database;

    final List<Map<String, dynamic>> travelMaps = await db.query(
      TravelTable.tableName,
    );

    final List<Travel> travels = [];

    for (var travelMap in travelMaps) {
      final travelId = travelMap[TravelTable.id] as int;

      final List<Map<String, dynamic>> stopPointMaps = await db.query(
        StopPointTable.tableName,
        where: '${StopPointTable.travelId} = ?',
        whereArgs: [travelId],
        orderBy: '${StopPointTable.stopOrder} ASC',
      );
      final stopPoints = stopPointMaps
          .map((map) => StopPoint.fromMap(map))
          .toList();

      final List<Map<String, dynamic>> linkMaps = await db.query(
        TravelTravelerTable.tableName,
        where: '${TravelTravelerTable.travelId} = ?',
        whereArgs: [travelId],
      );
      final travelerIds = linkMaps
          .map((map) => map[TravelTravelerTable.travelerId] as int)
          .toList();

      List<Traveler> travelers = [];
      if (travelerIds.isNotEmpty) {
        final travelersMaps = await db.query(
          TravelerTable.tableName,
          where: '${TravelerTable.id} IN (${travelerIds.join(',')})',
        );
        travelers = travelersMaps.map((map) => Traveler.fromMap(map)).toList();
      }

      travels.add(
        Travel.fromMap(travelMap, stopPoints: stopPoints, travelers: travelers),
      );
    }

    return travels;
  }
}
