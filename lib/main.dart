import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'app/app.dart';
import 'core/ffi/frb_generated.dart';
import 'core/constants/storage_paths.dart';
import 'core/database/database_manager.dart';
import 'core/services/crypto_service.dart';
import 'shared/utils/orientation_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for desktop platforms (Linux, Windows, macOS)
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize Rust library for pink072 encryption
  await RustLib.init();

  // Initialize storage paths
  await StoragePaths.initialize();

  // Set development passphrase (9 characters)
  // TODO: Replace with proper passphrase setup flow
  CryptoService.instance.setPassphrase('dev123456');

  // Initialize database
  await DatabaseManager.instance.initialize();

  // Set default orientation (all directions allowed)
  // TODO: Load saved orientation setting from database and apply here
  // Example: final settings = await SettingsRepository.load();
  //          await OrientationHelper.applyOrientation(settings.orientationLock);
  await OrientationHelper.resetToDefault();

  // Enable wake lock to prevent screen sleep (skip on Linux desktop if not supported)
  try {
    if (!Platform.isLinux) {
      await WakelockPlus.enable();
    }
  } catch (e) {
    // Ignore wakelock errors on platforms where it's not supported
    debugPrint('Wakelock not available: $e');
  }

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D1117),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: SelonaApp(),
    ),
  );
}
