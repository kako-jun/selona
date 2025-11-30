import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';

/// Passphrase setup screen for first-time users
class PassphraseSetupScreen extends ConsumerStatefulWidget {
  const PassphraseSetupScreen({super.key});

  @override
  ConsumerState<PassphraseSetupScreen> createState() =>
      _PassphraseSetupScreenState();
}

class _PassphraseSetupScreenState
    extends ConsumerState<PassphraseSetupScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isValid = false;
  bool _isConfirming = false;
  String? _firstPassphrase;

  static const int _passphraseLength = 9;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isValid = _controller.text.length == _passphraseLength;
    });
  }

  void _onConfirm() {
    if (!_isValid) return;

    HapticFeedback.lightImpact();

    if (!_isConfirming) {
      // First entry - save and ask for confirmation
      setState(() {
        _firstPassphrase = _controller.text;
        _isConfirming = true;
        _controller.clear();
      });
    } else {
      // Second entry - verify match
      if (_controller.text == _firstPassphrase) {
        // TODO: Store passphrase hash securely
        Navigator.pushReplacementNamed(context, AppRoutes.library);
      } else {
        // Mismatch - reset
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pinMismatch),
            backgroundColor: SelonaColors.error,
          ),
        );
        setState(() {
          _isConfirming = false;
          _firstPassphrase = null;
          _controller.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final characterCount = _controller.text.length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),

              // Logo
              const Center(
                child: Icon(
                  Icons.nights_stay_outlined,
                  size: 64,
                  color: SelonaColors.primaryAccent,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  l10n.appName,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),

              const SizedBox(height: 48),

              // Title
              Text(
                _isConfirming ? l10n.confirmPin : l10n.passphraseSetup,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.passphraseDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SelonaColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Passphrase input
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLength: _passphraseLength,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'monospace',
                  letterSpacing: 4,
                ),
                decoration: InputDecoration(
                  hintText: l10n.passphraseHint,
                  hintStyle: TextStyle(
                    fontSize: 24,
                    fontFamily: 'monospace',
                    letterSpacing: 4,
                    color: SelonaColors.textMuted.withAlpha(128),
                  ),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9]')),
                  LengthLimitingTextInputFormatter(_passphraseLength),
                ],
                onSubmitted: (_) => _onConfirm(),
              ),

              const SizedBox(height: 8),

              // Character count
              Text(
                l10n.passphraseCharacters(characterCount),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _isValid
                          ? SelonaColors.success
                          : SelonaColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SelonaColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SelonaColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 20,
                          color: SelonaColors.info,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Passphrase format',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Looks like: revision ID, commit hash',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SelonaColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Example: "a3f7b2c1e", "8d4e9f0a1"',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                            color: SelonaColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Warning box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SelonaColors.warning.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SelonaColors.warning.withAlpha(77)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 24,
                      color: SelonaColors.warning,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.passphraseWarning,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: SelonaColors.warning,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Confirm button
              ElevatedButton(
                onPressed: _isValid ? _onConfirm : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: SelonaColors.surface,
                ),
                child: Text(l10n.confirm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
