import 'dart:convert';

import 'package:agora_chat_uikit/provider/chat_uikit_profile.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../exporter.dart';

/// UserDataStore handles local storage of user profiles and chat data using SQLite
class UserDataStore {
  static const String _tableName = 'user_profiles';
  static const String _dbName = 'user_data.db';
  static const int _dbVersion = 2;

  Database? _database;

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute('ALTER TABLE $_tableName ADD COLUMN extension TEXT');
        }
      },
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT,
        avatar_url TEXT,
        type TEXT NOT NULL,
        nickname TEXT,
        group_name TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        extension TEXT
      )
    ''');
  }

  /// Initialize the data store
  Future<void> init({required VoidCallback onOpened}) async {
    try {
      // Initialize database
      await database;

      // Call the onOpened callback
      onOpened();
    } catch (e) {
      logInfo('UserDataStore init error: $e');
      // Still call onOpened even if there's an error
      onOpened();
    }
  }

  /// Save a single user profile
  Future<void> saveUserData(ChatUIKitProfile profile) async {
    try {
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;

      await db.insert(
        _tableName,
        _profileToMap(profile, now),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      logInfo('UserDataStore saveUserData error: $e');
    }
  }

  /// Save multiple user profiles
  Future<void> saveUserDatas(List<ChatUIKitProfile> profiles) async {
    try {
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Use batch for better performance
      final batch = db.batch();

      for (final profile in profiles) {
        batch.insert(
          _tableName,
          _profileToMap(profile, now),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit();
    } catch (e) {
      logInfo('UserDataStore saveUserDatas error: $e');
    }
  }

  /// Load all stored profiles
  Future<List<ChatUIKitProfile>> loadAllProfiles() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(_tableName);

      return maps.map((map) => _profileFromMap(map)).toList();
    } catch (e) {
      logInfo('UserDataStore loadAllProfiles error: $e');
      return [];
    }
  }

  /// Get a specific profile by ID
  Future<ChatUIKitProfile?> getProfileById(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return _profileFromMap(maps.first);
    } catch (e) {
      logInfo('UserDataStore getProfileById error: $e');
      return null;
    }
  }

  /// Delete a profile by ID
  Future<void> deleteProfile(String id) async {
    try {
      final db = await database;
      await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      logInfo('UserDataStore deleteProfile error: $e');
    }
  }

  /// Clear all stored data
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete(_tableName);
    } catch (e) {
      logInfo('UserDataStore clearAllData error: $e');
    }
  }

  /// Convert ChatUIKitProfile to SQLite map
  Map<String, dynamic> _profileToMap(ChatUIKitProfile profile, int timestamp) {
    return {
      'id': profile.id,
      'name': profile.nickname,
      'avatar_url': profile.avatarUrl,
      'type': profile.type.toString(),
      'nickname': profile.nickname,
      'group_name': profile.nickname,
      'created_at': timestamp,
      'updated_at': timestamp,
      'extension': jsonEncode(profile.extension),
    };
  }

  /// Convert SQLite map to ChatUIKitProfile
  ChatUIKitProfile _profileFromMap(Map<String, dynamic> map) {
    final typeString = map['type'] as String;
    final type = ChatUIKitProfileType.values.firstWhere(
      (e) => e.toString() == typeString,
      orElse: () => ChatUIKitProfileType.contact,
    );
    final extension =
        jsonDecode(map['extension'] ?? "{}") as Map<String, dynamic>;

    if (type == ChatUIKitProfileType.group) {
      return ChatUIKitProfile.group(
        id: map['id'] as String,
        groupName: map['group_name'] as String?,
        avatarUrl: map['avatar_url'] as String?,
      );
    } else {
      final profile = ChatUIKitProfile.contact(
        id: map['id'] as String,
        nickname: map['nickname'] as String?,
        avatarUrl: map['avatar_url'] as String?,
        extension: extension.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
      return profile;
    }
  }
}

/// Callback type for initialization
typedef VoidCallback = void Function();
