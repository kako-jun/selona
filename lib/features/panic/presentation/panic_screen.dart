import 'package:flutter/material.dart';

import '../../../shared/models/app_settings.dart';
import 'fake_calculator_screen.dart';
import 'fake_notes_screen.dart';
import 'fake_weather_screen.dart';

/// Routes to the appropriate fake screen based on settings
class PanicScreen extends StatelessWidget {
  final FakeScreenType screenType;
  final VoidCallback onExit;

  const PanicScreen({
    super.key,
    required this.screenType,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    switch (screenType) {
      case FakeScreenType.notes:
        return FakeNotesScreen(onExit: onExit);
      case FakeScreenType.weather:
        return FakeWeatherScreen(onExit: onExit);
      case FakeScreenType.calculator:
      default:
        return FakeCalculatorScreen(onExit: onExit);
    }
  }
}
