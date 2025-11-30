import 'dart:ui';
import 'package:equatable/equatable.dart';

/// Type of bookmark
enum BookmarkType {
  file,
  scene,
  region;

  static BookmarkType fromString(String value) {
    switch (value) {
      case 'file':
        return BookmarkType.file;
      case 'scene':
        return BookmarkType.scene;
      case 'region':
        return BookmarkType.region;
      default:
        throw ArgumentError('Unknown bookmark type: $value');
    }
  }
}

/// Represents a bookmark for a media file
class Bookmark extends Equatable {
  final String id;
  final String mediaFileId;
  final BookmarkType type;
  final Duration? timestamp;
  final Rect? region;
  final String? note;
  final DateTime createdAt;

  const Bookmark({
    required this.id,
    required this.mediaFileId,
    required this.type,
    this.timestamp,
    this.region,
    this.note,
    required this.createdAt,
  });

  /// Create from database map
  factory Bookmark.fromMap(Map<String, dynamic> map) {
    Rect? region;
    if (map['region_left'] != null) {
      region = Rect.fromLTRB(
        (map['region_left'] as num).toDouble(),
        (map['region_top'] as num).toDouble(),
        (map['region_right'] as num).toDouble(),
        (map['region_bottom'] as num).toDouble(),
      );
    }

    return Bookmark(
      id: map['id'] as String,
      mediaFileId: map['media_file_id'] as String,
      type: BookmarkType.fromString(map['type'] as String),
      timestamp: map['timestamp'] != null
          ? Duration(milliseconds: map['timestamp'] as int)
          : null,
      region: region,
      note: map['note'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'media_file_id': mediaFileId,
      'type': type.name,
      'timestamp': timestamp?.inMilliseconds,
      'region_left': region?.left,
      'region_top': region?.top,
      'region_right': region?.right,
      'region_bottom': region?.bottom,
      'note': note,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Create a copy with updated fields
  Bookmark copyWith({
    String? id,
    String? mediaFileId,
    BookmarkType? type,
    Duration? timestamp,
    bool clearTimestamp = false,
    Rect? region,
    bool clearRegion = false,
    String? note,
    bool clearNote = false,
    DateTime? createdAt,
  }) {
    return Bookmark(
      id: id ?? this.id,
      mediaFileId: mediaFileId ?? this.mediaFileId,
      type: type ?? this.type,
      timestamp: clearTimestamp ? null : (timestamp ?? this.timestamp),
      region: clearRegion ? null : (region ?? this.region),
      note: clearNote ? null : (note ?? this.note),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        mediaFileId,
        type,
        timestamp,
        region,
        note,
        createdAt,
      ];
}
