import 'package:flutter/services.dart';

import '../models/app_settings.dart';

/// Helper class for managing screen orientation
class OrientationHelper {
  OrientationHelper._();

  /// Apply orientation lock based on settings
  static Future<void> applyOrientation(ScreenOrientation orientation) async {
    switch (orientation) {
      case ScreenOrientation.portrait:
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        break;
      case ScreenOrientation.landscape:
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        break;
      case ScreenOrientation.auto:
      default:
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        break;
    }
  }

  /// Reset to system default (all orientations allowed)
  static Future<void> resetToDefault() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
