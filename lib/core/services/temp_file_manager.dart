import 'dart:async';
import 'dart:collection';

import 'crypto_service.dart';

/// Manages temporary decoded files with automatic cleanup
///
/// Tracks which files are currently in use and cleans up
/// files that are no longer needed.
class TempFileManager {
  TempFileManager._();
  static final instance = TempFileManager._();

  final _crypto = CryptoService.instance;

  /// Currently active temp files (uuid -> temp path)
  final _activeFiles = <String, String>{};

  /// Files that have been released but not yet deleted
  final _pendingCleanup = Queue<String>();

  /// Timer for periodic cleanup
  Timer? _cleanupTimer;

  /// Maximum number of files to keep in pending cleanup
  static const _maxPendingFiles = 10;

  /// Start periodic cleanup (call on app start)
  void startPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performCleanup(),
    );
  }

  /// Stop periodic cleanup (call on app exit)
  void stopPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  /// Acquire a decoded file for viewing
  /// Returns the path to the temp file
  Future<String> acquireFile(String uuid, String originalExtension) async {
    // Check if already decoded
    if (_activeFiles.containsKey(uuid)) {
      return _activeFiles[uuid]!;
    }

    // Decode the file
    final tempPath =
        await _crypto.decodeFileForViewing(uuid, originalExtension);
    _activeFiles[uuid] = tempPath;

    return tempPath;
  }

  /// Release a file (mark as no longer in use)
  /// The file will be deleted when appropriate
  void releaseFile(String uuid) {
    final tempPath = _activeFiles.remove(uuid);
    if (tempPath != null) {
      _pendingCleanup.add(tempPath);

      // If too many pending files, clean up oldest
      if (_pendingCleanup.length > _maxPendingFiles) {
        _performCleanup();
      }
    }
  }

  /// Release all files (call when navigating away from viewer)
  void releaseAllFiles() {
    for (final entry in _activeFiles.entries) {
      _pendingCleanup.add(entry.value);
    }
    _activeFiles.clear();
    _performCleanup();
  }

  /// Check if a file is currently active
  bool isFileActive(String uuid) => _activeFiles.containsKey(uuid);

  /// Get temp path for an active file
  String? getActivePath(String uuid) => _activeFiles[uuid];

  /// Perform cleanup of pending files
  Future<void> _performCleanup() async {
    while (_pendingCleanup.isNotEmpty) {
      final path = _pendingCleanup.removeFirst();
      await _crypto.deleteTempFile(path);
    }
  }

  /// Force cleanup of all temp files (call on app exit/lock)
  Future<void> forceCleanupAll() async {
    // Clean pending
    await _performCleanup();

    // Clean active (force release)
    for (final path in _activeFiles.values) {
      await _crypto.deleteTempFile(path);
    }
    _activeFiles.clear();

    // Clean any remaining files in temp directory
    await _crypto.cleanupAllTempFiles();
  }
}
