import 'package:flutter_test/flutter_test.dart';
import 'package:selona/shared/models/media_file.dart';

void main() {
  group('MediaType', () {
    test('fromString returns correct type for image', () {
      expect(MediaType.fromString('image'), MediaType.image);
    });

    test('fromString returns correct type for video', () {
      expect(MediaType.fromString('video'), MediaType.video);
    });

    test('fromString throws for unknown type', () {
      expect(() => MediaType.fromString('audio'), throwsArgumentError);
    });
  });

  group('Rotation', () {
    test('fromDegrees returns correct rotation', () {
      expect(Rotation.fromDegrees(0), Rotation.none);
      expect(Rotation.fromDegrees(90), Rotation.cw90);
      expect(Rotation.fromDegrees(180), Rotation.cw180);
      expect(Rotation.fromDegrees(270), Rotation.cw270);
    });

    test('fromDegrees handles values over 360', () {
      expect(Rotation.fromDegrees(360), Rotation.none);
      expect(Rotation.fromDegrees(450), Rotation.cw90);
      expect(Rotation.fromDegrees(720), Rotation.none);
    });

    test('fromDegrees returns none for invalid degrees', () {
      expect(Rotation.fromDegrees(45), Rotation.none);
      expect(Rotation.fromDegrees(123), Rotation.none);
    });

    test('rotateClockwise cycles through all rotations', () {
      expect(Rotation.none.rotateClockwise(), Rotation.cw90);
      expect(Rotation.cw90.rotateClockwise(), Rotation.cw180);
      expect(Rotation.cw180.rotateClockwise(), Rotation.cw270);
      expect(Rotation.cw270.rotateClockwise(), Rotation.none);
    });

    test('degrees property returns correct value', () {
      expect(Rotation.none.degrees, 0);
      expect(Rotation.cw90.degrees, 90);
      expect(Rotation.cw180.degrees, 180);
      expect(Rotation.cw270.degrees, 270);
    });
  });

  group('MediaFile', () {
    late MediaFile testFile;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testFile = MediaFile(
        id: 'test-uuid-123',
        name: 'test_image.jpg',
        folderId: 'folder-uuid-456',
        type: MediaType.image,
        encryptedPath: '/vault/test-uuid-123.pnk',
        fileSize: 1024000,
        importedAt: testDate,
      );
    });

    test('isVideo returns correct value', () {
      expect(testFile.isVideo, false);

      final videoFile = testFile.copyWith(type: MediaType.video);
      expect(videoFile.isVideo, true);
    });

    test('isImage returns correct value', () {
      expect(testFile.isImage, true);

      final videoFile = testFile.copyWith(type: MediaType.video);
      expect(videoFile.isImage, false);
    });

    test('isUnviewed returns true when never viewed', () {
      expect(testFile.isUnviewed, true);

      final viewedFile = testFile.copyWith(lastViewedAt: DateTime.now());
      expect(viewedFile.isUnviewed, false);
    });

    test('isRated returns correct value', () {
      expect(testFile.isRated, false);

      final ratedFile = testFile.copyWith(rating: 3);
      expect(ratedFile.isRated, true);
    });

    group('toMap/fromMap', () {
      test('roundtrip preserves all fields', () {
        final fullFile = MediaFile(
          id: 'test-id',
          name: 'video.mp4',
          folderId: 'folder-id',
          type: MediaType.video,
          encryptedPath: '/vault/test.pnk',
          encryptedThumbnailPath: '/vault/thumbs/test.pnk',
          fileSize: 5000000,
          importedAt: testDate,
          lastViewedAt: testDate.add(const Duration(days: 1)),
          lastPlaybackPosition: const Duration(minutes: 5, seconds: 30),
          rotation: Rotation.cw90,
          rating: 4,
          isBookmarked: true,
          viewCount: 10,
        );

        final map = fullFile.toMap();
        final restored = MediaFile.fromMap(map);

        expect(restored.id, fullFile.id);
        expect(restored.name, fullFile.name);
        expect(restored.folderId, fullFile.folderId);
        expect(restored.type, fullFile.type);
        expect(restored.encryptedPath, fullFile.encryptedPath);
        expect(
            restored.encryptedThumbnailPath, fullFile.encryptedThumbnailPath);
        expect(restored.fileSize, fullFile.fileSize);
        expect(restored.importedAt, fullFile.importedAt);
        expect(restored.lastViewedAt, fullFile.lastViewedAt);
        expect(restored.lastPlaybackPosition, fullFile.lastPlaybackPosition);
        expect(restored.rotation, fullFile.rotation);
        expect(restored.rating, fullFile.rating);
        expect(restored.isBookmarked, fullFile.isBookmarked);
        expect(restored.viewCount, fullFile.viewCount);
      });

      test('fromMap handles null optional fields', () {
        final map = {
          'id': 'test-id',
          'name': 'image.jpg',
          'folder_id': 'folder-id',
          'media_type': 'image',
          'encrypted_path': '/vault/test.pnk',
          'file_size': 1000,
          'imported_at': testDate.millisecondsSinceEpoch,
        };

        final file = MediaFile.fromMap(map);

        expect(file.encryptedThumbnailPath, isNull);
        expect(file.lastViewedAt, isNull);
        expect(file.lastPlaybackPosition, isNull);
        expect(file.rotation, Rotation.none);
        expect(file.rating, 0);
        expect(file.isBookmarked, false);
        expect(file.viewCount, 0);
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        final updated = testFile.copyWith(
          name: 'new_name.jpg',
          rating: 5,
          isBookmarked: true,
        );

        expect(updated.name, 'new_name.jpg');
        expect(updated.rating, 5);
        expect(updated.isBookmarked, true);
        // Unchanged fields
        expect(updated.id, testFile.id);
        expect(updated.folderId, testFile.folderId);
      });

      test('clearThumbnail removes thumbnail path', () {
        final withThumb = testFile.copyWith(
          encryptedThumbnailPath: '/vault/thumbs/test.pnk',
        );
        expect(withThumb.encryptedThumbnailPath, isNotNull);

        final cleared = withThumb.copyWith(clearThumbnail: true);
        expect(cleared.encryptedThumbnailPath, isNull);
      });

      test('clearLastViewedAt removes last viewed date', () {
        final viewed = testFile.copyWith(lastViewedAt: DateTime.now());
        expect(viewed.lastViewedAt, isNotNull);

        final cleared = viewed.copyWith(clearLastViewedAt: true);
        expect(cleared.lastViewedAt, isNull);
      });

      test('clearPlaybackPosition removes playback position', () {
        final withPosition = testFile.copyWith(
          lastPlaybackPosition: const Duration(minutes: 10),
        );
        expect(withPosition.lastPlaybackPosition, isNotNull);

        final cleared = withPosition.copyWith(clearPlaybackPosition: true);
        expect(cleared.lastPlaybackPosition, isNull);
      });
    });

    test('equality works correctly', () {
      final file1 = MediaFile(
        id: 'same-id',
        name: 'test.jpg',
        folderId: 'folder',
        type: MediaType.image,
        encryptedPath: '/path',
        fileSize: 1000,
        importedAt: testDate,
      );

      final file2 = MediaFile(
        id: 'same-id',
        name: 'test.jpg',
        folderId: 'folder',
        type: MediaType.image,
        encryptedPath: '/path',
        fileSize: 1000,
        importedAt: testDate,
      );

      final file3 = file1.copyWith(name: 'different.jpg');

      expect(file1, equals(file2));
      expect(file1, isNot(equals(file3)));
    });
  });
}
