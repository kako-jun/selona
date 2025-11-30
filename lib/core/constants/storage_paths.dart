import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Storage path utilities for the app sandbox
class StoragePaths {
  StoragePaths._();

  static Directory? _appDir;

  /// Initialize storage paths
  static Future<void> initialize() async {
    _appDir = await getApplicationDocumentsDirectory();
  }

  /// Get the app documents directory
  static Directory get appDirectory {
    if (_appDir == null) {
      throw StateError('StoragePaths not initialized. Call initialize() first.');
    }
    return _appDir!;
  }

  /// Get the encrypted files directory
  static String get encryptedFilesDir {
    return path.join(appDirectory.path, 'encrypted_files');
  }

  /// Get the encrypted thumbnails directory
  static String get thumbnailsDir {
    return path.join(encryptedFilesDir, 'thumbs');
  }

  /// Get the database file path
  static String get databasePath {
    return path.join(appDirectory.path, 'selona.db');
  }

  /// Get path for an encrypted file by UUID
  static String encryptedFilePath(String uuid) {
    return path.join(encryptedFilesDir, '$uuid.enc');
  }

  /// Get path for an encrypted thumbnail by UUID
  static String thumbnailPath(String uuid) {
    return path.join(thumbnailsDir, '${uuid}_thumb.enc');
  }

  /// Ensure all required directories exist
  static Future<void> ensureDirectoriesExist() async {
    final dirs = [
      Directory(encryptedFilesDir),
      Directory(thumbnailsDir),
    ];

    for (final dir in dirs) {
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }
  }
}
