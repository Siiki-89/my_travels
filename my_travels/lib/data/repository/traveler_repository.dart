import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/local/database_service.dart';
import 'package:my_travels/data/tables/traveler_table.dart';
import 'package:sqflite/sqflite.dart';

class TravelerRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<int> insertTraveler(Traveler traveler) async {
    final db = await _dbService.database;
    // O toMap da entidade não deve incluir o ID para inserções.
    final map = traveler.toMap();
    map.remove('id');

    return db.insert(
      TravelerTable.tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Traveler>> getTravelers() async {
    final db = await _dbService.database;
    final maps = await db.query(TravelerTable.tableName);
    return List.generate(maps.length, (i) {
      return Traveler.fromMap(maps[i]);
    });
  }

  Future<int> deleteTraveler(int id) async {
    final db = await _dbService.database;
    return db.delete(
      TravelerTable.tableName,
      where: '${TravelerTable.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateTraveler(Traveler traveler) async {
    final db = await _dbService.database;
    return db.update(
      TravelerTable.tableName,
      traveler.toMap(),
      where: '${TravelerTable.id} = ?',
      whereArgs: [traveler.id],
    );
  }
}
