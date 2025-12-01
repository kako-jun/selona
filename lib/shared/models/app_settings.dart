import 'package:equatable/equatable.dart';

/// Image view mode options
enum ImageViewMode {
  vertical,
  horizontal,
  single;

  static ImageViewMode fromString(String value) {
    switch (value) {
      case 'vertical':
        return ImageViewMode.vertical;
      case 'horizontal':
        return ImageViewMode.horizontal;
      case 'single':
        return ImageViewMode.single;
      default:
        return ImageViewMode.horizontal;
    }
  }
}

/// Handedness setting for one-handed operation
enum Handedness {
  left,
  right;

  static Handedness fromString(String value) {
    switch (value) {
      case 'left':
        return Handedness.left;
      case 'right':
        return Handedness.right;
      default:
        return Handedness.right;
    }
  }
}

/// Screen orientation lock option
enum ScreenOrientation {
  auto,
  portrait,
  landscape;

  static ScreenOrientation fromString(String value) {
    switch (value) {
      case 'auto':
        return ScreenOrientation.auto;
      case 'portrait':
        return ScreenOrientation.portrait;
      case 'landscape':
        return ScreenOrientation.landscape;
      default:
        return ScreenOrientation.auto;
    }
  }
}

/// Shake sensitivity for panic mode
enum ShakeSensitivity {
  gentle,
  normal,
  hard;

  static ShakeSensitivity fromString(String value) {
    switch (value) {
      case 'gentle':
        return ShakeSensitivity.gentle;
      case 'normal':
        return ShakeSensitivity.normal;
      case 'hard':
        return ShakeSensitivity.hard;
      default:
        return ShakeSensitivity.normal;
    }
  }
}

/// Fake screen type for panic mode
enum FakeScreenType {
  calculator,
  notes,
  weather;

  static FakeScreenType fromString(String value) {
    switch (value) {
      case 'calculator':
        return FakeScreenType.calculator;
      case 'notes':
        return FakeScreenType.notes;
      case 'weather':
        return FakeScreenType.weather;
      default:
        return FakeScreenType.calculator;
    }
  }
}

/// Auto-exit timeout for idle detection (寝落ち対策)
enum IdleTimeout {
  disabled,
  minutes5,
  minutes15,
  minutes30,
  hour1;

  int? get minutes {
    switch (this) {
      case IdleTimeout.disabled:
        return null;
      case IdleTimeout.minutes5:
        return 5;
      case IdleTimeout.minutes15:
        return 15;
      case IdleTimeout.minutes30:
        return 30;
      case IdleTimeout.hour1:
        return 60;
    }
  }

  static IdleTimeout fromString(String value) {
    switch (value) {
      case 'disabled':
        return IdleTimeout.disabled;
      case 'minutes5':
        return IdleTimeout.minutes5;
      case 'minutes15':
        return IdleTimeout.minutes15;
      case 'minutes30':
        return IdleTimeout.minutes30;
      case 'hour1':
        return IdleTimeout.hour1;
      default:
        return IdleTimeout.minutes15;
    }
  }
}

/// Application settings
class AppSettings extends Equatable {
  // Encryption (immutable after first launch)
  final String? passphraseHash;
  final bool isInitialized;

  // Security
  final bool pinEnabled;
  final String? pinHash;
  final String appIcon;
  final String locale;
  final ImageViewMode defaultViewMode;
  final Handedness handedness;
  final ScreenOrientation orientationLock;

  // Panic mode settings
  final bool panicModeEnabled;
  final ShakeSensitivity shakeSensitivity;
  final FakeScreenType fakeScreen;
  final String? fakeScreenReturnCode;

  // Playback defaults
  final bool startVideosMuted;

  // History settings
  final int historyLimit;

  const AppSettings({
    this.passphraseHash,
    this.isInitialized = false,
    this.pinEnabled = false,
    this.pinHash,
    this.appIcon = 'default',
    this.locale = 'ja',
    this.defaultViewMode = ImageViewMode.horizontal,
    this.handedness = Handedness.right,
    this.orientationLock = ScreenOrientation.auto,
    this.panicModeEnabled = false,
    this.shakeSensitivity = ShakeSensitivity.normal,
    this.fakeScreen = FakeScreenType.calculator,
    this.fakeScreenReturnCode,
    this.startVideosMuted = false,
    this.historyLimit = 100,
  });

