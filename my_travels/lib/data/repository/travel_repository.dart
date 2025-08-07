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
      // 1. Insere a viagem principal e pega o ID gerado
      final travelId = await txn.insert(TravelTable.tableName, travel.toMap());

      // 2. Insere os pontos de parada (destinos)
      for (final stopPoint in travel.stopPoints) {
        // Cria um novo mapa para poder adicionar o travelId
        final stopPointMap = stopPoint.toMap();
        stopPointMap['travel_id'] = travelId;
        await txn.insert(StopPointTable.tableName, stopPointMap);
      }

      // 3. Insere a ligação entre viagem e viajantes
      for (final traveler in travel.travelers) {
        if (traveler.id != null) {
          final link = {'travel_id': travelId, 'traveler_id': traveler.id};
          await txn.insert(TravelTravelerTable.tableName, link);
        }
      }
    });
  }

  // --- MÉTODO DE LEITURA ADICIONADO ---
  Future<List<Travel>> getTravels() async {
    final db = await _dbService.database;

    // 1. Busca todas as viagens principais
    final List<Map<String, dynamic>> travelMaps = await db.query(
      TravelTable.tableName,
    );

    final List<Travel> travels = [];

    // 2. Para cada viagem, busca suas informações relacionadas
    for (var travelMap in travelMaps) {
      final travelId = travelMap[TravelTable.id] as int;

      // 3. Busca os pontos de parada (destinos) desta viagem
      final List<Map<String, dynamic>> stopPointMaps = await db.query(
        StopPointTable.tableName,
        where: '${StopPointTable.travelId} = ?',
        whereArgs: [travelId],
        orderBy: '${StopPointTable.stopOrder} ASC', // Garante a ordem correta
      );
      final stopPoints = stopPointMaps
          .map((map) => StopPoint.fromMap(map))
          .toList();

      // 4. Busca os IDs dos viajantes ligados a esta viagem
      final List<Map<String, dynamic>> linkMaps = await db.query(
        TravelTravelerTable.tableName,
        where: '${TravelTravelerTable.travelId} = ?',
        whereArgs: [travelId],
      );
      final travelerIds = linkMaps
          .map((map) => map[TravelTravelerTable.travelerId] as int)
          .toList();

      // 5. Busca os dados completos dos viajantes usando os IDs
      List<Traveler> travelers = [];
      if (travelerIds.isNotEmpty) {
        final travelersMaps = await db.query(
          TravelerTable.tableName,
          where: '${TravelerTable.id} IN (${travelerIds.join(',')})',
        );
        travelers = travelersMaps.map((map) => Traveler.fromMap(map)).toList();
      }

      // 6. Monta o objeto Travel completo e adiciona à lista
      travels.add(
        Travel.fromMap(travelMap, stopPoints: stopPoints, travelers: travelers),
      );
    }

    return travels;
  }
}
