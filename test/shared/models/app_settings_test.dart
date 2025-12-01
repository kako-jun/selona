import 'package:flutter_test/flutter_test.dart';
import 'package:selona/shared/models/app_settings.dart';

void main() {
  group('ImageViewMode', () {
    test('fromString returns correct mode', () {
      expect(ImageViewMode.fromString('vertical'), ImageViewMode.vertical);
      expect(ImageViewMode.fromString('horizontal'), ImageViewMode.horizontal);
      expect(ImageViewMode.fromString('single'), ImageViewMode.single);
    });

    test('fromString returns horizontal for unknown value', () {
      expect(ImageViewMode.fromString('unknown'), ImageViewMode.horizontal);
      expect(ImageViewMode.fromString(''), ImageViewMode.horizontal);
    });
  });

  group('Handedness', () {
    test('fromString returns correct handedness', () {
      expect(Handedness.fromString('left'), Handedness.left);
      expect(Handedness.fromString('right'), Handedness.right);
    });

    test('fromString returns right for unknown value', () {
      expect(Handedness.fromString('unknown'), Handedness.right);
    });
  });

  group('ScreenOrientation', () {
    test('fromString returns correct orientation', () {
      expect(ScreenOrientation.fromString('auto'), ScreenOrientation.auto);
      expect(
          ScreenOrientation.fromString('portrait'), ScreenOrientation.portrait);
      expect(ScreenOrientation.fromString('landscape'),
          ScreenOrientation.landscape);
    });

    test('fromString returns auto for unknown value', () {
      expect(ScreenOrientation.fromString('unknown'), ScreenOrientation.auto);
    });
  });

  group('ShakeSensitivity', () {
    test('fromString returns correct sensitivity', () {
      expect(ShakeSensitivity.fromString('gentle'), ShakeSensitivity.gentle);
      expect(ShakeSensitivity.fromString('normal'), ShakeSensitivity.normal);
      expect(ShakeSensitivity.fromString('hard'), ShakeSensitivity.hard);
    });

    test('fromString returns normal for unknown value', () {
      expect(ShakeSensitivity.fromString('unknown'), ShakeSensitivity.normal);
    });
  });

  group('FakeScreenType', () {
    test('fromString returns correct type', () {
      expect(
          FakeScreenType.fromString('calculator'), FakeScreenType.calculator);
      expect(FakeScreenType.fromString('notes'), FakeScreenType.notes);
      expect(FakeScreenType.fromString('weather'), FakeScreenType.weather);
    });

    test('fromString returns calculator for unknown value', () {
      expect(FakeScreenType.fromString('unknown'), FakeScreenType.calculator);
    });
  });

  group('AppSettings', () {
    test('defaults are reasonable', () {
      const settings = AppSettings.defaults;

      expect(settings.isInitialized, false);
      expect(settings.pinEnabled, false);
      expect(settings.locale, 'ja');
      expect(settings.defaultViewMode, ImageViewMode.horizontal);
      expect(settings.handedness, Handedness.right);
      expect(settings.orientationLock, ScreenOrientation.auto);
      expect(settings.panicModeEnabled, false);
      expect(settings.shakeSensitivity, ShakeSensitivity.normal);
      expect(settings.fakeScreen, FakeScreenType.calculator);
      expect(settings.startVideosMuted, false);
      expect(settings.historyLimit, 100);
    });

    group('toMap/fromMap', () {
      test('roundtrip preserves all fields', () {
        const settings = AppSettings(
          passphraseHash: 'abc123hash',
          isInitialized: true,
          pinEnabled: true,
          pinHash: 'pin456hash',
          appIcon: 'calculator',
          locale: 'en',
          defaultViewMode: ImageViewMode.vertical,
          handedness: Handedness.left,
          orientationLock: ScreenOrientation.landscape,
          panicModeEnabled: true,
          shakeSensitivity: ShakeSensitivity.gentle,
          fakeScreen: FakeScreenType.notes,
          fakeScreenReturnCode: '123',
          startVideosMuted: true,
          historyLimit: 50,
        );

        final map = settings.toMap();
        final restored = AppSettings.fromMap(map);

        expect(restored.passphraseHash, settings.passphraseHash);
        expect(restored.isInitialized, settings.isInitialized);
        expect(restored.pinEnabled, settings.pinEnabled);
        expect(restored.pinHash, settings.pinHash);
        expect(restored.appIcon, settings.appIcon);
        expect(restored.locale, settings.locale);
        expect(restored.defaultViewMode, settings.defaultViewMode);
        expect(restored.handedness, settings.handedness);
        expect(restored.orientationLock, settings.orientationLock);
        expect(restored.panicModeEnabled, settings.panicModeEnabled);
        expect(restored.shakeSensitivity, settings.shakeSensitivity);
        expect(restored.fakeScreen, settings.fakeScreen);
        expect(restored.fakeScreenReturnCode, settings.fakeScreenReturnCode);
        expect(restored.startVideosMuted, settings.startVideosMuted);
        expect(restored.historyLimit, settings.historyLimit);
      });

      test('fromMap handles missing optional fields', () {
        final map = <String, dynamic>{};
        final settings = AppSettings.fromMap(map);

        expect(settings.passphraseHash, isNull);
        expect(settings.isInitialized, false);
        expect(settings.pinEnabled, false);
        expect(settings.pinHash, isNull);
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        const original = AppSettings.defaults;

        final updated = original.copyWith(
          locale: 'en',
          pinEnabled: true,
          historyLimit: 200,
        );

        expect(updated.locale, 'en');
        expect(updated.pinEnabled, true);
        expect(updated.historyLimit, 200);
        // Unchanged
        expect(updated.handedness, original.handedness);
        expect(updated.defaultViewMode, original.defaultViewMode);
      });

      test('clearPinHash removes pin hash', () {
        const withPin = AppSettings(pinHash: 'hash123');
        expect(withPin.pinHash, isNotNull);

        final cleared = withPin.copyWith(clearPinHash: true);
        expect(cleared.pinHash, isNull);
      });

      test('clearFakeScreenReturnCode removes return code', () {
        const withCode = AppSettings(fakeScreenReturnCode: '999');
        expect(withCode.fakeScreenReturnCode, isNotNull);

        final cleared = withCode.copyWith(clearFakeScreenReturnCode: true);
        expect(cleared.fakeScreenReturnCode, isNull);
      });
    });

    test('equality works correctly', () {
      const settings1 = AppSettings(locale: 'ja', historyLimit: 100);
      const settings2 = AppSettings(locale: 'ja', historyLimit: 100);
      const settings3 = AppSettings(locale: 'en', historyLimit: 100);

      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });
  });
}
