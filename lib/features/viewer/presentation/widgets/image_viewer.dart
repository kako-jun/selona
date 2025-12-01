import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../app/theme.dart';
import '../../../../core/services/crypto_service.dart';
import '../../../../core/database/media_file_repository.dart';
import '../../../../shared/models/media_file.dart';
import '../../../../shared/models/app_settings.dart';

/// Image viewer widget with zoom, pan, and rotation support
/// Rotation is persisted per file and applied automatically
class ImageViewerWidget extends StatefulWidget {
  final MediaFile file;
  final ImageViewMode viewMode;

  const ImageViewerWidget({
    super.key,
    required this.file,
    this.viewMode = ImageViewMode.horizontal,
  });

  @override
  State<ImageViewerWidget> createState() => _ImageViewerWidgetState();
}

class _ImageViewerWidgetState extends State<ImageViewerWidget> {
  final _crypto = CryptoService.instance;
  final _mediaRepo = MediaFileRepository.instance;

  String? _decodedFilePath;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(ImageViewerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.id != widget.file.id) {
      _cleanupOldFile();
      _loadImage();
    }
  }

  @override
  void dispose() {
    _cleanupOldFile();
    super.dispose();
  }

  Future<void> _cleanupOldFile() async {
    if (_decodedFilePath != null) {
      try {
        await _crypto.deleteTempFile(_decodedFilePath!);
      } catch (_) {}
      _decodedFilePath = null;
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get original extension from database
      final extension = await _mediaRepo.getOriginalExtension(widget.file.id);

      // Decode the encrypted file to a temp location
      final decodedPath = await _crypto.decodeFileForViewing(
        widget.file.id,
        extension,
      );

      if (mounted) {
        setState(() {
          _decodedFilePath = decodedPath;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null || _decodedFilePath == null) {
      return _buildErrorWidget(context);
    }

    return Transform.rotate(
      angle: _getRotationAngle(),
      child: PhotoView(
        imageProvider: FileImage(File(_decodedFilePath!)),
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 4,
        initialScale: PhotoViewComputedScale.contained,
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(context),
      ),
    );
  }

  /// Convert rotation enum to radians
  double _getRotationAngle() {
    return widget.file.rotation.degrees * math.pi / 180;
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: SelonaColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            widget.file.name,
            style: const TextStyle(
              color: SelonaColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                style: const TextStyle(
                  color: SelonaColors.textMuted,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
