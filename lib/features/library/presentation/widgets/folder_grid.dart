import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
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
            onLongPress:
                onFolderLongPress != null ? () => onFolderLongPress!(folder) : null,
          );
        },
        childCount: folders.length,
      ),
    );
  }
}

/// Card widget for a single folder
class FolderCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Material(
      color: SelonaColors.backgroundSecondary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.folder,
                size: 40,
                color: SelonaColors.primaryAccent,
              ),
              const Spacer(),
              Text(
                folder.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(folder.updatedAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: SelonaColors.textMuted,
                    ),
              ),
            ],
          ),
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
