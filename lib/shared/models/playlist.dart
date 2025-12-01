import 'package:equatable/equatable.dart';

/// Represents a playlist containing media files
class Playlist extends Equatable {
  final String id;
  final String name;
  final List<PlaylistItem> items;
  final int imageDurationSeconds;
  final bool loop;
  final bool shuffle;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Playlist({
    required this.id,
    required this.name,
    this.items = const [],
    this.imageDurationSeconds = 5,
    this.loop = false,
    this.shuffle = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Number of items in the playlist
  int get length => items.length;

  /// Whether the playlist is empty
  bool get isEmpty => items.isEmpty;

  /// Create from database map
  factory Playlist.fromMap(Map<String, dynamic> map,
      {List<PlaylistItem>? items}) {
    return Playlist(
      id: map['id'] as String,
      name: map['name'] as String,
      items: items ?? const [],
      imageDurationSeconds: map['image_duration_seconds'] as int? ?? 5,
      loop: (map['loop'] as int? ?? 0) == 1,
      shuffle: (map['shuffle'] as int? ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_duration_seconds': imageDurationSeconds,
      'loop': loop ? 1 : 0,
      'shuffle': shuffle ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create a copy with updated fields
  Playlist copyWith({
    String? id,
    String? name,
    List<PlaylistItem>? items,
    int? imageDurationSeconds,
    bool? loop,
    bool? shuffle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      imageDurationSeconds: imageDurationSeconds ?? this.imageDurationSeconds,
      loop: loop ?? this.loop,
      shuffle: shuffle ?? this.shuffle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        items,
        imageDurationSeconds,
        loop,
        shuffle,
        createdAt,
        updatedAt,
      ];
}

/// Represents an item in a playlist
class PlaylistItem extends Equatable {
  final String id;
  final String playlistId;
  final String mediaFileId;
  final int order;

  const PlaylistItem({
    required this.id,
    required this.playlistId,
    required this.mediaFileId,
    required this.order,
  });

  /// Create from database map
  factory PlaylistItem.fromMap(Map<String, dynamic> map) {
    return PlaylistItem(
      id: map['id'] as String,
      playlistId: map['playlist_id'] as String,
      mediaFileId: map['media_file_id'] as String,
      order: map['order'] as int,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playlist_id': playlistId,
      'media_file_id': mediaFileId,
      'order': order,
    };
  }

  /// Create a copy with updated fields
  PlaylistItem copyWith({
    String? id,
    String? playlistId,
    String? mediaFileId,
    int? order,
  }) {
    return PlaylistItem(
      id: id ?? this.id,
      playlistId: playlistId ?? this.playlistId,
      mediaFileId: mediaFileId ?? this.mediaFileId,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, playlistId, mediaFileId, order];
}
