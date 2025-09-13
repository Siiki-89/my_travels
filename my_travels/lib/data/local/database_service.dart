import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:my_travels/data/tables/comment_photo_table.dart';
import 'package:my_travels/data/tables/comment_table.dart';
import 'package:my_travels/data/tables/stop_point_table.dart';
import 'package:my_travels/data/tables/travel_table.dart';
import 'package:my_travels/data/tables/travel_traveler_table.dart';
import 'package:my_travels/data/tables/traveler_table.dart';

/// A singleton class to manage the application's database connection.
class DatabaseService {
  /// Private constructor for the singleton pattern.
  DatabaseService._init();

  /// The single, static instance of the database service.
  static final DatabaseService instance = DatabaseService._init();

  /// The underlying database instance.
  static Database? _database;

  /// Public getter for the database.
  ///
  /// If the database is already initialized, it returns the existing instance.
  /// Otherwise, it initializes the database and then returns it.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('my_travels.db');
    return _database!;
  }

  /// Initializes the database by finding or creating the database file.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  /// Creates all the necessary tables when the database is first created.
  Future<void> _createDB(Database db, int version) async {
    await db.execute(TravelerTable.createTable);
    await db.execute(TravelTable.createTable);
    await db.execute(StopPointTable.createTable);
    await db.execute(TravelTravelerTable.createTable);
    await db.execute(CommentTable.createTable);
    await db.execute(CommentPhotoTable.createTable);
  }
}
