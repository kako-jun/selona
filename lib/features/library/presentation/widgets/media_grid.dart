import 'package:flutter/material.dart';

import '../../../../shared/models/media_file.dart';
import '../../../../shared/utils/responsive_grid.dart';
import 'thumbnail_card.dart';

/// Grid view for displaying media files
/// Automatically adjusts column count based on screen width
class MediaGrid extends StatelessWidget {
  final List<MediaFile> files;
  final void Function(MediaFile file) onFileTap;
  final void Function(MediaFile file)? onFileLongPress;

  const MediaGrid({
    super.key,
    required this.files,
    required this.onFileTap,
    this.onFileLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: ResponsiveGrid.getMediaGridDelegate(context),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final file = files[index];
          return ThumbnailCard(
            file: file,
            onTap: () => onFileTap(file),
            onLongPress:
                onFileLongPress != null ? () => onFileLongPress!(file) : null,
          );
        },
        childCount: files.length,
      ),
    );
  }
}
