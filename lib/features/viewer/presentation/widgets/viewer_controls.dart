import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../app/theme.dart';
import '../../../../shared/models/media_file.dart';
import '../../../../shared/models/app_settings.dart';

/// Bottom control bar for the viewer
class ViewerControls extends StatelessWidget {
  final MediaFile file;
  final int currentIndex;
  final int totalFiles;
  final ImageViewMode viewMode;
  final void Function(ImageViewMode mode)? onViewModeChanged;
  final VoidCallback? onRotate;
  final void Function(int rating)? onRatingChanged;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const ViewerControls({
    super.key,
    required this.file,
    required this.currentIndex,
    required this.totalFiles,
    required this.viewMode,
    this.onViewModeChanged,
    this.onRotate,
    this.onRatingChanged,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page indicator
          Text(
            l10n.pageIndicator(currentIndex + 1, totalFiles),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),

          // Main controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: onPrevious != null ? Colors.white : Colors.white38,
                ),
                onPressed: onPrevious,
              ),

              // View mode buttons (for images only)
              if (file.isImage && onViewModeChanged != null) ...[
                _ViewModeButton(
                  icon: Icons.view_day,
                  label: l10n.viewModeVertical,
                  isSelected: viewMode == ImageViewMode.vertical,
                  onTap: () => onViewModeChanged!(ImageViewMode.vertical),
                ),
                _ViewModeButton(
                  icon: Icons.view_carousel,
                  label: l10n.viewModeHorizontal,
                  isSelected: viewMode == ImageViewMode.horizontal,
                  onTap: () => onViewModeChanged!(ImageViewMode.horizontal),
                ),
                _ViewModeButton(
                  icon: Icons.crop_square,
                  label: l10n.viewModeSingle,
                  isSelected: viewMode == ImageViewMode.single,
                  onTap: () => onViewModeChanged!(ImageViewMode.single),
                ),
              ],

              // Rotate button
              IconButton(
                icon: const Icon(Icons.rotate_right, color: Colors.white),
                onPressed: onRotate,
                tooltip: l10n.rotate,
              ),

              // Rating stars
              _RatingWidget(
                rating: file.rating,
                onChanged: onRatingChanged,
              ),

              // Next
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: onNext != null ? Colors.white : Colors.white38,
                ),
                onPressed: onNext,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: IconButton(
        icon: Icon(
          icon,
          color: isSelected ? SelonaColors.primaryAccent : Colors.white,
        ),
        onPressed: onTap,
      ),
    );
  }
}

class _RatingWidget extends StatelessWidget {
  final int rating;
  final void Function(int rating)? onChanged;

  const _RatingWidget({
    required this.rating,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starRating = index + 1;
        return GestureDetector(
          onTap: onChanged != null
              ? () => onChanged!(rating == starRating ? 0 : starRating)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              index < rating ? Icons.star : Icons.star_border,
              size: 20,
              color: index < rating ? SelonaColors.warning : Colors.white54,
            ),
          ),
        );
      }),
    );
  }
}
