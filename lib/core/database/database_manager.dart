import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/storage_paths.dart';
import '../services/crypto_service.dart';

/// Manages the SQLite database with pnk encryption
///
/// The database is stored encrypted as selona.pnk when not in use.
/// On startup, it's decoded to a temp location.
/// On app exit/background, it's encoded back to pnk format.
class DatabaseManager {
  DatabaseManager._();
  static final instance = DatabaseManager._();

  Database? _database;
  final _crypto = CryptoService.instance;
  bool _isInitialized = false;

  /// Current database version
  static const int _version = 1;

  /// Get the database instance
  Database get database {
    if (_database == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _database!;
  }

  /// Check if database is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the database (decode from pnk if exists)
  Future<void> initialize() async {
    if (_isInitialized) return;

    await StoragePaths.ensureDirectoriesExist();

    // Try to decode existing database
    final hasExisting = await _crypto.decodeDatabase();

    final dbPath = StoragePaths.tempDatabasePath;

    _database = await openDatabase(
      dbPath,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    _isInitialized = true;
    debugPrint('Database initialized at $dbPath (existing: $hasExisting)');
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        parent_id TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (parent_id) REFERENCES folders (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE media_files (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        original_extension TEXT NOT NULL,
        folder_id TEXT,
        media_type TEXT NOT NULL,
        file_size INTEGER NOT NULL,
        imported_at INTEGER NOT NULL,
        last_viewed_at INTEGER,
        last_playback_position INTEGER,
        rotation INTEGER DEFAULT 0,
        rating INTEGER DEFAULT 0,
        is_bookmarked INTEGER DEFAULT 0,
        view_count INTEGER DEFAULT 0,
        FOREIGN KEY (folder_id) REFERENCES folders (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE bookmarks (
        id TEXT PRIMARY KEY,
        media_file_id TEXT NOT NULL,
        position INTEGER,
        label TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (media_file_id) REFERENCES media_files (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE playlists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE playlist_items (
        id TEXT PRIMARY KEY,
        playlist_id TEXT NOT NULL,
        media_file_id TEXT NOT NULL,
        sort_order INTEGER NOT NULL,
        FOREIGN KEY (playlist_id) REFERENCES playlists (id) ON DELETE CASCADE,
        FOREIGN KEY (media_file_id) REFERENCES media_files (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE view_history (
        id TEXT PRIMARY KEY,
        media_file_id TEXT NOT NULL,
        viewed_at INTEGER NOT NULL,
        FOREIGN KEY (media_file_id) REFERENCES media_files (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_folders_parent ON folders (parent_id)');
    await db
        .execute('CREATE INDEX idx_media_folder ON media_files (folder_id)');
    await db.execute('CREATE INDEX idx_media_type ON media_files (media_type)');
    await db.execute(
        'CREATE INDEX idx_media_bookmarked ON media_files (is_bookmarked)');
    await db.execute(
        'CREATE INDEX idx_history_file ON view_history (media_file_id)');
    await db
        .execute('CREATE INDEX idx_history_date ON view_history (viewed_at)');
    await db.execute(
        'CREATE INDEX idx_playlist_items_playlist ON playlist_items (playlist_id)');

    debugPrint('Database tables created');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here
    debugPrint('Database upgraded from $oldVersion to $newVersion');
  }

  /// Save and encrypt the database (call on app exit/background)
  Future<void> saveAndEncrypt() async {
    if (!_isInitialized || _database == null) return;

    // Close the database
    await _database!.close();
    _database = null;

    // Encode to pnk
    await _crypto.encodeDatabase();

    // Delete temp database
    final tempDb = File(StoragePaths.tempDatabasePath);
    if (await tempDb.exists()) {
      await tempDb.delete();
    }

    _isInitialized = false;
    debugPrint('Database saved and encrypted');
  }

  /// Close the database without saving (for emergency/lock)
  Future<void> closeWithoutSaving() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    // Delete temp database
    final tempDb = File(StoragePaths.tempDatabasePath);
    if (await tempDb.exists()) {
      await tempDb.delete();
    }

    _isInitialized = false;
    debugPrint('Database closed without saving');
  }
}
