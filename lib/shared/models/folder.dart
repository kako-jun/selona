import 'package:equatable/equatable.dart';

/// Represents a folder containing media files
class Folder extends Equatable {
  final String id;
  final String name;
  final String? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// UUIDs of files to show as preview thumbnails (max 4)
  final List<String> previewFileIds;

  /// Total file count in this folder
  final int fileCount;

  const Folder({
    required this.id,
    required this.name,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    this.previewFileIds = const [],
    this.fileCount = 0,
  });

  /// Create from database map
  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] as String,
      name: map['name'] as String,
      parentId: map['parent_id'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create a copy with updated fields
  Folder copyWith({
    String? id,
    String? name,
    String? parentId,
    bool clearParentId = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? previewFileIds,
    int? fileCount,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: clearParentId ? null : (parentId ?? this.parentId),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      previewFileIds: previewFileIds ?? this.previewFileIds,
      fileCount: fileCount ?? this.fileCount,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, parentId, createdAt, updatedAt, previewFileIds, fileCount];
}
