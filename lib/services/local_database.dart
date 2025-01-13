
// ignore_for_file: depend_on_referenced_packages

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseHelper {
  static final LocalDatabaseHelper _instance =
      LocalDatabaseHelper._internal();
  static Database? _database;

  static LocalDatabaseHelper get i => _instance;

  LocalDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'locations.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE locations (
            id INTEGER PRIMARY KEY,
            location TEXT,
            serverSynced INTEGER,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  // Retrieve locations with pagination
  Future<List<Map<String, dynamic>>> getLocations(
    int page,
    int pageSize, {
    bool ascending = false,
    bool? synced,
    DateTime? before,
    DateTime? after,
  }) async {
    final String orderBy = ascending ? "id ASC" : "id DESC";
    final db = await database;
    final offset = (page - 1) * pageSize;

    List<String> whereConditions = [];
    List<dynamic> whereArgs = [];

    if (synced == false) {
      whereConditions.add('serverSynced = 0');
    } else if (synced == true) {
      whereConditions.add('serverSynced = 1');
    }

    if (before != null) {
      whereConditions.add('timestamp <= ?');
      whereArgs.add(before.toUtc().toIso8601String());
    }

    if (after != null) {
      whereConditions.add('timestamp >= ?');
      whereArgs.add(after.toUtc().toIso8601String());
    }

    String? where =
        whereConditions.isEmpty ? null : whereConditions.join(' AND ');

    final locations = await db.query(
      'locations',
      orderBy: orderBy,
      limit: pageSize,
      offset: offset,
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );

    return locations;
  }

  // Remove location data
  Future<void> deleteLocations(List<int> ids) async {
    final db = await database;
    await db.delete(
      'locations',
      where: 'id IN (${List.filled(ids.length, '?').join(', ')})',
      whereArgs: ids,
    );
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('locations');
  }

  Future<void> saveLocations(List<Map<String,dynamic>> locations) async {
    final db = await database;
    final batch = db.batch();

    for (final location in locations) {
      batch.insert(
        'locations',
        location,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<void> updateLocations(List<Map<String,dynamic>> locationData) async {
    final db = await database;
    final batch = db.batch();

    for (var location in locationData) {
      batch.update(
        'locations',
        location,
        where: 'id = ?',
        whereArgs: [location["id"]],
      );
    }

    await batch.commit();
  }
}
