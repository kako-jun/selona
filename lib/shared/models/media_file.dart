import 'package:equatable/equatable.dart';

/// Type of media file
enum MediaType {
  image,
  video;

  static MediaType fromString(String value) {
    switch (value) {
      case 'image':
        return MediaType.image;
      case 'video':
        return MediaType.video;
      default:
        throw ArgumentError('Unknown media type: $value');
    }
  }
}

/// Rotation angle for media files (persisted per file)
enum Rotation {
  none(0),
  cw90(90),
  cw180(180),
  cw270(270);

  final int degrees;
  const Rotation(this.degrees);

  static Rotation fromDegrees(int degrees) {
    switch (degrees % 360) {
      case 0:
        return Rotation.none;
      case 90:
        return Rotation.cw90;
      case 180:
        return Rotation.cw180;
      case 270:
        return Rotation.cw270;
      default:
        return Rotation.none;
    }
  }

  Rotation rotateClockwise() {
    switch (this) {
      case Rotation.none:
        return Rotation.cw90;
      case Rotation.cw90:
        return Rotation.cw180;
      case Rotation.cw180:
        return Rotation.cw270;
      case Rotation.cw270:
        return Rotation.none;
    }
  }
}

/// Represents a media file (image or video) stored in the app
class MediaFile extends Equatable {
  final String id;
  final String name;
  final String folderId;
  final MediaType type;
  final String encryptedPath;
  final String? encryptedThumbnailPath;
  final int fileSize;
  final DateTime importedAt;
  final DateTime? lastViewedAt;
  final Duration? lastPlaybackPosition;
  final Rotation rotation;
  final int rating;
  final bool isBookmarked;
  final int viewCount;

  const MediaFile({
    required this.id,
    required this.name,
    required this.folderId,
    required this.type,
    required this.encryptedPath,
    this.encryptedThumbnailPath,
    required this.fileSize,
    required this.importedAt,
    this.lastViewedAt,
    this.lastPlaybackPosition,
    this.rotation = Rotation.none,
    this.rating = 0,
    this.isBookmarked = false,
    this.viewCount = 0,
  });

  /// Whether this is a video file
  bool get isVideo => type == MediaType.video;

  /// Whether this is an image file
  bool get isImage => type == MediaType.image;

  /// Whether this file has never been viewed
  bool get isUnviewed => lastViewedAt == null;

  /// Whether this file has a rating
  bool get isRated => rating > 0;

  /// Create from database map
  factory MediaFile.fromMap(Map<String, dynamic> map) {
    return MediaFile(
      id: map['id'] as String,
      name: map['name'] as String,
      folderId: map['folder_id'] as String,
      type: MediaType.fromString(map['media_type'] as String),
      encryptedPath: map['encrypted_path'] as String,
      encryptedThumbnailPath: map['encrypted_thumbnail_path'] as String?,
      fileSize: map['file_size'] as int,
      importedAt:
          DateTime.fromMillisecondsSinceEpoch(map['imported_at'] as int),
      lastViewedAt: map['last_viewed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_viewed_at'] as int)
          : null,
      lastPlaybackPosition: map['last_playback_position'] != null
          ? Duration(milliseconds: map['last_playback_position'] as int)
          : null,
      rotation: Rotation.fromDegrees(map['rotation'] as int? ?? 0),
      rating: map['rating'] as int? ?? 0,
      isBookmarked: (map['is_bookmarked'] as int? ?? 0) == 1,
      viewCount: map['view_count'] as int? ?? 0,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'folder_id': folderId,
      'media_type': type.name,
      'encrypted_path': encryptedPath,
      'encrypted_thumbnail_path': encryptedThumbnailPath,
      'file_size': fileSize,
      'imported_at': importedAt.millisecondsSinceEpoch,
      'last_viewed_at': lastViewedAt?.millisecondsSinceEpoch,
      'last_playback_position': lastPlaybackPosition?.inMilliseconds,
      'rotation': rotation.degrees,
      'rating': rating,
      'is_bookmarked': isBookmarked ? 1 : 0,
      'view_count': viewCount,
    };
  }

  /// Create a copy with updated fields
  MediaFile copyWith({
    String? id,
    String? name,
    String? folderId,
    MediaType? type,
    String? encryptedPath,
    String? encryptedThumbnailPath,
    bool clearThumbnail = false,
    int? fileSize,
    DateTime? importedAt,
    DateTime? lastViewedAt,
    bool clearLastViewedAt = false,
    Duration? lastPlaybackPosition,
    bool clearPlaybackPosition = false,
    Rotation? rotation,
    int? rating,
    bool? isBookmarked,
    int? viewCount,
  }) {
    return MediaFile(
      id: id ?? this.id,
      name: name ?? this.name,
      folderId: folderId ?? this.folderId,
      type: type ?? this.type,
      encryptedPath: encryptedPath ?? this.encryptedPath,
      encryptedThumbnailPath: clearThumbnail
          ? null
          : (encryptedThumbnailPath ?? this.encryptedThumbnailPath),
      fileSize: fileSize ?? this.fileSize,
      importedAt: importedAt ?? this.importedAt,
      lastViewedAt:
          clearLastViewedAt ? null : (lastViewedAt ?? this.lastViewedAt),
      lastPlaybackPosition: clearPlaybackPosition
          ? null
          : (lastPlaybackPosition ?? this.lastPlaybackPosition),
      rotation: rotation ?? this.rotation,
      rating: rating ?? this.rating,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        folderId,
        type,
        encryptedPath,
        encryptedThumbnailPath,
        fileSize,
        importedAt,
        lastViewedAt,
        lastPlaybackPosition,
        rotation,
        rating,
        isBookmarked,
        viewCount,
      ];
}
