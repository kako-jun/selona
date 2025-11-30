/// Application-wide constants
class AppConstants {
  AppConstants._();

  /// App name
  static const String appName = 'Selona';

  /// App tagline
  static const String tagline = 'Your private serenity space';

  /// PIN length range
  static const int pinMinLength = 4;
  static const int pinMaxLength = 6;

  /// Passphrase length (exactly 9 characters for pink-072)
  static const int passphraseLength = 9;

  /// Supported image extensions
  static const List<String> supportedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];

  /// Supported video extensions
  static const List<String> supportedVideoExtensions = [
    'mp4',
    'webm',
    'mkv',
  ];

  /// Maximum history items
  static const int defaultHistoryLimit = 100;

  /// Thumbnail size
  static const int thumbnailSize = 256;

  /// Animation durations
  static const Duration animationMicro = Duration(milliseconds: 150);
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 400);

  /// Cache settings
  static const int thumbnailCacheSize = 100;
}
