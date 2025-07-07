import 'package:my_travels/data/entities/traveler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../tables/traveler_table.dart';

class TravelerRepository {
  static Database? _database;
  static const String _tableName = 'Traveler';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'my_travels.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(TravelerTable.createTable);
      },
    );
  }

  // CRUD

  // CREATE
  Future<int> insertTraveler(Traveler traveler) async {
    final db = await database;
    return await db.insert(
      _tableName,
      traveler.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ ALL TRAVELERS
  Future<List<Traveler>> getTravelers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
      return Traveler.fromMap(maps[i]);
    });
  }

  // READ TRAVELER BY ID
}
