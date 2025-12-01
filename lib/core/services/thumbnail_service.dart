import 'dart:io';

import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

import '../../shared/models/media_file.dart';
import '../constants/storage_paths.dart';
import 'crypto_service.dart';

/// Service for generating and managing thumbnails
class ThumbnailService {
  ThumbnailService._();
  static final instance = ThumbnailService._();

  final _crypto = CryptoService.instance;
  final _videoThumbnail = FcNativeVideoThumbnail();

  /// Thumbnail size (width and height)
  static const int thumbnailSize = 200;

  /// JPEG quality for thumbnails
  static const int jpegQuality = 80;

  /// Generate thumbnail for a media file
  /// sourcePath is the decoded (temp) file path
  /// Returns true if successful
  Future<bool> generateThumbnail(
      String uuid, String sourcePath, MediaType type) async {
    try {
      Uint8List? thumbnailData;

      if (type == MediaType.image) {
        thumbnailData = await _generateImageThumbnail(sourcePath);
      } else if (type == MediaType.video) {
        thumbnailData = await _generateVideoThumbnail(sourcePath);
      }

      if (thumbnailData == null) {
        debugPrint('Failed to generate thumbnail for $uuid');
        return false;
      }

      // Save thumbnail as .pnk
      await _saveThumbnailAsPnk(uuid, thumbnailData);
      debugPrint('Generated thumbnail for $uuid');
      return true;
    } catch (e) {
      debugPrint('Thumbnail generation error: $e');
      return false;
    }
  }

  /// Generate thumbnail from image file
  Future<Uint8List?> _generateImageThumbnail(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();

      // Decode and resize in isolate to avoid blocking UI
      return await compute(_resizeImage, bytes);
    } catch (e) {
      debugPrint('Image thumbnail error: $e');
      return null;
    }
  }

  /// Resize image (runs in isolate)
  static Uint8List? _resizeImage(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return null;

    final thumbnail = img.copyResize(
      image,
      width: thumbnailSize,
      height: thumbnailSize,
      maintainAspect: true,
    );

    return Uint8List.fromList(img.encodeJpg(thumbnail, quality: jpegQuality));
  }

  /// Generate thumbnail from video file
  Future<Uint8List?> _generateVideoThumbnail(String videoPath) async {
    // Linux not supported
    if (Platform.isLinux) {
      debugPrint('Video thumbnails not supported on Linux');
      return null;
    }

    try {
      final tempDir = StoragePaths.decodeTempDir;
      await Directory(tempDir).create(recursive: true);

      final tempThumbPath = path.join(
        tempDir,
        'vthumb_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Generate using fc_native_video_thumbnail
      await _videoThumbnail.getVideoThumbnail(
        srcFile: videoPath,
        destFile: tempThumbPath,
        width: thumbnailSize,
        height: thumbnailSize,
        keepAspectRatio: true,
        format: 'jpeg',
        quality: jpegQuality,
      );

      final thumbFile = File(tempThumbPath);
      if (await thumbFile.exists()) {
        final data = await thumbFile.readAsBytes();
        await thumbFile.delete();
        return data;
      }

      return null;
    } catch (e) {
      debugPrint('Video thumbnail error: $e');
      return null;
    }
  }

  /// Save thumbnail data as encrypted .pnk file
  Future<void> _saveThumbnailAsPnk(String uuid, Uint8List thumbnailData) async {
    final tempDir = StoragePaths.decodeTempDir;
    await Directory(tempDir).create(recursive: true);

    // Write temp file
    final tempPath = path.join(tempDir, 'thumb_$uuid.jpg');
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(thumbnailData);

    // Ensure thumbnail directory exists
    final pnkPath = StoragePaths.thumbnailPnkPath(uuid);
    await Directory(path.dirname(pnkPath)).create(recursive: true);

    // Encode to .pnk using crypto service
    await _crypto.encodeThumbnail(tempPath, uuid);

    // Clean up temp
    await tempFile.delete();
  }

  /// Decode thumbnail for display
  /// Returns the decoded thumbnail bytes, or null if not available
  Future<Uint8List?> decodeThumbnail(String uuid) async {
    try {
      return await _crypto.decodeThumbnail(uuid);
    } catch (e) {
      debugPrint('Failed to decode thumbnail: $e');
      return null;
    }
  }

  /// Check if thumbnail exists for a file
  Future<bool> hasThumbnail(String uuid) async {
    final pnkPath = StoragePaths.thumbnailPnkPath(uuid);
    return File(pnkPath).exists();
  }

  /// Delete thumbnail
  Future<void> deleteThumbnail(String uuid) async {
    await _crypto.deleteThumbnail(uuid);
  }
}
