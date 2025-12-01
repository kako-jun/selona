import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/services/thumbnail_service.dart';
import '../../../../shared/models/media_file.dart';

/// Thumbnail card for a single media file
class ThumbnailCard extends StatefulWidget {
  final MediaFile file;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ThumbnailCard({
    super.key,
    required this.file,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<ThumbnailCard> createState() => _ThumbnailCardState();
}

class _ThumbnailCardState extends State<ThumbnailCard> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    final bytes = await ThumbnailService.instance.decodeThumbnail(widget.file.id);
    if (mounted) {
      setState(() {
        _thumbnailBytes = bytes;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SelonaColors.backgroundSecondary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail image or placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _isLoading
                  ? Container(
                      color: SelonaColors.surface,
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : _thumbnailBytes != null
                      ? Image.memory(
                          _thumbnailBytes!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
            ),

            // Video indicator
            if (widget.file.isVideo)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(179),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow,
                        size: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),

            // Bookmark indicator
            if (widget.file.isBookmarked)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.bookmark,
                  size: 20,
                  color: SelonaColors.primaryAccent,
                ),
              ),

            // Rating indicator
            if (widget.file.rating > 0)
              Positioned(
                bottom: 8,
                left: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: SelonaColors.warning,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${widget.file.rating}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Unviewed indicator
            if (widget.file.isUnviewed)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: SelonaColors.info,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: SelonaColors.surface,
      child: Center(
        child: Icon(
          widget.file.isVideo ? Icons.videocam : Icons.image,
          size: 32,
          color: SelonaColors.textSecondary,
        ),
      ),
    );
  }
}
