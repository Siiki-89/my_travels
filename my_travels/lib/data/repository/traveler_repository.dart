import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/data/local/database_service.dart';
import 'package:my_travels/data/tables/traveler_table.dart';
import 'package:sqflite/sqflite.dart';

class TravelerRepository {
  TravelerRepository({required this.dbService});
  final DatabaseService dbService;

  Future<int> insertTraveler(Traveler traveler) async {
    final db = await dbService.database;
    return db.insert(
      travelerTableName,
      traveler.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Traveler>> getTravelers() async {
    final db = await dbService.database;
    final maps = await db.query(travelerTableName);
    return List.generate(maps.length, (i) {
      return Traveler.fromMap(maps[i]);
    });
  }

  Future<int> deleteTraveler(int id) async {
    final db = await dbService.database;
    return db.delete(
      travelerTableName,
      where: '$travelerTableId = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateTraveler(Traveler traveler) async {
    final db = await dbService.database;
    return db.update(
      travelerTableName,
      traveler.toMap(),
      where: '$travelerTableId = ?',
      whereArgs: [traveler.id],
    );
  }
}
