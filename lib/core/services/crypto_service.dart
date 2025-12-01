import 'dart:io';

import 'package:flutter/foundation.dart';

import '../constants/storage_paths.dart';

/// Service for encoding/decoding files using pink072 via Rust FFI
///
/// TODO: Replace mock implementation with actual flutter_rust_bridge calls
/// once code generation is complete.
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

    // TODO: Call Rust FFI
    // await rust_lib.encode_to_pnk(sourcePath, outputPath, _passphrase!);

    // Mock: Just copy the file for now
    await File(sourcePath).copy(outputPath);

    debugPrint('Encoded $sourcePath -> $outputPath');
  }

  /// Decode a .pnk file to temp directory for viewing
  /// Returns the path to the decoded temp file
  Future<String> decodeFileForViewing(String uuid, String originalExtension) async {
    _ensurePassphrase();

    final pnkPath = StoragePaths.pnkFilePath(uuid);
    final tempDir = StoragePaths.decodeTempDir;
    final tempPath = StoragePaths.tempDecodedPath(uuid, originalExtension);

    // Ensure temp directory exists
    await Directory(tempDir).create(recursive: true);

    // TODO: Call Rust FFI
    // await rust_lib.decode_from_pnk(pnkPath, tempDir);

    // Mock: Just copy the file for now
    await File(pnkPath).copy(tempPath);

    debugPrint('Decoded $pnkPath -> $tempPath');
    return tempPath;
  }

  /// Delete a temp decoded file after viewing
  Future<void> deleteTempFile(String tempPath) async {
    // TODO: Call Rust FFI for secure deletion
    // await rust_lib.delete_temp_file(tempPath);

    await StoragePaths.deleteTempFile(tempPath);
    debugPrint('Deleted temp file: $tempPath');
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

    // TODO: Call Rust FFI
    // await rust_lib.encode_to_pnk(dbPath, pnkPath, _passphrase!);

    // Mock: Just copy
    await File(dbPath).copy(pnkPath);

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

    // TODO: Call Rust FFI
    // await rust_lib.decode_from_pnk(pnkPath, tempDir);

    // Mock: Just copy
    final tempPath = StoragePaths.tempDatabasePath;
    await File(pnkPath).copy(tempPath);

    debugPrint('Decoded database -> $tempPath');
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

    // TODO: Call Rust FFI
    // await rust_lib.encode_to_pnk(sourcePath, outputPath, _passphrase!);

    // Mock: Just copy
    await File(sourcePath).copy(outputPath);

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

    // TODO: Call Rust FFI to decode to memory
    // return await rust_lib.decode_from_pnk_to_bytes(pnkPath, _passphrase!);

    // Mock: Just read the file
    return await file.readAsBytes();
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
