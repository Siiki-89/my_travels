import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/local/database_service.dart';
import 'package:my_travels/data/tables/stop_point_table.dart';
import 'package:my_travels/data/tables/travel_table.dart';
import 'package:my_travels/data/tables/travel_traveler_table.dart';
import 'package:my_travels/data/tables/traveler_table.dart';

class TravelRepository {
  TravelRepository({required this.dbService});
  final DatabaseService dbService;

  Future<void> insertTravel(Travel travel) async {
    final db = await dbService.database;

    await db.transaction((txn) async {
      final travelId = await txn.insert(travelTableName, travel.toMap());

      for (final stopPoint in travel.stopPoints) {
        final stopPointMap = stopPoint.toMap();
        stopPointMap[stopPointTableTravelId] = travelId;
        await txn.insert(stopPointTableName, stopPointMap);
      }

      for (final traveler in travel.travelers) {
        if (traveler.id != null) {
          final link = {
            travelTravelerTableTravelId: travelId,
            travelTravelerTableTravelerId: traveler.id,
          };
          await txn.insert(travelTravelerTableName, link);
        }
      }
    });
  }

  Future<Travel?> getTravelById(int id) async {
    final db = await dbService.database;
    final travelMaps = await db.query(
      travelTableName,
      where: '$travelTableId = ?',
      whereArgs: [id],
    );

    if (travelMaps.isEmpty) return null;

    final travelMap = travelMaps.first;
    final travelIdValue = travelMap[travelTableId] as int;

    final stopPointMaps = await db.query(
      stopPointTableName,
      where: '$stopPointTableTravelId = ?',
      whereArgs: [travelIdValue],
      orderBy: '$stopPointTableStopOrder ASC',
    );
    final stopPoints = stopPointMaps.map(StopPoint.fromMap).toList();

    final linkMaps = await db.query(
      travelTravelerTableName,
      where: '$travelTravelerTableTravelId = ?',
      whereArgs: [travelIdValue],
    );
    final travelerIds = linkMaps
        .map((map) => map[travelTravelerTableTravelerId] as int)
        .toList();

    var travelers = <Traveler>[];
    if (travelerIds.isNotEmpty) {
      final travelersMaps = await db.query(
        travelerTableName,
        where: '$travelerTableId IN (${travelerIds.join(',')})',
      );
      travelers = travelersMaps.map(Traveler.fromMap).toList();
    }

    return Travel.fromMap(
      travelMap,
      stopPoints: stopPoints,
      travelers: travelers,
    );
  }

  Future<List<Travel>> getTravels() async {
    final db = await dbService.database;
    final travelMaps = await db.query(travelTableName);
    final travels = <Travel>[];

    for (final travelMap in travelMaps) {
      // Para a lista da home, buscamos a viagem completa.
      // Uma otimização futura seria buscar uma versão resumida.
      final travel = await getTravelById(travelMap[travelTableId] as int);
      if (travel != null) {
        travels.add(travel);
      }
    }
    return travels;
  }
}
