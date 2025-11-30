import 'package:equatable/equatable.dart';

/// Represents a view history entry
class ViewHistory extends Equatable {
  final String id;
  final String mediaFileId;
  final DateTime viewedAt;
  final Duration? playbackPosition;

  const ViewHistory({
    required this.id,
    required this.mediaFileId,
    required this.viewedAt,
    this.playbackPosition,
  });

  /// Create from database map
  factory ViewHistory.fromMap(Map<String, dynamic> map) {
    return ViewHistory(
      id: map['id'] as String,
      mediaFileId: map['media_file_id'] as String,
      viewedAt: DateTime.fromMillisecondsSinceEpoch(map['viewed_at'] as int),
      playbackPosition: map['playback_position'] != null
          ? Duration(milliseconds: map['playback_position'] as int)
          : null,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'media_file_id': mediaFileId,
      'viewed_at': viewedAt.millisecondsSinceEpoch,
      'playback_position': playbackPosition?.inMilliseconds,
    };
  }

  /// Create a copy with updated fields
  ViewHistory copyWith({
    String? id,
    String? mediaFileId,
    DateTime? viewedAt,
    Duration? playbackPosition,
    bool clearPlaybackPosition = false,
  }) {
    return ViewHistory(
      id: id ?? this.id,
      mediaFileId: mediaFileId ?? this.mediaFileId,
      viewedAt: viewedAt ?? this.viewedAt,
      playbackPosition: clearPlaybackPosition
          ? null
          : (playbackPosition ?? this.playbackPosition),
    );
  }

  @override
  List<Object?> get props => [id, mediaFileId, viewedAt, playbackPosition];
}
