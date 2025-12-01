import 'package:flutter_test/flutter_test.dart';
import 'package:selona/shared/utils/responsive_grid.dart';

void main() {
  group('ResponsiveGrid', () {
    group('calculateColumnCount', () {
      const minSize = 100.0;
      const maxSize = 200.0;

      test('returns 1 column for very narrow width', () {
        // 150px - 24px padding = 126px effective
        // Can only fit 1 column at min 100px
        final columns =
            ResponsiveGrid.calculateColumnCount(150, minSize, maxSize);
        expect(columns, 1);
      });

      test('returns 2 columns for phone width', () {
        // 360px - 24px padding = 336px effective
        // 2 columns: (336 - 4) / 2 = 166px per item (within 100-200 range)
        final columns =
            ResponsiveGrid.calculateColumnCount(360, minSize, maxSize);
        expect(columns, 2);
      });

      test('returns more columns for tablet width', () {
        // 768px - 24px padding = 744px effective
        // Should fit 4-5 columns
        final columns =
            ResponsiveGrid.calculateColumnCount(768, minSize, maxSize);
        expect(columns, greaterThanOrEqualTo(4));
        expect(columns, lessThanOrEqualTo(6));
      });

      test('returns more columns for desktop width', () {
        // 1200px - 24px padding = 1176px effective
        // Should fit 6+ columns
        final columns =
            ResponsiveGrid.calculateColumnCount(1200, minSize, maxSize);
        expect(columns, greaterThanOrEqualTo(6));
      });

      test('respects maximum column limit of 10', () {
        // Very wide screen
        final columns =
            ResponsiveGrid.calculateColumnCount(3000, minSize, maxSize);
        expect(columns, lessThanOrEqualTo(10));
      });

      test('item size stays within bounds', () {
        // Test various widths
        for (final width in [300.0, 400.0, 600.0, 800.0, 1000.0, 1500.0]) {
          final columns =
              ResponsiveGrid.calculateColumnCount(width, minSize, maxSize);

          // Calculate actual item size
          final effectiveWidth = width - 24;
          final gaps = columns - 1;
          final totalSpacing = gaps * 4.0;
          final itemSize = (effectiveWidth - totalSpacing) / columns;

          // Item size should be within acceptable range (or at limit)
          expect(
            itemSize,
            greaterThanOrEqualTo(minSize - 1), // Allow small rounding error
            reason: 'Width $width: item size $itemSize should be >= $minSize',
          );
        }
      });

      test('increasing width does not decrease columns', () {
        int previousColumns = 1;
        for (final width in [
          200.0,
          300.0,
          400.0,
          500.0,
          600.0,
          800.0,
          1000.0
        ]) {
          final columns =
              ResponsiveGrid.calculateColumnCount(width, minSize, maxSize);
          expect(
            columns,
            greaterThanOrEqualTo(previousColumns),
            reason: 'Width $width should have >= $previousColumns columns',
          );
          previousColumns = columns;
        }
      });
    });

    group('breakpoints', () {
      test('phone max width is defined', () {
        expect(ResponsiveGrid.phoneMaxWidth, 600);
      });

      test('tablet max width is defined', () {
        expect(ResponsiveGrid.tabletMaxWidth, 900);
      });

      test('desktop max width is defined', () {
        expect(ResponsiveGrid.desktopMaxWidth, 1200);
      });
    });

    group('thumbnail size constants', () {
      test('min thumbnail size is reasonable', () {
        expect(ResponsiveGrid.minThumbnailSize, greaterThan(50));
        expect(ResponsiveGrid.minThumbnailSize, lessThan(200));
      });

      test('max thumbnail size is larger than min', () {
        expect(
          ResponsiveGrid.maxThumbnailSize,
          greaterThan(ResponsiveGrid.minThumbnailSize),
        );
      });
    });
  });
}
