import 'package:sqflite/sqflite.dart';

import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/local/database_service.dart';
import 'package:my_travels/data/tables/stop_point_table.dart';
import 'package:my_travels/data/tables/travel_table.dart';
import 'package:my_travels/data/tables/travel_traveler_table.dart';
import 'package:my_travels/data/tables/traveler_table.dart';

/// Manages travel-related data operations with the local database.
class TravelRepository {
  /// The singleton instance of the database service.
  final DatabaseService _dbService = DatabaseService.instance;

  /// Inserts a new travel itinerary and its associated data into the database.
  ///
  /// This includes the travel details, its stop points, and the links to its
  /// travelers. The operation is performed in a transaction for data integrity.
  Future<void> insertTravel(Travel travel) async {
    final db = await _dbService.database;
    try {
      await db.transaction((txn) async {
        // Ensures a new travel is always marked as not finished by default.
        final travelToInsert = travel.copyWith(isFinished: false);
        final travelMap = travelToInsert.toMap();

        final travelId = await txn.insert(
          TravelTable.tableName,
          travelMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        for (final stopPoint in travel.stopPoints) {
          final stopPointMap = stopPoint.toMap();
          stopPointMap[StopPointTable.travelId] = travelId;
          await txn.insert(StopPointTable.tableName, stopPointMap);
        }

        for (final traveler in travel.travelers) {
          if (traveler.id != null) {
            await txn.insert(TravelTravelerTable.tableName, {
              TravelTravelerTable.travelId: travelId,
              TravelTravelerTable.travelerId: traveler.id,
            });
          }
        }
      });
    } catch (e) {
      // debugPrint('Erro ao inserir viagem: $e');
      rethrow;
    }
  }

  /// Retrieves a single, complete travel object by its ID.
  ///
  /// This includes its list of stop points and associated travelers.
  /// Returns `null` if no travel with the given [id] is found.
  Future<Travel?> getTravelById(int id) async {
    final db = await _dbService.database;
    final travelMaps = await db.query(
      TravelTable.tableName,
      where: '${TravelTable.id} = ?',
      whereArgs: [id],
    );

    if (travelMaps.isEmpty) return null;

    final travelMap = travelMaps.first;

    final stopPointMaps = await db.query(
      StopPointTable.tableName,
      where: '${StopPointTable.travelId} = ?',
      whereArgs: [id],
      orderBy: '${StopPointTable.stopOrder} ASC',
    );
    final stopPoints = stopPointMaps
        .map((map) => StopPoint.fromMap(map))
        .toList();

    final linkMaps = await db.query(
      TravelTravelerTable.tableName,
      where: '${TravelTravelerTable.travelId} = ?',
      whereArgs: [id],
    );
    final travelerIds = linkMaps
        .map((map) => map[TravelTravelerTable.travelerId] as int)
        .toList();

    var travelers = <Traveler>[];
    if (travelerIds.isNotEmpty) {
      final travelersMaps = await db.query(
        TravelerTable.tableName,
        where: '${TravelerTable.id} IN (${travelerIds.join(',')})',
      );
      travelers = travelersMaps.map((map) => Traveler.fromMap(map)).toList();
    }

    return Travel.fromMap(
      travelMap,
      stopPoints: stopPoints,
      travelers: travelers,
    );
  }

  /// Retrieves a list of all travels, including their details.
  Future<List<Travel>> getTravels() async {
    final db = await _dbService.database;
    final travelMaps = await db.query(TravelTable.tableName);
    final travels = <Travel>[];

    for (final travelMap in travelMaps) {
      final fullTravel = await getTravelById(travelMap[TravelTable.id] as int);
      if (fullTravel != null) {
        travels.add(fullTravel);
      }
    }
    return travels;
  }

  /// Deletes a travel and all its associated data from the database.
  ///
  /// This includes stop points and traveler links, performed in a transaction.
  Future<void> deleteTravel(int travelId) async {
    final db = await _dbService.database;
    try {
      await db.transaction((txn) async {
        await txn.delete(
          TravelTravelerTable.tableName,
          where: '${TravelTravelerTable.travelId} = ?',
          whereArgs: [travelId],
        );
        await txn.delete(
          StopPointTable.tableName,
          where: '${StopPointTable.travelId} = ?',
          whereArgs: [travelId],
        );
        await txn.delete(
          TravelTable.tableName,
          where: '${TravelTable.id} = ?',
          whereArgs: [travelId],
        );
      });
    } catch (e) {
      // debugPrint('Erro ao deletar viagem: $e');
      rethrow;
    }
  }

  /// Updates a travel's status to finished (is_finished = 1).
  Future<void> markTravelAsFinished(int travelId) async {
    final db = await _dbService.database;
    try {
      await db.update(
        TravelTable.tableName,
        {TravelTable.isFinished: 1}, // 1 representa 'true'
        where: '${TravelTable.id} = ?',
        whereArgs: [travelId],
      );
    } catch (e) {
      // debugPrint('Erro ao marcar viagem como finalizada: $e');
      rethrow;
    }
  }

  /// Updates a travel's status to unfinished (is_finished = 0).
  Future<void> markTravelAsUnfinished(int travelId) async {
    final db = await _dbService.database;
    try {
      await db.update(
        TravelTable.tableName,
        {TravelTable.isFinished: 0}, // 0 representa 'false'
        where: '${TravelTable.id} = ?',
        whereArgs: [travelId],
      );
    } catch (e) {
      // debugPrint('Erro ao marcar viagem como "em andamento": $e');
      rethrow;
    }
  }
}
