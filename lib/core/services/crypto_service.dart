import 'dart:io';

import 'package:flutter/foundation.dart';

import '../constants/storage_paths.dart';
import '../ffi/api/crypto.dart' as rust_crypto;

/// Service for encoding/decoding files using pink072 via Rust FFI
class CryptoService {
  CryptoService._();
  static final instance = CryptoService._();

  String? _passphrase;

  /// Set the passphrase (called after authentication)
  void setPassphrase(String passphrase) {
    if (passphrase.length != 9) {
      throw ArgumentError('Passphrase must be exactly 9 characters');
    }
    _passphrase = passphrase;
  }

  /// Clear the passphrase (called on lock/logout)
  void clearPassphrase() {
    _passphrase = null;
  }

  /// Check if passphrase is set
  bool get hasPassphrase => _passphrase != null;

  /// Encode a file to .pnk format and save to vault
  /// The uuid is provided by the caller (from MediaFileRepository)
  Future<void> encodeFile(String sourcePath, String uuid) async {
    _ensurePassphrase();

    final outputPath = StoragePaths.pnkFilePath(uuid);

    // Ensure output directory exists
    await Directory(StoragePaths.pnkFilesDir).create(recursive: true);

    rust_crypto.encodeToPnk(
      inputPath: sourcePath,
      outputPath: outputPath,
      passphrase: _passphrase!,
    );

    debugPrint('Encoded $sourcePath -> $outputPath');
  }

  /// Decode a .pnk file to temp directory for viewing
  /// Returns the path to the decoded temp file
  Future<String> decodeFileForViewing(
      String uuid, String originalExtension) async {
    _ensurePassphrase();

    final pnkPath = StoragePaths.pnkFilePath(uuid);
    final tempDir = StoragePaths.decodeTempDir;

    // Ensure temp directory exists
    await Directory(tempDir).create(recursive: true);

    final decodedFilename = rust_crypto.decodeFromPnk(
      inputPath: pnkPath,
      outputDir: tempDir,
    );

    final tempPath = '$tempDir/$decodedFilename';

    debugPrint('Decoded $pnkPath -> $tempPath');
    return tempPath;
  }

  /// Delete a temp decoded file after viewing
  Future<void> deleteTempFile(String tempPath) async {
    try {
      rust_crypto.deleteTempFile(path: tempPath);
      debugPrint('Deleted temp file: $tempPath');
    } catch (e) {
      debugPrint('Failed to delete temp file: $e');
    }
  }

  /// Encode the database to .pnk format
  Future<void> encodeDatabase() async {
    _ensurePassphrase();

    final dbPath = StoragePaths.tempDatabasePath;
    final pnkPath = StoragePaths.databasePnkPath;

    if (!await File(dbPath).exists()) {
      debugPrint('No database to encode');
      return;
    }

    rust_crypto.encodeToPnk(
      inputPath: dbPath,
      outputPath: pnkPath,
      passphrase: _passphrase!,
    );

    debugPrint('Encoded database -> $pnkPath');
  }

  /// Decode the database .pnk for use
  /// Returns true if database was decoded, false if no database exists
  Future<bool> decodeDatabase() async {
    _ensurePassphrase();

    final pnkPath = StoragePaths.databasePnkPath;
    final tempDir = StoragePaths.decodeTempDir;

    if (!await File(pnkPath).exists()) {
      debugPrint('No encrypted database found');
      return false;
    }

    // Ensure temp directory exists
    await Directory(tempDir).create(recursive: true);

    rust_crypto.decodeFromPnk(
      inputPath: pnkPath,
      outputDir: tempDir,
    );

    final dbPath = StoragePaths.tempDatabasePath;

    debugPrint('Decoded database -> $dbPath');
    return true;
  }

  /// Delete the encrypted file from vault
  Future<void> deleteEncryptedFile(String uuid) async {
    final pnkPath = StoragePaths.pnkFilePath(uuid);
    final file = File(pnkPath);
    if (await file.exists()) {
      await file.delete();
      debugPrint('Deleted encrypted file: $pnkPath');
    }
  }

  /// Encode thumbnail to .pnk
  Future<void> encodeThumbnail(String sourcePath, String uuid) async {
    _ensurePassphrase();

    final outputPath = StoragePaths.thumbnailPnkPath(uuid);

    // Ensure thumbnail directory exists
    await Directory(StoragePaths.thumbnailsDir).create(recursive: true);

    rust_crypto.encodeToPnk(
      inputPath: sourcePath,
      outputPath: outputPath,
      passphrase: _passphrase!,
    );

    debugPrint('Encoded thumbnail -> $outputPath');
  }

  /// Decode thumbnail for display
  /// Returns the decoded bytes, or null if not available
  Future<Uint8List?> decodeThumbnail(String uuid) async {
    _ensurePassphrase();

    final pnkPath = StoragePaths.thumbnailPnkPath(uuid);
    final file = File(pnkPath);

    if (!await file.exists()) {
      return null;
    }

    try {
      return rust_crypto.decodeToBytes(inputPath: pnkPath);
    } catch (e) {
      debugPrint('Failed to decode thumbnail: $e');
      return null;
    }
  }

  /// Delete thumbnail .pnk
  Future<void> deleteThumbnail(String uuid) async {
    final pnkPath = StoragePaths.thumbnailPnkPath(uuid);
    final file = File(pnkPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Clean up all temp files (call on app exit/background)
  Future<void> cleanupAllTempFiles() async {
    await StoragePaths.cleanupTempFiles();
    debugPrint('Cleaned up all temp files');
  }

  void _ensurePassphrase() {
    if (_passphrase == null) {
      throw StateError('Passphrase not set. Call setPassphrase() first.');
    }
  }
}
