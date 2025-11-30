import 'package:path/path.dart' as path;

import '../constants/app_constants.dart';
import '../../shared/models/media_file.dart';

/// Utility functions for file operations
class FileUtils {
  FileUtils._();

  /// Check if a file extension is a supported image type
  static bool isSupportedImage(String filePath) {
    final ext = path.extension(filePath).toLowerCase().replaceFirst('.', '');
    return AppConstants.supportedImageExtensions.contains(ext);
  }

  /// Check if a file extension is a supported video type
  static bool isSupportedVideo(String filePath) {
    final ext = path.extension(filePath).toLowerCase().replaceFirst('.', '');
    return AppConstants.supportedVideoExtensions.contains(ext);
  }

  /// Check if a file is a supported media type
  static bool isSupportedMedia(String filePath) {
    return isSupportedImage(filePath) || isSupportedVideo(filePath);
  }

  /// Get the media type from a file path
  static MediaType? getMediaType(String filePath) {
    if (isSupportedImage(filePath)) {
      return MediaType.image;
    } else if (isSupportedVideo(filePath)) {
      return MediaType.video;
    }
    return null;
  }

  /// Get file extension without the dot
  static String getExtension(String filePath) {
    return path.extension(filePath).toLowerCase().replaceFirst('.', '');
  }

  /// Get file name without extension
  static String getBaseName(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// Get file name with extension
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  /// Format file size as human readable string
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
