import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../shared/models/media_file.dart';
import 'database_manager.dart';

/// Sort options for media files
enum MediaSortBy {
  name,
  importedAt,
  lastViewedAt,
  fileSize,
  rating,
  viewCount,
}

/// Filter options for media files
class MediaFilter {
  final bool? isBookmarked;
  final bool? isUnviewed;
  final MediaType? type;
  final int? minRating;

  const MediaFilter({
    this.isBookmarked,
    this.isUnviewed,
    this.type,
    this.minRating,
  });

  static const none = MediaFilter();
}

/// Repository for media file operations
class MediaFileRepository {
  MediaFileRepository._();
  static final instance = MediaFileRepository._();

  final _db = DatabaseManager.instance;
  final _uuid = const Uuid();

  /// Create a new media file entry
  Future<MediaFile> create({
    required String originalName,
    required String? folderId,
    required MediaType type,
    required int fileSize,
  }) async {
    final id = _uuid.v4();
    final extension = path.extension(originalName);
    final now = DateTime.now();

    final file = MediaFile(
      id: id,
      name: originalName,
      folderId: folderId ?? '', // Root level
      type: type,
      encryptedPath: id, // UUID is used as the filename
      fileSize: fileSize,
      importedAt: now,
    );

    await _db.database.insert('media_files', {
      ...file.toMap(),
      'original_extension': extension,
    });

    return file;
  }

