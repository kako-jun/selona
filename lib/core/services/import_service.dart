import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../../shared/models/media_file.dart';
import '../database/folder_repository.dart';
import '../database/media_file_repository.dart';
import 'crypto_service.dart';

/// Progress callback for import operations
typedef ImportProgressCallback = void Function(
    int current, int total, String filename);

/// Result of an import operation
class ImportResult {
  final int totalFiles;
  final int successCount;
  final int failureCount;
  final List<String> errors;

  const ImportResult({
    required this.totalFiles,
    required this.successCount,
    required this.failureCount,
    required this.errors,
  });

  bool get isSuccess => failureCount == 0;
}

/// Service for importing files and folders
class ImportService {
  ImportService._();
  static final instance = ImportService._();

  final _crypto = CryptoService.instance;
  final _folderRepo = FolderRepository.instance;
  final _mediaRepo = MediaFileRepository.instance;

  /// Supported image extensions
  static const imageExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.bmp'
  };

  /// Supported video extensions
  static const videoExtensions = {
    '.mp4',
    '.webm',
    '.mkv',
    '.avi',
    '.mov',
    '.m4v'
  };

  /// All supported extensions
  static Set<String> get supportedExtensions =>
      {...imageExtensions, ...videoExtensions};

  /// Check if a file is a supported media file
  bool isSupportedMedia(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    return supportedExtensions.contains(ext);
  }

  /// Get media type from file extension
  MediaType? getMediaType(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    if (imageExtensions.contains(ext)) return MediaType.image;
    if (videoExtensions.contains(ext)) return MediaType.video;
    return null;
  }

  /// Import a single file
  Future<MediaFile?> importFile(
    String sourcePath, {
    String? targetFolderId,
    bool deleteAfterImport = false,
  }) async {
    final file = File(sourcePath);
    if (!await file.exists()) {
      debugPrint('Import failed: File not found: $sourcePath');
      return null;
    }

    final mediaType = getMediaType(sourcePath);
    if (mediaType == null) {
      debugPrint('Import failed: Unsupported file type: $sourcePath');
      return null;
    }

    try {
      // Get file info
      final stat = await file.stat();
      final fileName = path.basename(sourcePath);

      // Create database entry first (generates UUID)
      final mediaFile = await _mediaRepo.create(
        originalName: fileName,
        folderId: targetFolderId,
        type: mediaType,
        fileSize: stat.size,
      );

      // Encode to .pnk using the generated UUID
      await _crypto.encodeFile(sourcePath, mediaFile.id);

      // Delete original if requested
      if (deleteAfterImport) {
        try {
          await file.delete();
          debugPrint('Deleted original file: $sourcePath');
        } catch (e) {
          debugPrint('Failed to delete original: $e');
        }
      }

      debugPrint('Imported: $fileName -> ${mediaFile.id}');
      return mediaFile;
    } catch (e) {
      debugPrint('Import failed: $e');
      return null;
    }
  }

  /// Import multiple files
  Future<ImportResult> importFiles(
    List<String> filePaths, {
    String? targetFolderId,
    bool deleteAfterImport = false,
    ImportProgressCallback? onProgress,
  }) async {
    final errors = <String>[];
    var successCount = 0;

    for (var i = 0; i < filePaths.length; i++) {
      final filePath = filePaths[i];
      onProgress?.call(i + 1, filePaths.length, path.basename(filePath));

      final result = await importFile(
        filePath,
        targetFolderId: targetFolderId,
        deleteAfterImport: deleteAfterImport,
      );

      if (result != null) {
        successCount++;
      } else {
        errors.add('Failed to import: ${path.basename(filePath)}');
      }
    }

    return ImportResult(
      totalFiles: filePaths.length,
      successCount: successCount,
      failureCount: filePaths.length - successCount,
      errors: errors,
    );
  }

  /// Import a folder (preserving structure)
  Future<ImportResult> importFolder(
    String folderPath, {
    String? targetFolderId,
    bool deleteAfterImport = false,
    ImportProgressCallback? onProgress,
  }) async {
    final dir = Directory(folderPath);
    if (!await dir.exists()) {
      return const ImportResult(
        totalFiles: 0,
        successCount: 0,
        failureCount: 1,
        errors: ['Folder not found'],
      );
    }

    // First, collect all files
    final filesToImport = <_ImportItem>[];
    await _collectFiles(dir, folderPath, filesToImport);

    if (filesToImport.isEmpty) {
      return const ImportResult(
        totalFiles: 0,
        successCount: 0,
        failureCount: 0,
        errors: [],
      );
    }

    // Create folder structure and import files
    final errors = <String>[];
    var successCount = 0;
    final folderCache = <String, String>{}; // relative path -> folder ID

    for (var i = 0; i < filesToImport.length; i++) {
      final item = filesToImport[i];
      onProgress?.call(
          i + 1, filesToImport.length, path.basename(item.filePath));

      try {
        // Get or create folder for this file
        String? folderId = targetFolderId;
        if (item.relativeFolderPath.isNotEmpty) {
          folderId = await _getOrCreateFolder(
            item.relativeFolderPath,
            targetFolderId,
            folderCache,
          );
        }

        // Import the file
        final result = await importFile(
          item.filePath,
          targetFolderId: folderId,
          deleteAfterImport: deleteAfterImport,
        );

        if (result != null) {
          successCount++;
        } else {
          errors.add('Failed to import: ${item.relativePath}');
        }
      } catch (e) {
        errors.add('Error importing ${item.relativePath}: $e');
      }
    }

    // Delete empty folders if deleteAfterImport
    if (deleteAfterImport) {
      try {
        await _deleteEmptyFolders(dir);
      } catch (e) {
        debugPrint('Failed to clean up folders: $e');
      }
    }

    return ImportResult(
      totalFiles: filesToImport.length,
      successCount: successCount,
      failureCount: filesToImport.length - successCount,
      errors: errors,
    );
  }

  /// Collect all supported files from a directory recursively
  Future<void> _collectFiles(
    Directory dir,
    String basePath,
    List<_ImportItem> items,
  ) async {
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && isSupportedMedia(entity.path)) {
        final relativePath = path.relative(entity.path, from: basePath);
        final relativeFolderPath = path.dirname(relativePath);

        items.add(_ImportItem(
          filePath: entity.path,
          relativePath: relativePath,
          relativeFolderPath:
              relativeFolderPath == '.' ? '' : relativeFolderPath,
        ));
      }
    }
  }

  /// Get or create folder from relative path
  Future<String> _getOrCreateFolder(
    String relativeFolderPath,
    String? parentFolderId,
    Map<String, String> cache,
  ) async {
    // Check cache
    final cacheKey = '${parentFolderId ?? ''}/$relativeFolderPath';
    if (cache.containsKey(cacheKey)) {
      return cache[cacheKey]!;
    }

    // Build full path for folder creation
    final parts =
        relativeFolderPath.split('/').where((p) => p.isNotEmpty).toList();
    String? currentParentId = parentFolderId;

    for (final folderName in parts) {
      final partKey = '${currentParentId ?? ''}/$folderName';
      if (cache.containsKey(partKey)) {
        currentParentId = cache[partKey];
      } else {
        final folder = await _folderRepo.create(
          name: folderName,
          parentId: currentParentId,
        );
        cache[partKey] = folder.id;
        currentParentId = folder.id;
      }
    }

    cache[cacheKey] = currentParentId!;
    return currentParentId;
  }

  /// Delete empty folders recursively
  Future<void> _deleteEmptyFolders(Directory dir) async {
    final entities = await dir.list().toList();

    for (final entity in entities) {
      if (entity is Directory) {
        await _deleteEmptyFolders(entity);
      }
    }

    // Check if directory is now empty
    final remaining = await dir.list().toList();
    if (remaining.isEmpty) {
      await dir.delete();
    }
  }
}

/// Internal class to track file import info
class _ImportItem {
  final String filePath;
  final String relativePath;
  final String relativeFolderPath;

  const _ImportItem({
    required this.filePath,
    required this.relativePath,
    required this.relativeFolderPath,
  });
}
