import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../app/theme.dart';
import '../../../shared/models/app_settings.dart';
import '../../../shared/utils/orientation_helper.dart';

/// Settings screen
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Demo settings state - will be replaced with actual provider
  AppSettings _settings = const AppSettings();

  void _updateSettings(AppSettings newSettings) {
    // Apply orientation if changed
    if (newSettings.orientationLock != _settings.orientationLock) {
      OrientationHelper.applyOrientation(newSettings.orientationLock);
    }

    setState(() {
      _settings = newSettings;
    });
    // TODO: Save to database
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // Security section
          _SectionHeader(title: l10n.settingsSecurity),
          SwitchListTile(
            title: Text(l10n.settingsPinLock),
            value: _settings.pinEnabled,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(pinEnabled: value));
            },
          ),
          if (_settings.pinEnabled)
            ListTile(
              title: Text(l10n.settingsChangePin),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to PIN change screen
              },
            ),

          const Divider(),

          // Appearance section
          _SectionHeader(title: l10n.settingsAppearance),
          ListTile(
            title: Text(l10n.settingsAppIcon),
            subtitle: Text(_getAppIconName(_settings.appIcon)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showAppIconPicker();
            },
          ),

          const Divider(),

          // Controls section
          _SectionHeader(title: l10n.settingsControls),
          ListTile(
            title: Text(l10n.settingsHandedness),
            subtitle: Text(_settings.handedness == Handedness.left
                ? l10n.settingsHandednessLeft
                : l10n.settingsHandednessRight),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showHandednessPicker();
            },
          ),
          ListTile(
            title: Text(l10n.settingsOrientation),
            subtitle: Text(_getOrientationName(l10n)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showOrientationPicker();
            },
          ),

          const Divider(),

          // General section
          _SectionHeader(title: l10n.settingsGeneral),
          ListTile(
            title: Text(l10n.settingsLanguage),
            subtitle: Text(_settings.locale == 'ja' ? '日本語' : 'English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showLanguagePicker();
            },
          ),
          ListTile(
            title: Text(l10n.settingsDefaultViewMode),
            subtitle: Text(_getViewModeName(l10n)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showViewModePicker();
            },
          ),
          SwitchListTile(
            title: Text(l10n.settingsStartVideosMuted),
            value: _settings.startVideosMuted,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(startVideosMuted: value));
            },
          ),

          const Divider(),

          // Panic mode section
          _SectionHeader(title: l10n.settingsPanicMode),
          SwitchListTile(
            title: Text(l10n.settingsPanicModeEnabled),
            value: _settings.panicModeEnabled,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(panicModeEnabled: value));
            },
          ),
          if (_settings.panicModeEnabled) ...[
            ListTile(
              title: Text(l10n.settingsShakeSensitivity),
              subtitle: Text(_getShakeSensitivityName(l10n)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showShakeSensitivityPicker();
              },
            ),
            ListTile(
              title: Text(l10n.settingsFakeScreen),
              subtitle: Text(_getFakeScreenName(l10n)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showFakeScreenPicker();
              },
            ),
          ],

          const Divider(),

          // About section
          _SectionHeader(title: l10n.settingsAbout),
          ListTile(
            title: Text(l10n.settingsVersion),
            trailing: const Text(
              '1.0.0',
              style: TextStyle(color: SelonaColors.textSecondary),
            ),
          ),
          ListTile(
            title: Text(l10n.settingsLicenses),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: l10n.appName,
                applicationVersion: '1.0.0',
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getAppIconName(String icon) {
    switch (icon) {
      case 'calculator':
        return 'Calculator';
      case 'notes':
        return 'Notes';
      case 'weather':
        return 'Weather';
      default:
        return 'Default';
    }
  }

  String _getOrientationName(AppLocalizations l10n) {
    switch (_settings.orientationLock) {
      case ScreenOrientation.portrait:
        return l10n.settingsOrientationPortrait;
      case ScreenOrientation.landscape:
        return l10n.settingsOrientationLandscape;
      default:
        return l10n.settingsOrientationAuto;
    }
  }

  String _getViewModeName(AppLocalizations l10n) {
    switch (_settings.defaultViewMode) {
      case ImageViewMode.vertical:
        return l10n.viewModeVertical;
      case ImageViewMode.single:
        return l10n.viewModeSingle;
      default:
        return l10n.viewModeHorizontal;
    }
  }

  String _getShakeSensitivityName(AppLocalizations l10n) {
    switch (_settings.shakeSensitivity) {
      case ShakeSensitivity.gentle:
        return 'Gentle';
      case ShakeSensitivity.hard:
        return 'Hard';
      default:
        return 'Normal';
    }
  }

  String _getFakeScreenName(AppLocalizations l10n) {
    switch (_settings.fakeScreen) {
      case FakeScreenType.notes:
        return l10n.settingsFakeScreenNotes;
      case FakeScreenType.weather:
        return l10n.settingsFakeScreenWeather;
      default:
        return l10n.settingsFakeScreenCalculator;
    }
  }

  void _showAppIconPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _PickerSheet(
        title: AppLocalizations.of(context)!.settingsAppIcon,
        options: [
          _PickerOption(
            value: 'default',
            label: 'Default',
            isSelected: _settings.appIcon == 'default',
          ),
          _PickerOption(
            value: 'calculator',
            label: 'Calculator',
            isSelected: _settings.appIcon == 'calculator',
          ),
          _PickerOption(
            value: 'notes',
            label: 'Notes',
            isSelected: _settings.appIcon == 'notes',
          ),
          _PickerOption(
            value: 'weather',
            label: 'Weather',
            isSelected: _settings.appIcon == 'weather',
          ),
        ],
        onSelected: (value) {
          _updateSettings(_settings.copyWith(appIcon: value));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showHandednessPicker() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => _PickerSheet(
        title: l10n.settingsHandedness,
        options: [
          _PickerOption(
            value: 'right',
            label: l10n.settingsHandednessRight,
            isSelected: _settings.handedness == Handedness.right,
          ),
          _PickerOption(
            value: 'left',
            label: l10n.settingsHandednessLeft,
            isSelected: _settings.handedness == Handedness.left,
          ),
        ],
        onSelected: (value) {
          _updateSettings(_settings.copyWith(
            handedness: Handedness.fromString(value),
          ));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showOrientationPicker() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => _PickerSheet(
        title: l10n.settingsOrientation,
        options: [
          _PickerOption(
            value: 'auto',
            label: l10n.settingsOrientationAuto,
            isSelected: _settings.orientationLock == ScreenOrientation.auto,
          ),
          _PickerOption(
            value: 'portrait',
            label: l10n.settingsOrientationPortrait,
            isSelected: _settings.orientationLock == ScreenOrientation.portrait,
          ),
          _PickerOption(
            value: 'landscape',
            label: l10n.settingsOrientationLandscape,
            isSelected:
                _settings.orientationLock == ScreenOrientation.landscape,
          ),
        ],
        onSelected: (value) {
          _updateSettings(_settings.copyWith(
            orientationLock: ScreenOrientation.fromString(value),
          ));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showLanguagePicker() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => _PickerSheet(
        title: l10n.settingsLanguage,
        options: [
          _PickerOption(
            value: 'ja',
            label: '日本語',
            isSelected: _settings.locale == 'ja',
          ),
          _PickerOption(
            value: 'en',
            label: 'English',
            isSelected: _settings.locale == 'en',
          ),
        ],
        onSelected: (value) {
          _updateSettings(_settings.copyWith(locale: value));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showViewModePicker() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => _PickerSheet(
        title: l10n.settingsDefaultViewMode,
        options: [
          _PickerOption(
            value: 'horizontal',
            label: l10n.viewModeHorizontal,
            isSelected: _settings.defaultViewMode == ImageViewMode.horizontal,
          ),
          _PickerOption(
            value: 'vertical',
            label: l10n.viewModeVertical,
            isSelected: _settings.defaultViewMode == ImageViewMode.vertical,
          ),
          _PickerOption(
            value: 'single',
            label: l10n.viewModeSingle,
            isSelected: _settings.defaultViewMode == ImageViewMode.single,
          ),
        ],
        onSelected: (value) {
          _updateSettings(_settings.copyWith(
            defaultViewMode: ImageViewMode.fromString(value),
          ));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showShakeSensitivityPicker() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => _PickerSheet(
        title: l10n.settingsShakeSensitivity,
        options: [
          _PickerOption(
            value: 'gentle',
            label: 'Gentle',
            isSelected: _settings.shakeSensitivity == ShakeSensitivity.gentle,
          ),
          _PickerOption(
            value: 'normal',
            label: 'Normal',
            isSelected: _settings.shakeSensitivity == ShakeSensitivity.normal,
          ),
          _PickerOption(
            value: 'hard',
            label: 'Hard',
            isSelected: _settings.shakeSensitivity == ShakeSensitivity.hard,
          ),
        ],
        onSelected: (value) {
          _updateSettings(_settings.copyWith(
            shakeSensitivity: ShakeSensitivity.fromString(value),
          ));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showFakeScreenPicker() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => _PickerSheet(
        title: l10n.settingsFakeScreen,
        options: [
          _PickerOption(
            value: 'calculator',
            label: l10n.settingsFakeScreenCalculator,
            isSelected: _settings.fakeScreen == FakeScreenType.calculator,
          ),
          _PickerOption(
            value: 'notes',
            label: l10n.settingsFakeScreenNotes,
            isSelected: _settings.fakeScreen == FakeScreenType.notes,
          ),
          _PickerOption(
            value: 'weather',
            label: l10n.settingsFakeScreenWeather,
            isSelected: _settings.fakeScreen == FakeScreenType.weather,
          ),
        ],
        onSelected: (value) {
          _updateSettings(_settings.copyWith(
            fakeScreen: FakeScreenType.fromString(value),
          ));
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: SelonaColors.textSecondary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _PickerOption {
  final String value;
  final String label;
  final bool isSelected;

  const _PickerOption({
    required this.value,
    required this.label,
    this.isSelected = false,
  });
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<_PickerOption> options;
  final void Function(String value) onSelected;

  const _PickerSheet({
    required this.title,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SelonaColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),

          // Options
          ...options.map(
            (option) => ListTile(
              title: Text(
                option.label,
                style: TextStyle(
                  color: option.isSelected
                      ? SelonaColors.primaryAccent
                      : SelonaColors.textPrimary,
                  fontWeight:
                      option.isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: option.isSelected
                  ? const Icon(
                      Icons.check,
                      color: SelonaColors.primaryAccent,
                    )
                  : null,
              onTap: () => onSelected(option.value),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
