import 'package:flutter/foundation.dart';
import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/local/database_service.dart';
import 'package:my_travels/data/tables/stop_point_table.dart';
import 'package:my_travels/data/tables/travel_table.dart';
import 'package:my_travels/data/tables/travel_traveler_table.dart';
import 'package:my_travels/data/tables/traveler_table.dart';
import 'package:sqflite/sqflite.dart';

class TravelRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<void> insertTravel(Travel travel) async {
    final db = await _dbService.database;
    try {
      await db.transaction((txn) async {
        // ### MELHORIA: Garante que a viagem seja sempre inserida como "não finalizada" ###
        final travelToInsert = travel.copyWith(isFinished: false);
        final travelMap = travelToInsert.toMap();

        // Não é preciso remover o 'id' do mapa, o método 'insert' do sqflite o ignora
        // quando a chave primária é AUTOINCREMENT.
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
      debugPrint('Erro ao inserir viagem: $e');
      rethrow;
    }
  }

  // >> A MELHORIA PONTUAL QUE VOCÊ APROVOU <<
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

  Future<List<Travel>> getTravels() async {
    final db = await _dbService.database;
    final travelMaps = await db.query(TravelTable.tableName);
    final travels = <Travel>[];

    for (final travelMap in travelMaps) {
      // Usamos a nova função para buscar os detalhes completos
      final fullTravel = await getTravelById(travelMap[TravelTable.id] as int);
      if (fullTravel != null) {
        travels.add(fullTravel);
      }
    }
    return travels;
  }

  Future<void> deleteTravel(int travelId) async {
    final db = await _dbService.database;
    try {
      // Usamos uma transação para garantir que todas as operações
      // sejam concluídas com sucesso. Se uma falhar, todas são revertidas.
      await db.transaction((txn) async {
        // Passo 1: Deletar os links na tabela de junção (travel_traveler)
        await txn.delete(
          TravelTravelerTable.tableName,
          where: '${TravelTravelerTable.travelId} = ?',
          whereArgs: [travelId],
        );

        // Passo 2: Deletar todos os pontos de parada (stop points) associados
        await txn.delete(
          StopPointTable.tableName,
          where: '${StopPointTable.travelId} = ?',
          whereArgs: [travelId],
        );

        // Passo 3: Finalmente, deletar a viagem principal
        await txn.delete(
          TravelTable.tableName,
          where: '${TravelTable.id} = ?',
          whereArgs: [travelId],
        );
      });
      debugPrint(
        'Viagem com ID $travelId e todos os dados associados foram deletados.',
      );
    } catch (e) {
      debugPrint('Erro ao deletar a viagem com ID $travelId: $e');
      rethrow; // Re-lança a exceção para que a camada superior (provider) possa lidar com ela.
    }
  }

  Future<void> markTravelAsFinished(int travelId) async {
    final db = await _dbService.database;
    try {
      await db.update(
        TravelTable.tableName,
        {TravelTable.isFinished: 1}, // 1 representa 'true'
        where: '${TravelTable.id} = ?',
        whereArgs: [travelId],
      );
      debugPrint('Viagem com ID $travelId marcada como finalizada.');
    } catch (e) {
      debugPrint('Erro ao marcar a viagem $travelId como finalizada: $e');
      rethrow;
    }
  }

  /// Atualiza o status de uma viagem para "em andamento" (is_finished = 0).
  Future<void> markTravelAsUnfinished(int travelId) async {
    final db = await _dbService.database;
    try {
      await db.update(
        TravelTable.tableName,
        {TravelTable.isFinished: 0}, // 0 representa 'false'
        where: '${TravelTable.id} = ?',
        whereArgs: [travelId],
      );
      debugPrint('Viagem com ID $travelId marcada como "em andamento".');
    } catch (e) {
      debugPrint('Erro ao marcar a viagem $travelId como "em andamento": $e');
      rethrow;
    }
  }
}
