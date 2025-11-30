import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';

import '../../../app/theme.dart';

/// Import screen for selecting and importing folders
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool _isImporting = false;
  String? _selectedPath;
  int _totalFiles = 0;
  int _importedFiles = 0;

  Future<void> _selectFolder() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();

      if (result != null) {
        setState(() {
          _selectedPath = result;
        });
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting folder: $e'),
          backgroundColor: SelonaColors.error,
        ),
      );
    }
  }

  Future<void> _startImport() async {
    if (_selectedPath == null) return;

    setState(() {
      _isImporting = true;
      _totalFiles = 10; // TODO: Scan actual files
      _importedFiles = 0;
    });

    // Simulate import progress
    for (int i = 0; i < _totalFiles; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      setState(() {
        _importedFiles = i + 1;
      });
    }

    if (!mounted) return;

    // Show completion dialog
    final deleteOriginals = await _showDeleteOriginalsDialog();

    if (deleteOriginals == true) {
      // TODO: Delete original files
    }

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.importComplete),
        backgroundColor: SelonaColors.success,
      ),
    );
  }

  Future<bool?> _showDeleteOriginalsDialog() {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteOriginals),
        content: Text(l10n.deleteWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
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
            // Selected folder display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SelonaColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SelonaColors.border),
              ),
              child: Column(
                children: [
                  Icon(
                    _selectedPath != null
                        ? Icons.folder
                        : Icons.folder_open_outlined,
                    size: 64,
                    color: _selectedPath != null
                        ? SelonaColors.primaryAccent
                        : SelonaColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedPath ?? l10n.selectFolder,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _selectedPath != null
                              ? SelonaColors.textPrimary
                              : SelonaColors.textMuted,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Select folder button
            if (!_isImporting)
              OutlinedButton.icon(
                onPressed: _selectFolder,
                icon: const Icon(Icons.folder_open),
                label: Text(l10n.selectFolder),
              ),

            const Spacer(),

            // Import progress
            if (_isImporting) ...[
              LinearProgressIndicator(
                value: _totalFiles > 0 ? _importedFiles / _totalFiles : 0,
              ),
              const SizedBox(height: 16),
              Text(
                '${l10n.importing} $_importedFiles/$_totalFiles',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SelonaColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],

            // Import button
            if (!_isImporting && _selectedPath != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _startImport,
                icon: const Icon(Icons.download),
                label: Text(l10n.import),
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
}
