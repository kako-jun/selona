import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

import '../../../app/theme.dart';
import '../../../core/services/import_service.dart';

/// Import screen for selecting and importing folders/files
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

/// Represents a selected import source
class _ImportSelection {
  final String? folderPath;
  final List<String> filePaths;

  const _ImportSelection({this.folderPath, this.filePaths = const []});

  bool get isEmpty => folderPath == null && filePaths.isEmpty;
  bool get isFolder => folderPath != null;

  int get fileCount {
    if (folderPath != null) {
      // Count will be determined after scanning
      return -1;
    }
    return filePaths.length;
  }

  String get displayName {
    if (folderPath != null) {
      return path.basename(folderPath!);
    }
    if (filePaths.length == 1) {
      return path.basename(filePaths.first);
    }
    return '${filePaths.length} files';
  }
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final _importService = ImportService.instance;

  bool _isImporting = false;
  _ImportSelection _selection = const _ImportSelection();
  int _totalFiles = 0;
  int _importedFiles = 0;
  int _scannedFileCount = 0;
  bool _deleteAfterImport = false;

  Future<void> _selectFolder() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();

      if (result != null) {
        setState(() {
          _selection = _ImportSelection(folderPath: result);
          _scannedFileCount = 0;
        });
        // Scan for file count
        await _scanFolder(result);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting folder: $e'),
          backgroundColor: SelonaColors.error,
        ),
      );
    }
  }

  Future<void> _selectFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          // Images
          'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp',
          // Videos
          'mp4', 'webm', 'mkv', 'avi', 'mov', 'm4v',
          // Archives
          'zip',
        ],
      );

      if (result != null && result.files.isNotEmpty) {
        final paths = result.files
            .where((f) => f.path != null)
            .map((f) => f.path!)
            .toList();

        setState(() {
          _selection = _ImportSelection(filePaths: paths);
          _scannedFileCount = paths.length;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting files: $e'),
          backgroundColor: SelonaColors.error,
        ),
      );
    }
  }

  Future<void> _scanFolder(String folderPath) async {
    final dir = Directory(folderPath);
    int count = 0;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        final ext = path.extension(entity.path).toLowerCase();
        if (_importService.isSupportedExtension(ext)) {
          count++;
        }
      }
    }

    if (mounted) {
      setState(() {
        _scannedFileCount = count;
      });
    }
  }

  Future<void> _startImport() async {
    if (_selection.isEmpty) return;

    setState(() {
      _isImporting = true;
      _totalFiles = _scannedFileCount;
      _importedFiles = 0;
    });

    try {
      if (_selection.isFolder) {
        await _importService.importFolder(
          _selection.folderPath!,
          deleteAfterImport: _deleteAfterImport,
          onProgress: (imported, total) {
            if (mounted) {
              setState(() {
                _importedFiles = imported;
                _totalFiles = total;
              });
            }
          },
        );
      } else {
        await _importService.importFiles(
          _selection.filePaths,
          deleteAfterImport: _deleteAfterImport,
          onProgress: (imported, total) {
            if (mounted) {
              setState(() {
                _importedFiles = imported;
                _totalFiles = total;
              });
            }
          },
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true); // Return true to indicate import completed

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.importComplete),
          backgroundColor: SelonaColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isImporting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import error: $e'),
          backgroundColor: SelonaColors.error,
        ),
      );
    }
  }

  void _clearSelection() {
    setState(() {
      _selection = const _ImportSelection();
      _scannedFileCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.import),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isImporting ? null : () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selection buttons
            if (!_isImporting && _selection.isEmpty) ...[
              _buildSelectionButton(
                icon: Icons.insert_drive_file,
                label: l10n.selectFiles,
                subtitle: l10n.selectImagesVideosZip,
                onTap: _selectFiles,
              ),
              const SizedBox(height: 16),
              _buildSelectionButton(
                icon: Icons.folder,
                label: l10n.selectFolder,
                subtitle: l10n.importEntireFolder,
                onTap: _selectFolder,
              ),
            ],

            // Selected item display
            if (!_isImporting && !_selection.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SelonaColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SelonaColors.primaryAccent),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _selection.isFolder
                              ? Icons.folder
                              : Icons.insert_drive_file,
                          size: 40,
                          color: SelonaColors.primaryAccent,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selection.displayName,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _scannedFileCount > 0
                                    ? '$_scannedFileCount files'
                                    : 'Scanning...',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: SelonaColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _clearSelection,
                          tooltip: 'Clear selection',
                        ),
                      ],
                    ),
                    if (_selection.isFolder) ...[
                      const SizedBox(height: 8),
                      Text(
                        _selection.folderPath!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: SelonaColors.textMuted,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const Spacer(),

            // Import progress
            if (_isImporting) ...[
              LinearProgressIndicator(
                value: _totalFiles > 0 ? _importedFiles / _totalFiles : null,
              ),
              const SizedBox(height: 16),
              Text(
                _totalFiles > 0
                    ? '${l10n.importing} $_importedFiles/$_totalFiles'
                    : l10n.importing,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SelonaColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],

            // Delete after import checkbox
            if (!_isImporting &&
                !_selection.isEmpty &&
                _scannedFileCount > 0) ...[
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _deleteAfterImport,
                onChanged: (value) {
                  setState(() {
                    _deleteAfterImport = value ?? false;
                  });
                },
                title: Text(l10n.deleteOriginals),
                subtitle: Text(
                  l10n.deleteWarning,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _deleteAfterImport
                            ? SelonaColors.warning
                            : SelonaColors.textMuted,
                      ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],

            // Import button
            if (!_isImporting &&
                !_selection.isEmpty &&
                _scannedFileCount > 0) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _startImport,
                icon: const Icon(Icons.download),
                label: Text('${l10n.import} ($_scannedFileCount files)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: SelonaColors.backgroundSecondary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: SelonaColors.primaryAccent,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SelonaColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: SelonaColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
