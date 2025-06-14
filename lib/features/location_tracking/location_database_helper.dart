// ignore_for_file: depend_on_referenced_packages

import 'models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocationDatabaseHelper {
  static final LocationDatabaseHelper _instance =
      LocationDatabaseHelper._internal();
  static Database? _database;

  static LocationDatabaseHelper get i => _instance;

  LocationDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'location.db');
    return await openDatabase(
      path,
      version: 1,
      onUpgrade: (db, oldVersion, newVersion) async {
        // if (oldVersion < 2) {
        //   await db.execute(
        //       "ALTER TABLE locations ADD COLUMN identifier INTEGER DEFAULT 1");
        // }
      },
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE location (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            activity_position TEXT,
            server_synced INTEGER,
            timestamp TEXT, 
            identifier  TEXT
          )
        ''');
      },
    );
  }

  // Retrieve locations with pagination
  Future<List<LocationDataWrapper>> getLocations(
    int page,
    int pageSize, {
    bool ascending = false,
    bool? synced,
    DateTime? before,
    DateTime? after,
    String? identifier,
  }) async {
    final String orderBy = ascending ? "id ASC" : "id DESC";
    final db = await database;
    final offset = (page - 1) * pageSize;

    List<String> whereConditions = [];
    List<dynamic> whereArgs = [];

    if (synced != null) {
      whereConditions.add('server_synced == ?');
      whereArgs.add(synced.toString());
    }

    if (identifier != null) {
      whereConditions.add('identifier == ?');
      whereArgs.add(identifier);
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
      'location',
      orderBy: orderBy,
      limit: pageSize,
      offset: offset,
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );

    return locations.map((e) => LocationDataWrapper.fromMap(e)).toList();
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
    await db.delete('location');
  }

  Future<void> saveActivityLocations(
    List<LocationDataWrapper> locations,
  ) async {
    final db = await database;
    final batch = db.batch();

    for (final location in locations) {
      batch.insert(
        'location',
        location.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<void> updateLocations(List<LocationDataWrapper> locationData) async {
    final db = await database;
    final batch = db.batch();

    for (var location in locationData) {
      batch.update(
        'location',
        location.toMap(),
        where: 'id = ?',
        whereArgs: [location.id],
      );
    }

    await batch.commit();
  }
}
