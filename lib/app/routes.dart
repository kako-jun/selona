import 'package:flutter/material.dart';

import '../features/auth/presentation/pin_screen.dart';
import '../features/auth/presentation/passphrase_setup_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/library/presentation/import_screen.dart';
import '../features/viewer/presentation/viewer_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../shared/models/media_file.dart';

/// Application route definitions
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String passphraseSetup = '/passphrase-setup';
  static const String pin = '/pin';
  static const String library = '/library';
  static const String import = '/import';
  static const String viewer = '/viewer';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(
          const SplashScreen(),
          settings,
        );
      case passphraseSetup:
        return _buildRoute(
          const PassphraseSetupScreen(),
          settings,
        );
      case pin:
        return _buildRoute(
          const PinScreen(),
          settings,
        );
      case library:
        final folderId = settings.arguments as String?;
        return _buildRoute(
          LibraryScreen(folderId: folderId),
          settings,
        );
      case import:
        return _buildRoute(
          const ImportScreen(),
          settings,
        );
      case viewer:
        final args = settings.arguments as ViewerScreenArguments;
        return _buildRoute(
          ViewerScreen(arguments: args),
          settings,
        );
      case AppRoutes.settings:
        return _buildRoute(
          const SettingsScreen(),
          settings,
        );
      default:
        return _buildRoute(
          const NotFoundScreen(),
          settings,
        );
    }
  }

  static PageRouteBuilder<T> _buildRoute<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        final offsetAnimation = animation.drive(tween);
        final fadeAnimation = animation.drive(
          Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

/// Splash screen - determines initial route based on app state
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // TODO: Check if app is initialized (passphrase set)
    // TODO: Check if PIN is enabled
    // For now, navigate to library after a brief delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // TODO: Implement proper initialization check
    // Navigator.pushReplacementNamed(context, AppRoutes.passphraseSetup);
    Navigator.pushReplacementNamed(context, AppRoutes.library);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.nights_stay_outlined,
              size: 80,
              color: Color(0xFF7C8DB5),
            ),
            SizedBox(height: 24),
            Text(
              'Selona',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE6EDF3),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your private serenity space',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8B949E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 404 Not Found screen
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFF8B949E),
            ),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFFE6EDF3),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.library);
              },
              child: const Text('Go to Library'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Arguments for the viewer screen
class ViewerScreenArguments {
  final List<MediaFile> files;
  final int initialIndex;
  final String? folderId;

  const ViewerScreenArguments({
    required this.files,
    this.initialIndex = 0,
    this.folderId,
  });
}