  /// Get a media file by ID
  Future<MediaFile?> getById(String id) async {
    final results = await _db.database.query(
      'media_files',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return _mapToMediaFile(results.first);
  }

  /// Get all media files in a folder
  Future<List<MediaFile>> getByFolder(
    String? folderId, {
    MediaSortBy sortBy = MediaSortBy.name,
    bool descending = false,
    MediaFilter filter = MediaFilter.none,
  }) async {
    final whereClause = StringBuffer();
    final whereArgs = <dynamic>[];

    if (folderId == null || folderId.isEmpty) {
      whereClause.write('(folder_id IS NULL OR folder_id = "")');
    } else {
      whereClause.write('folder_id = ?');
      whereArgs.add(folderId);
    }

    _applyFilter(whereClause, whereArgs, filter);

    final orderBy = _buildOrderBy(sortBy, descending);

    final results = await _db.database.query(
      'media_files',
      where: whereClause.toString(),
      whereArgs: whereArgs,
      orderBy: orderBy,
    );

    return results.map(_mapToMediaFile).toList();
  }

  /// Get all media files (across all folders)
  Future<List<MediaFile>> getAll({
    MediaSortBy sortBy = MediaSortBy.name,
    bool descending = false,
    MediaFilter filter = MediaFilter.none,
  }) async {
    final whereClause = StringBuffer();
    final whereArgs = <dynamic>[];

    _applyFilter(whereClause, whereArgs, filter);

    final orderBy = _buildOrderBy(sortBy, descending);

    final results = await _db.database.query(
      'media_files',
      where: whereClause.isEmpty ? null : whereClause.toString(),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: orderBy,
    );

    return results.map(_mapToMediaFile).toList();
  }

  /// Get recently viewed files
  Future<List<MediaFile>> getRecentlyViewed({int limit = 50}) async {
    final results = await _db.database.query(
      'media_files',
      where: 'last_viewed_at IS NOT NULL',
      orderBy: 'last_viewed_at DESC',
      limit: limit,
    );

    return results.map(_mapToMediaFile).toList();
  }

  /// Get bookmarked files
  Future<List<MediaFile>> getBookmarked() async {
    final results = await _db.database.query(
      'media_files',
      where: 'is_bookmarked = 1',
      orderBy: 'name ASC',
    );

    return results.map(_mapToMediaFile).toList();
  }

  /// Update a media file
  Future<MediaFile> update(MediaFile file) async {
    final extension = await _getOriginalExtension(file.id);

    await _db.database.update(
      'media_files',
      {
        ...file.toMap(),
        'original_extension': extension,
      },
      where: 'id = ?',
      whereArgs: [file.id],
    );

    return file;
  }

  /// Rename a media file
  Future<MediaFile> rename(String id, String newName) async {
    final file = await getById(id);
    if (file == null) {
      throw Exception('Media file not found: $id');
    }

    return update(file.copyWith(name: newName));
  }

  /// Move a media file to a new folder
  Future<MediaFile> move(String id, String? newFolderId) async {
    final file = await getById(id);
    if (file == null) {
      throw Exception('Media file not found: $id');
    }

    return update(file.copyWith(folderId: newFolderId ?? ''));
  }

  /// Update view information
  Future<MediaFile> markViewed(String id) async {
    final file = await getById(id);
    if (file == null) {
      throw Exception('Media file not found: $id');
    }

    return update(file.copyWith(
      lastViewedAt: DateTime.now(),
      viewCount: file.viewCount + 1,
    ));
  }

  /// Update playback position (for videos)
  Future<MediaFile> updatePlaybackPosition(String id, Duration position) async {
    final file = await getById(id);
    if (file == null) {
      throw Exception('Media file not found: $id');
    }

    return update(file.copyWith(lastPlaybackPosition: position));
  }

  /// Update rotation
  Future<MediaFile> updateRotation(String id, Rotation rotation) async {
    final file = await getById(id);
    if (file == null) {
      throw Exception('Media file not found: $id');
    }

    return update(file.copyWith(rotation: rotation));
  }

  /// Update rating
  Future<MediaFile> updateRating(String id, int rating) async {
    if (rating < 0 || rating > 5) {
      throw ArgumentError('Rating must be between 0 and 5');
    }

    final file = await getById(id);
    if (file == null) {
      throw Exception('Media file not found: $id');
    }

    return update(file.copyWith(rating: rating));
  }

  /// Toggle bookmark
  Future<MediaFile> toggleBookmark(String id) async {
    final file = await getById(id);
    if (file == null) {
      throw Exception('Media file not found: $id');
    }

    return update(file.copyWith(isBookmarked: !file.isBookmarked));
  }

  /// Delete a media file entry (does not delete the actual .pnk file)
  Future<void> delete(String id) async {
    await _db.database.delete(
      'media_files',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get the original extension for a file
  Future<String> _getOriginalExtension(String id) async {
    final results = await _db.database.query(
      'media_files',
      columns: ['original_extension'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return '';
    return results.first['original_extension'] as String? ?? '';
  }

  /// Get original extension (public)
  Future<String> getOriginalExtension(String id) async {
    return _getOriginalExtension(id);
  }

  /// Get file count in folder
  Future<int> getCountInFolder(String? folderId) async {
    final result = await _db.database.rawQuery(
      folderId == null || folderId.isEmpty
          ? 'SELECT COUNT(*) as count FROM media_files WHERE folder_id IS NULL OR folder_id = ""'
          : 'SELECT COUNT(*) as count FROM media_files WHERE folder_id = ?',
      folderId == null || folderId.isEmpty ? [] : [folderId],
    );

    return result.first['count'] as int? ?? 0;
  }

  /// Get total file count
  Future<int> getTotalCount() async {
    final result = await _db.database.rawQuery(
      'SELECT COUNT(*) as count FROM media_files',
    );

    return result.first['count'] as int? ?? 0;
  }

  MediaFile _mapToMediaFile(Map<String, dynamic> map) {
    return MediaFile.fromMap(map);
  }

  void _applyFilter(StringBuffer where, List<dynamic> args, MediaFilter filter) {
    if (filter.isBookmarked == true) {
      if (where.isNotEmpty) where.write(' AND ');
      where.write('is_bookmarked = 1');
    }

    if (filter.isUnviewed == true) {
      if (where.isNotEmpty) where.write(' AND ');
      where.write('last_viewed_at IS NULL');
    }

    if (filter.type != null) {
      if (where.isNotEmpty) where.write(' AND ');
      where.write('media_type = ?');
      args.add(filter.type!.name);
    }

    if (filter.minRating != null && filter.minRating! > 0) {
      if (where.isNotEmpty) where.write(' AND ');
      where.write('rating >= ?');
      args.add(filter.minRating);
    }
  }

  String _buildOrderBy(MediaSortBy sortBy, bool descending) {
    final direction = descending ? 'DESC' : 'ASC';
    switch (sortBy) {
      case MediaSortBy.name:
        return 'name $direction';
      case MediaSortBy.importedAt:
        return 'imported_at $direction';
      case MediaSortBy.lastViewedAt:
        return 'last_viewed_at $direction NULLS LAST';
      case MediaSortBy.fileSize:
        return 'file_size $direction';
      case MediaSortBy.rating:
        return 'rating $direction';
      case MediaSortBy.viewCount:
        return 'view_count $direction';
    }
  }
}
