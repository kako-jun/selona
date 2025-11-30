import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../shared/models/media_file.dart';

/// Thumbnail card for a single media file
class ThumbnailCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Material(
      color: SelonaColors.backgroundSecondary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder thumbnail
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: SelonaColors.surface,
              ),
              child: Icon(
                file.isVideo ? Icons.videocam : Icons.image,
                size: 40,
                color: SelonaColors.textMuted,
              ),
            ),

            // Video indicator
            if (file.isVideo)
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
            if (file.isBookmarked)
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
            if (file.rating > 0)
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
                      '${file.rating}',
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
            if (file.isUnviewed)
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
}
