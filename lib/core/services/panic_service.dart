import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

import '../../shared/models/app_settings.dart';

/// Service for handling panic mode (shake to hide)
class PanicService {
  PanicService._();
  static final instance = PanicService._();

  ShakeDetector? _shakeDetector;
  bool _isEnabled = false;
  ShakeSensitivity _sensitivity = ShakeSensitivity.normal;
  VoidCallback? _onPanicTriggered;

  /// Initialize the panic service
  void initialize({
    required bool enabled,
    required ShakeSensitivity sensitivity,
    required VoidCallback onPanicTriggered,
  }) {
    _isEnabled = enabled;
    _sensitivity = sensitivity;
    _onPanicTriggered = onPanicTriggered;

    if (_isEnabled) {
      _startListening();
    }
  }

  /// Update settings
  void updateSettings({
    required bool enabled,
    required ShakeSensitivity sensitivity,
  }) {
    final wasEnabled = _isEnabled;
    _isEnabled = enabled;
    _sensitivity = sensitivity;

    if (_isEnabled && !wasEnabled) {
      _startListening();
    } else if (!_isEnabled && wasEnabled) {
      _stopListening();
    } else if (_isEnabled) {
      // Restart with new sensitivity
      _stopListening();
      _startListening();
    }
  }

  /// Start listening for shake events
  void _startListening() {
    _stopListening(); // Ensure no duplicate listeners

    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: () {
        if (_isEnabled && _onPanicTriggered != null) {
          _onPanicTriggered!();
        }
      },
      minimumShakeCount: _getShakeCount(),
      shakeSlopTimeMS: _getShakeSlopTime(),
      shakeCountResetTime: 3000,
      shakeThresholdGravity: _getShakeThreshold(),
    );
  }

  /// Stop listening for shake events
  void _stopListening() {
    _shakeDetector?.stopListening();
    _shakeDetector = null;
  }

  /// Get shake count based on sensitivity
  int _getShakeCount() {
    switch (_sensitivity) {
      case ShakeSensitivity.gentle:
        return 1; // Single shake triggers
      case ShakeSensitivity.hard:
        return 3; // Requires more shakes
      default:
        return 2; // Normal
    }
  }

  /// Get shake slop time based on sensitivity
  int _getShakeSlopTime() {
    switch (_sensitivity) {
      case ShakeSensitivity.gentle:
        return 500; // More time between shakes
      case ShakeSensitivity.hard:
        return 300; // Less time (harder to trigger)
      default:
        return 400;
    }
  }

  /// Get shake threshold based on sensitivity
  double _getShakeThreshold() {
    switch (_sensitivity) {
      case ShakeSensitivity.gentle:
        return 1.5; // Lower threshold (easier to trigger)
      case ShakeSensitivity.hard:
        return 3.0; // Higher threshold (harder to trigger)
      default:
        return 2.0;
    }
  }

  /// Dispose the service
  void dispose() {
    _stopListening();
    _onPanicTriggered = null;
  }
}
