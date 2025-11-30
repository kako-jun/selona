import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../app/theme.dart';
import '../../../../shared/models/media_file.dart';
import '../../../../shared/models/app_settings.dart';

/// Image viewer widget with zoom and pan support
class ImageViewerWidget extends StatelessWidget {
  final MediaFile file;
  final ImageViewMode viewMode;

  const ImageViewerWidget({
    super.key,
    required this.file,
    this.viewMode = ImageViewMode.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Load actual decrypted image from encrypted file

    return PhotoView.customChild(
      backgroundDecoration: const BoxDecoration(
        color: Colors.black,
      ),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 4,
      initialScale: PhotoViewComputedScale.contained,
      child: _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image,
            size: 80,
            color: SelonaColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            file.name,
            style: const TextStyle(
              color: SelonaColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatFileSize(file.fileSize),
            style: const TextStyle(
              color: SelonaColors.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
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
