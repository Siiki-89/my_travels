import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/local/database_service.dart';
import 'package:my_travels/data/tables/traveler_table.dart';
import 'package:sqflite/sqflite.dart';

class TravelerRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  static const String _tableName = TravelerTable.tableName;

  // CREATE
  Future<int> insertTraveler(Traveler traveler) async {
    final db = await _dbService.database;
    return await db.insert(
      _tableName,
      traveler.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ ALL TRAVELERS
  Future<List<Traveler>> getTravelers() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
      return Traveler.fromMap(maps[i]);
    });
  }

  // READ TRAVELER BY ID
  Future<Traveler?> getTravelerById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: '${TravelerTable.id} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Traveler.fromMap(maps.first);
    }
    return null;
  }

  // DELETE TRAVELER
  Future<int> deleteTraveler(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      _tableName,
      where: '${TravelerTable.id} = ?',
      whereArgs: [id],
    );
  }

  // UPDATE TRAVELER
  Future<int> updateTraveler(Traveler traveler) async {
    final db = await _dbService.database;
    return await db.update(
      _tableName,
      traveler.toMap(),
      where: '${TravelerTable.id} = ?',
      whereArgs: [traveler.id],
    );
  }
}
