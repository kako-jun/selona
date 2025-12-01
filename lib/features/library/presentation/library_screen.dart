import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/database/folder_repository.dart';
import '../../../core/database/media_file_repository.dart';
import '../../../shared/models/folder.dart';
import '../../../shared/models/media_file.dart';
import 'widgets/folder_grid.dart';
import 'widgets/media_grid.dart';
import 'widgets/sort_filter_sheet.dart';

/// Library screen - main browsing interface
class LibraryScreen extends ConsumerStatefulWidget {
  final String? folderId;
  final String? folderName;

  const LibraryScreen({
    super.key,
    this.folderId,
    this.folderName,
  });

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _folderRepo = FolderRepository.instance;
  final _fileRepo = MediaFileRepository.instance;

  SortOption _sortOption = SortOption.name;
  bool _sortAscending = true;
  FilterOption? _filterOption;

  List<Folder> _folders = [];
  List<MediaFile> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load folders
      if (widget.folderId == null) {
        // Root level - show all root folders
        final folders = await _folderRepo.getRootFolders();

        // Enrich folders with file count and preview IDs
        final enrichedFolders = <Folder>[];
        for (final folder in folders) {
          final fileCount = await _fileRepo.getCountInFolder(folder.id);
          final files = await _fileRepo.getByFolder(folder.id);
          final previewIds = files.take(4).map((f) => f.id).toList();

          enrichedFolders.add(folder.copyWith(
            fileCount: fileCount,
            previewFileIds: previewIds,
          ));
        }
        _folders = enrichedFolders;
      } else {
        // Inside a folder - show child folders
        final folders = await _folderRepo.getChildFolders(widget.folderId!);

        final enrichedFolders = <Folder>[];
        for (final folder in folders) {
          final fileCount = await _fileRepo.getCountInFolder(folder.id);
          final files = await _fileRepo.getByFolder(folder.id);
          final previewIds = files.take(4).map((f) => f.id).toList();

          enrichedFolders.add(folder.copyWith(
            fileCount: fileCount,
            previewFileIds: previewIds,
          ));
        }
        _folders = enrichedFolders;
      }

      // Load files in current folder
      _files = await _fileRepo.getByFolder(widget.folderId);
    } catch (e) {
      debugPrint('Failed to load library data: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onFolderTap(Folder folder) {
    Navigator.pushNamed(
      context,
      AppRoutes.library,
      arguments: LibraryScreenArguments(
        folderId: folder.id,
        folderName: folder.name,
      ),
    );
  }

  void _onFileTap(MediaFile file) {
    final args = ViewerScreenArguments(
      files: _files,
      initialIndex: _files.indexOf(file),
      folderId: widget.folderId,
    );
    Navigator.pushNamed(
      context,
      AppRoutes.viewer,
      arguments: args,
    );
  }

  void _showSortFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SortFilterSheet(
        currentSort: _sortOption,
        sortAscending: _sortAscending,
        currentFilter: _filterOption,
        onSortChanged: (option, ascending) {
          setState(() {
            _sortOption = option;
            _sortAscending = ascending;
          });
          Navigator.pop(context);
        },
        onFilterChanged: (option) {
          setState(() {
            _filterOption = option;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.folderId != null ? _getCurrentFolderName() : l10n.library),
        leading: widget.folderId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortFilterSheet,
            tooltip: l10n.sortBy,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, AppRoutes.import);
              // Reload data if import completed
              if (result == true) {
                _loadData();
              }
            },
            tooltip: l10n.import,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
            tooltip: l10n.settings,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _buildContent(l10n),
    );
  }

  String _getCurrentFolderName() {
    return widget.folderName ?? 'Folder';
  }

  Widget _buildContent(AppLocalizations l10n) {
    if (_folders.isEmpty && _files.isEmpty) {
      return _buildEmptyState(l10n);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          // Folders section
          if (_folders.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      l10n.folders,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_folders.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SelonaColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: FolderGrid(
                folders: _folders,
                onFolderTap: _onFolderTap,
              ),
            ),
          ],

          // Files section
          if (_files.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    Text(
                      l10n.files,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_files.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SelonaColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              sliver: MediaGrid(
                files: _files,
                onFileTap: _onFileTap,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 80,
            color: SelonaColors.textMuted.withAlpha(128),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.emptyLibrary,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: SelonaColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.importToStart,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SelonaColors.textMuted,
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.import);
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.import),
          ),
        ],
      ),
    );
  }
}