  /// Default settings
  static const AppSettings defaults = AppSettings();

  /// Create from database map
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      passphraseHash: map['passphrase_hash'] as String?,
      isInitialized: (map['is_initialized'] as int? ?? 0) == 1,
      pinEnabled: (map['pin_enabled'] as int? ?? 0) == 1,
      pinHash: map['pin_hash'] as String?,
      appIcon: map['app_icon'] as String? ?? 'default',
      locale: map['locale'] as String? ?? 'ja',
      defaultViewMode: ImageViewMode.fromString(
        map['default_view_mode'] as String? ?? 'horizontal',
      ),
      handedness: Handedness.fromString(
        map['handedness'] as String? ?? 'right',
      ),
      orientationLock: ScreenOrientation.fromString(
        map['orientation_lock'] as String? ?? 'auto',
      ),
      panicModeEnabled: (map['panic_mode_enabled'] as int? ?? 0) == 1,
      shakeSensitivity: ShakeSensitivity.fromString(
        map['shake_sensitivity'] as String? ?? 'normal',
      ),
      fakeScreen: FakeScreenType.fromString(
        map['fake_screen'] as String? ?? 'calculator',
      ),
      fakeScreenReturnCode: map['fake_screen_return_code'] as String?,
      startVideosMuted: (map['start_videos_muted'] as int? ?? 0) == 1,
      historyLimit: map['history_limit'] as int? ?? 100,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'passphrase_hash': passphraseHash,
      'is_initialized': isInitialized ? 1 : 0,
      'pin_enabled': pinEnabled ? 1 : 0,
      'pin_hash': pinHash,
      'app_icon': appIcon,
      'locale': locale,
      'default_view_mode': defaultViewMode.name,
      'handedness': handedness.name,
      'orientation_lock': orientationLock.name,
      'panic_mode_enabled': panicModeEnabled ? 1 : 0,
      'shake_sensitivity': shakeSensitivity.name,
      'fake_screen': fakeScreen.name,
      'fake_screen_return_code': fakeScreenReturnCode,
      'start_videos_muted': startVideosMuted ? 1 : 0,
      'history_limit': historyLimit,
    };
  }

  /// Create a copy with updated fields
  AppSettings copyWith({
    String? passphraseHash,
    bool? isInitialized,
    bool? pinEnabled,
    String? pinHash,
    bool clearPinHash = false,
    String? appIcon,
    String? locale,
    ImageViewMode? defaultViewMode,
    Handedness? handedness,
    ScreenOrientation? orientationLock,
    bool? panicModeEnabled,
    ShakeSensitivity? shakeSensitivity,
    FakeScreenType? fakeScreen,
    String? fakeScreenReturnCode,
    bool clearFakeScreenReturnCode = false,
    bool? startVideosMuted,
    int? historyLimit,
  }) {
    return AppSettings(
      passphraseHash: passphraseHash ?? this.passphraseHash,
      isInitialized: isInitialized ?? this.isInitialized,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      pinHash: clearPinHash ? null : (pinHash ?? this.pinHash),
      appIcon: appIcon ?? this.appIcon,
      locale: locale ?? this.locale,
      defaultViewMode: defaultViewMode ?? this.defaultViewMode,
      handedness: handedness ?? this.handedness,
      orientationLock: orientationLock ?? this.orientationLock,
      panicModeEnabled: panicModeEnabled ?? this.panicModeEnabled,
      shakeSensitivity: shakeSensitivity ?? this.shakeSensitivity,
      fakeScreen: fakeScreen ?? this.fakeScreen,
      fakeScreenReturnCode: clearFakeScreenReturnCode
          ? null
          : (fakeScreenReturnCode ?? this.fakeScreenReturnCode),
      startVideosMuted: startVideosMuted ?? this.startVideosMuted,
      historyLimit: historyLimit ?? this.historyLimit,
    );
  }

  @override
  List<Object?> get props => [
        passphraseHash,
        isInitialized,
        pinEnabled,
        pinHash,
        appIcon,
        locale,
        defaultViewMode,
        handedness,
        orientationLock,
        panicModeEnabled,
        shakeSensitivity,
        fakeScreen,
        fakeScreenReturnCode,
        startVideosMuted,
        historyLimit,
      ];
}
