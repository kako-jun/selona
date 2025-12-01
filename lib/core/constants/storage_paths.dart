import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Storage path utilities for the app sandbox
class StoragePaths {
  StoragePaths._();

  static Directory? _appDir;
  static Directory? _tempDir;

  /// Initialize storage paths
  static Future<void> initialize() async {
    _appDir = await getApplicationDocumentsDirectory();
    _tempDir = await getTemporaryDirectory();
  }

  /// Get the app documents directory
  static Directory get appDirectory {
    if (_appDir == null) {
      throw StateError(
          'StoragePaths not initialized. Call initialize() first.');
    }
    return _appDir!;
  }

  /// Get the temp directory
  static Directory get tempDirectory {
    if (_tempDir == null) {
      throw StateError(
          'StoragePaths not initialized. Call initialize() first.');
    }
    return _tempDir!;
  }

  /// Get the encrypted files directory (flat storage of UUID.pnk files)
  static String get pnkFilesDir {
    return path.join(appDirectory.path, 'vault');
  }

  /// Get the encrypted thumbnails directory
  static String get thumbnailsDir {
    return path.join(pnkFilesDir, 'thumbs');
  }

  /// Get the encrypted database file path
  static String get databasePnkPath {
    return path.join(appDirectory.path, 'selona.pnk');
  }

  /// Get the temp directory for decoded files during viewing
  static String get decodeTempDir {
    return path.join(tempDirectory.path, 'selona_decode');
  }

  /// Get the temp database path (decoded for use)
  static String get tempDatabasePath {
    return path.join(decodeTempDir, 'selona.db');
  }

  /// Get path for an encrypted file by UUID
  static String pnkFilePath(String uuid) {
    return path.join(pnkFilesDir, '$uuid.pnk');
  }

  /// Get path for an encrypted thumbnail by UUID
  static String thumbnailPnkPath(String uuid) {
    return path.join(thumbnailsDir, '$uuid.pnk');
  }

  /// Get temp path for a decoded file (for viewing)
  static String tempDecodedPath(String uuid, String originalExtension) {
    return path.join(decodeTempDir, '$uuid$originalExtension');
  }

  /// Ensure all required directories exist
  static Future<void> ensureDirectoriesExist() async {
    final dirs = [
      Directory(pnkFilesDir),
      Directory(thumbnailsDir),
      Directory(decodeTempDir),
    ];

    for (final dir in dirs) {
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }
  }

  /// Clean up all temp decoded files
  static Future<void> cleanupTempFiles() async {
    final dir = Directory(decodeTempDir);
    if (await dir.exists()) {
      await for (final entity in dir.list()) {
        if (entity is File) {
          try {
            await entity.delete();
          } catch (_) {
            // Ignore errors during cleanup
          }
        }
      }
    }
  }

  /// Delete a specific temp file
  static Future<void> deleteTempFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
