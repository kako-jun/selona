import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../app/theme.dart';

/// Shows an error dialog
Future<void> showErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  return showDialog(
    context: context,
    builder: (context) => ErrorDialog(
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    ),
  );
}

/// Error dialog widget
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.error_outline,
        color: SelonaColors.error,
        size: 48,
      ),
      title: Text(title),
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SelonaColors.textSecondary,
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
        if (actionLabel != null && onAction != null)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onAction!();
            },
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

/// Shows a confirmation dialog
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
  bool isDestructive = false,
}) async {
  final l10n = AppLocalizations.of(context)!;

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: isDestructive
          ? const Icon(
              Icons.warning_amber_rounded,
              color: SelonaColors.warning,
              size: 48,
            )
          : null,
      title: Text(title),
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SelonaColors.textSecondary,
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel ?? l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: isDestructive
              ? ElevatedButton.styleFrom(
                  backgroundColor: SelonaColors.error,
                )
              : null,
          child: Text(confirmLabel ?? l10n.confirm),
        ),
      ],
    ),
  );

  return result ?? false;
}
