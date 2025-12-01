import 'package:flutter/material.dart';

/// Utility class for calculating responsive grid layouts
class ResponsiveGrid {
  ResponsiveGrid._();

  /// Breakpoints for different device sizes
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 900;
  static const double desktopMaxWidth = 1200;

  /// Minimum thumbnail size in pixels
  static const double minThumbnailSize = 100;

  /// Maximum thumbnail size in pixels
  static const double maxThumbnailSize = 200;

  /// Calculate optimal column count for media grid based on screen width
  static int getMediaColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return calculateColumnCount(width, minThumbnailSize, maxThumbnailSize);
  }

  /// Calculate optimal column count for folder grid
  /// Folders are larger than thumbnails, so fewer columns
  static int getFolderColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < phoneMaxWidth) {
      return 2; // Phone portrait
    } else if (width < tabletMaxWidth) {
      return 3; // Tablet portrait or phone landscape
    } else if (width < desktopMaxWidth) {
      return 4; // Tablet landscape
    } else {
      return 5; // Desktop
    }
  }

  /// Calculate column count to fit items between min and max size
  /// @visibleForTesting
  static int calculateColumnCount(
    double availableWidth,
    double minItemSize,
    double maxItemSize,
  ) {
    // Account for padding (12px on each side = 24px total)
    final effectiveWidth = availableWidth - 24;

    // Account for spacing between items (4px per gap)
    // columns = n means n-1 gaps, so total spacing = (n-1) * 4

    // Start with minimum columns and increase until items would be too small
    int columns = 2;
    const spacing = 4.0;

    while (true) {
      final gaps = columns - 1;
      final totalSpacing = gaps * spacing;
      final itemSize = (effectiveWidth - totalSpacing) / columns;

      if (itemSize < minItemSize) {
        // Items would be too small, use previous column count
        return columns - 1 > 0 ? columns - 1 : 1;
      }

      if (itemSize <= maxItemSize) {
        // Items are in acceptable range
        return columns;
      }

      columns++;

      // Safety limit
      if (columns > 10) {
        return 10;
      }
    }
  }

  /// Get the grid delegate for media items
  static SliverGridDelegate getMediaGridDelegate(BuildContext context) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: getMediaColumnCount(context),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      childAspectRatio: 1,
    );
  }

  /// Get the grid delegate for folder items
  static SliverGridDelegate getFolderGridDelegate(BuildContext context) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: getFolderColumnCount(context),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.5,
    );
  }

  /// Check if current device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Check if device width suggests it's a phone
  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < phoneMaxWidth;
  }

  /// Check if device width suggests it's a tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= phoneMaxWidth && width < desktopMaxWidth;
  }

  /// Check if device width suggests it's a desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopMaxWidth;
  }
}
