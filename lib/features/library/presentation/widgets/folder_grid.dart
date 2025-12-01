import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/services/thumbnail_service.dart';
import '../../../../shared/models/folder.dart';
import '../../../../shared/utils/responsive_grid.dart';

/// Grid view for displaying folders
/// Automatically adjusts column count based on screen width
class FolderGrid extends StatelessWidget {
  final List<Folder> folders;
  final void Function(Folder folder) onFolderTap;
  final void Function(Folder folder)? onFolderLongPress;

  const FolderGrid({
    super.key,
    required this.folders,
    required this.onFolderTap,
    this.onFolderLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: ResponsiveGrid.getFolderGridDelegate(context),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final folder = folders[index];
          return FolderCard(
            folder: folder,
            onTap: () => onFolderTap(folder),
            onLongPress: onFolderLongPress != null
                ? () => onFolderLongPress!(folder)
                : null,
          );
        },
        childCount: folders.length,
      ),
    );
  }
}

/// Card widget for a single folder with 2x2 preview grid
class FolderCard extends StatefulWidget {
  final Folder folder;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const FolderCard({
    super.key,
    required this.folder,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<FolderCard> createState() => _FolderCardState();
}

class _FolderCardState extends State<FolderCard> {
  final _thumbnailService = ThumbnailService.instance;
  final Map<String, Uint8List?> _thumbnails = {};
  bool _loadingThumbnails = false;

  @override
  void initState() {
    super.initState();
    _loadThumbnails();
  }

  @override
  void didUpdateWidget(FolderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.folder.previewFileIds != widget.folder.previewFileIds) {
      _loadThumbnails();
    }
  }

  Future<void> _loadThumbnails() async {
    if (_loadingThumbnails) return;
    _loadingThumbnails = true;

    for (final fileId in widget.folder.previewFileIds.take(4)) {
      if (!mounted) return;
      final data = await _thumbnailService.decodeThumbnail(fileId);
      if (mounted) {
        setState(() {
          _thumbnails[fileId] = data;
        });
      }
    }
    _loadingThumbnails = false;
  }

  @override
  Widget build(BuildContext context) {
    final hasPreview = widget.folder.previewFileIds.isNotEmpty;

    return Material(
      color: SelonaColors.backgroundSecondary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview area (2x2 grid or folder icon)
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: hasPreview ? _buildPreviewGrid() : _buildFolderIcon(),
              ),
            ),
            // Folder info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.folder.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (widget.folder.fileCount > 0) ...[
                        Text(
                          '${widget.folder.fileCount}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: SelonaColors.textMuted,
                                  ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          _formatDate(widget.folder.updatedAt),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: SelonaColors.textMuted,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderIcon() {
    return Container(
      color: SelonaColors.surface,
      child: const Center(
        child: Icon(
          Icons.folder,
          size: 48,
          color: SelonaColors.primaryAccent,
        ),
      ),
    );
  }

  Widget _buildPreviewGrid() {
    final previewIds = widget.folder.previewFileIds.take(4).toList();
    final count = previewIds.length;

    if (count == 1) {
      return _buildThumbnailImage(previewIds[0]);
    }

    return GridView.count(
      crossAxisCount: 2,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: [
        for (int i = 0; i < 4; i++)
          if (i < count)
            _buildThumbnailImage(previewIds[i])
          else
            Container(color: SelonaColors.surface),
      ],
    );
  }

  Widget _buildThumbnailImage(String fileId) {
    final data = _thumbnails[fileId];
    if (data != null) {
      return Image.memory(
        data,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: SelonaColors.surface,
      child: const Center(
        child: Icon(
          Icons.image,
          size: 24,
          color: SelonaColors.textMuted,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
