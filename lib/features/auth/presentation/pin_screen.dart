import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import 'widgets/pin_pad.dart';

/// PIN lock screen for app authentication
class PinScreen extends ConsumerStatefulWidget {
  final bool isSetup;

  const PinScreen({
    super.key,
    this.isSetup = false,
  });

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  final List<String> _pin = [];
  final List<String> _confirmPin = [];
  bool _isConfirming = false;
  bool _hasError = false;
  String? _errorMessage;

  static const int _pinLength = 6;

  void _onDigitPressed(String digit) {
    HapticFeedback.lightImpact();

    setState(() {
      _hasError = false;
      _errorMessage = null;

      if (widget.isSetup) {
        if (_isConfirming) {
          if (_confirmPin.length < _pinLength) {
            _confirmPin.add(digit);
            if (_confirmPin.length == _pinLength) {
              _validateSetup();
            }
          }
        } else {
          if (_pin.length < _pinLength) {
            _pin.add(digit);
            if (_pin.length == _pinLength) {
              _isConfirming = true;
            }
          }
        }
      } else {
        if (_pin.length < _pinLength) {
          _pin.add(digit);
          if (_pin.length == _pinLength) {
            _validatePin();
          }
        }
      }
    });
  }

  void _onDeletePressed() {
    HapticFeedback.lightImpact();

    setState(() {
      if (widget.isSetup && _isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin.removeLast();
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin.removeLast();
        }
      }
      _hasError = false;
      _errorMessage = null;
    });
  }

  void _validatePin() {
    // TODO: Validate against stored PIN hash
    final enteredPin = _pin.join();

    // Temporary: accept any 6-digit PIN
    if (enteredPin.length == _pinLength) {
      Navigator.pushReplacementNamed(context, AppRoutes.library);
    } else {
      _showError(AppLocalizations.of(context)!.incorrectPin);
    }
  }

  void _validateSetup() {
    final pin = _pin.join();
    final confirmPin = _confirmPin.join();

    if (pin == confirmPin) {
      // TODO: Store PIN hash securely
      Navigator.pushReplacementNamed(context, AppRoutes.library);
    } else {
      _showError(AppLocalizations.of(context)!.pinMismatch);
      _confirmPin.clear();
    }
  }

  void _showError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentPin = widget.isSetup && _isConfirming ? _confirmPin : _pin;

    String title;
    if (widget.isSetup) {
      title = _isConfirming ? l10n.confirmPin : l10n.pinSetup;
    } else {
      title = l10n.enterPin;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo
              const Icon(
                Icons.nights_stay_outlined,
                size: 64,
                color: SelonaColors.primaryAccent,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.appName,
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 48),

              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: SelonaColors.textSecondary,
                    ),
              ),

              const SizedBox(height: 24),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pinLength,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < currentPin.length
                          ? _hasError
                              ? SelonaColors.error
                              : SelonaColors.primaryAccent
                          : SelonaColors.surface,
                      border: Border.all(
                        color: _hasError
                            ? SelonaColors.error
                            : SelonaColors.border,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),

              // Error message
              const SizedBox(height: 16),
              SizedBox(
                height: 20,
                child: _errorMessage != null
                    ? Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: SelonaColors.error,
                            ),
                      )
                    : null,
              ),

              const Spacer(flex: 1),

              // PIN pad
              PinPad(
                onDigitPressed: _onDigitPressed,
                onDeletePressed: _onDeletePressed,
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
