import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../../shared/models/media_file.dart';
import '../database/folder_repository.dart';
import '../database/media_file_repository.dart';
import 'crypto_service.dart';
import 'thumbnail_service.dart';

/// Progress callback for import operations (simple version)
typedef ImportProgressCallback = void Function(int current, int total);

/// Progress callback for import operations (with filename)
typedef ImportProgressCallbackWithName = void Function(
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
  final _thumbnail = ThumbnailService.instance;

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

  /// Supported archive extensions
  static const archiveExtensions = {'.zip'};

  /// All supported extensions (media only, not archives)
  static Set<String> get supportedExtensions =>
      {...imageExtensions, ...videoExtensions};

  /// Check if extension is supported (including archives)
  bool isSupportedExtension(String ext) {
    final lower = ext.toLowerCase();
    return supportedExtensions.contains(lower) ||
        archiveExtensions.contains(lower);
  }

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

      // Generate thumbnail
      await _thumbnail.generateThumbnail(mediaFile.id, sourcePath, mediaType);

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

  /// Import multiple files (with ZIP extraction support)
  Future<ImportResult> importFiles(
    List<String> filePaths, {
    String? targetFolderId,
    bool deleteAfterImport = false,
    ImportProgressCallback? onProgress,
  }) async {
    final errors = <String>[];
    var successCount = 0;

    // Expand ZIPs first
    final expandedFiles = <String>[];
    for (final filePath in filePaths) {
      final ext = path.extension(filePath).toLowerCase();
      if (archiveExtensions.contains(ext)) {
        // Extract ZIP
        final extracted = await _extractZip(filePath);
        expandedFiles.addAll(extracted);
      } else {
        expandedFiles.add(filePath);
      }
    }

    for (var i = 0; i < expandedFiles.length; i++) {
      final filePath = expandedFiles[i];
      onProgress?.call(i + 1, expandedFiles.length);

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
      totalFiles: expandedFiles.length,
      successCount: successCount,
      failureCount: expandedFiles.length - successCount,
      errors: errors,
    );
  }

  /// Extract ZIP file and return list of extracted file paths
  Future<List<String>> _extractZip(String zipPath) async {
    final extractedPaths = <String>[];

    try {
      final bytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final tempDir = Directory.systemTemp.createTempSync('selona_extract_');

      for (final file in archive) {
        if (file.isFile) {
          final ext = path.extension(file.name).toLowerCase();
          if (supportedExtensions.contains(ext)) {
            final outputPath = path.join(tempDir.path, file.name);
            final outputDir = Directory(path.dirname(outputPath));
            if (!outputDir.existsSync()) {
              outputDir.createSync(recursive: true);
            }
            final outputFile = File(outputPath);
            await outputFile.writeAsBytes(file.content as List<int>);
            extractedPaths.add(outputPath);
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to extract ZIP: $e');
    }

    return extractedPaths;
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

    // Create root folder for the imported folder itself
    final rootFolderName = path.basename(folderPath);
    final rootFolder = await _folderRepo.createPath(rootFolderName);
    final rootFolderId = rootFolder.id;

    // Create folder structure and import files
    final errors = <String>[];
    var successCount = 0;
    final folderCache = <String, String>{}; // relative path -> folder ID

    for (var i = 0; i < filesToImport.length; i++) {
      final item = filesToImport[i];
      onProgress?.call(i + 1, filesToImport.length);

      try {
        // Get or create folder for this file
        String folderId = rootFolderId;
        if (item.relativeFolderPath.isNotEmpty) {
          // Create subfolder path under the root folder
          final fullRelativePath = '$rootFolderName/${item.relativeFolderPath}';
          folderId = await _getOrCreateFolder(
            fullRelativePath,
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
  /// Uses FolderRepository.createPath which handles duplicate checking
  Future<String> _getOrCreateFolder(
    String relativeFolderPath,
    String? parentFolderId,
    Map<String, String> cache,
  ) async {
    // Check cache first
    final cacheKey = '${parentFolderId ?? ''}/$relativeFolderPath';
    if (cache.containsKey(cacheKey)) {
      return cache[cacheKey]!;
    }

    // Use createPath which handles existing folder lookup
    final folder = await _folderRepo.createPath(relativeFolderPath);
    cache[cacheKey] = folder.id;
    return folder.id;
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
