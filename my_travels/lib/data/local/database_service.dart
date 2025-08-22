import 'package:my_travels/data/tables/comment_photo_table.dart';
import 'package:my_travels/data/tables/comment_table.dart';
import 'package:my_travels/data/tables/stop_point_table.dart';
import 'package:my_travels/data/tables/travel_table.dart';
import 'package:my_travels/data/tables/travel_traveler_table.dart';
import 'package:my_travels/data/tables/traveler_table.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('my_travels.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(TravelerTable.createTable);
    await db.execute(TravelTable.createTable);
    await db.execute(StopPointTable.createTable);
    await db.execute(TravelTravelerTable.createTable);
    await db.execute(CommentTable.createTable);
    await db.execute(CommentPhotoTable.createTable);
  }
}
