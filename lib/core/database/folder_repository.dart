import 'package:uuid/uuid.dart';

import '../../shared/models/folder.dart';
import 'database_manager.dart';

/// Repository for folder operations
class FolderRepository {
  FolderRepository._();
  static final instance = FolderRepository._();

  final _db = DatabaseManager.instance;
  final _uuid = const Uuid();

  /// Create a new folder
  Future<Folder> create({
    required String name,
    String? parentId,
  }) async {
    final now = DateTime.now();
    final folder = Folder(
      id: _uuid.v4(),
      name: name,
      parentId: parentId,
      createdAt: now,
      updatedAt: now,
    );

    await _db.database.insert('folders', folder.toMap());
    return folder;
  }

  /// Get a folder by ID
  Future<Folder?> getById(String id) async {
    final results = await _db.database.query(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return Folder.fromMap(results.first);
  }

  /// Get all root folders (no parent)
  Future<List<Folder>> getRootFolders() async {
    final results = await _db.database.query(
      'folders',
      where: 'parent_id IS NULL',
      orderBy: 'name ASC',
    );

    return results.map((map) => Folder.fromMap(map)).toList();
  }

  /// Get child folders of a parent
  Future<List<Folder>> getChildFolders(String parentId) async {
    final results = await _db.database.query(
      'folders',
      where: 'parent_id = ?',
      whereArgs: [parentId],
      orderBy: 'name ASC',
    );

    return results.map((map) => Folder.fromMap(map)).toList();
  }

  /// Get all folders
  Future<List<Folder>> getAll() async {
    final results = await _db.database.query(
      'folders',
      orderBy: 'name ASC',
    );

    return results.map((map) => Folder.fromMap(map)).toList();
  }

  /// Update a folder
  Future<Folder> update(Folder folder) async {
    final updated = folder.copyWith(updatedAt: DateTime.now());

    await _db.database.update(
      'folders',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [folder.id],
    );

    return updated;
  }

  /// Rename a folder
  Future<Folder> rename(String id, String newName) async {
    final folder = await getById(id);
    if (folder == null) {
      throw Exception('Folder not found: $id');
    }

    return update(folder.copyWith(name: newName));
  }

  /// Move a folder to a new parent
  Future<Folder> move(String id, String? newParentId) async {
    final folder = await getById(id);
    if (folder == null) {
      throw Exception('Folder not found: $id');
    }

    // Prevent moving to self or descendant
    if (newParentId != null) {
      if (newParentId == id) {
        throw Exception('Cannot move folder into itself');
      }
      if (await _isDescendant(newParentId, id)) {
        throw Exception('Cannot move folder into its descendant');
      }
    }

    return update(folder.copyWith(
      parentId: newParentId,
      clearParentId: newParentId == null,
    ));
  }

  /// Check if potentialDescendant is a descendant of ancestorId
  Future<bool> _isDescendant(
      String potentialDescendant, String ancestorId) async {
    var current = await getById(potentialDescendant);
    while (current != null && current.parentId != null) {
      if (current.parentId == ancestorId) return true;
      current = await getById(current.parentId!);
    }
    return false;
  }

  /// Delete a folder (cascades to subfolders and moves files to root)
  Future<void> delete(String id) async {
    await _db.database.delete(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get the folder path (for display)
  Future<List<Folder>> getPath(String folderId) async {
    final path = <Folder>[];
    var current = await getById(folderId);

    while (current != null) {
      path.insert(0, current);
      if (current.parentId == null) break;
      current = await getById(current.parentId!);
    }

    return path;
  }

  /// Create folder structure from path (e.g., "Photos/2024/vacation")
  /// Returns the leaf folder
  Future<Folder> createPath(String pathString) async {
    final parts = pathString.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) {
      throw ArgumentError('Path cannot be empty');
    }

    String? parentId;
    Folder? folder;

    for (final name in parts) {
      // Check if folder already exists at this level
      final existing = await _findByNameAndParent(name, parentId);
      if (existing != null) {
        folder = existing;
        parentId = existing.id;
      } else {
        folder = await create(name: name, parentId: parentId);
        parentId = folder.id;
      }
    }

    return folder!;
  }

  /// Find folder by name and parent
  Future<Folder?> _findByNameAndParent(String name, String? parentId) async {
    final results = await _db.database.query(
      'folders',
      where: parentId == null
          ? 'name = ? AND parent_id IS NULL'
          : 'name = ? AND parent_id = ?',
      whereArgs: parentId == null ? [name] : [name, parentId],
    );

    if (results.isEmpty) return null;
    return Folder.fromMap(results.first);
  }
}
