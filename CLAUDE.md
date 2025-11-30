# CLAUDE.md - Selona Project Guide

## Project Overview

**Selona** is a cross-platform private media viewer application. Users can safely view their personally collected image and video files within a sandboxed environment. The app prioritizes privacy, security, and a non-embarrassing user experience.

### Brand Concept
- **Name Origin**: "Sel" evokes Serenity, Secret, Self, Selene (moon goddess), Silence, Shelter
- **Tagline**: "Your private serenity space"
- **Target**: Adults who want to manage personal media files privately

## Tech Stack

- **Framework**: Flutter (Dart)
- **Platforms**: iOS, Android, Windows, macOS, Linux (all simultaneously)
- **Rust Integration**: flutter_rust_bridge
- **Encryption**: pink-072 crate (external Rust library)
- **State Management**: TBD (Riverpod recommended)
- **Local Storage**: SQLite or Hive for metadata

## Architecture

```
selona/
├── lib/
│   ├── main.dart
│   ├── app/                 # App-level configuration
│   ├── core/                # Core utilities, constants
│   ├── features/            # Feature modules
│   │   ├── auth/            # PIN lock
│   │   ├── viewer/          # Image/video viewer
│   │   ├── library/         # File management
│   │   └── settings/        # App settings
│   ├── l10n/                # Localization (ja, en)
│   └── shared/              # Shared widgets, models
├── rust/                    # Rust code for flutter_rust_bridge
│   └── src/
│       └── lib.rs           # pink-072 integration
├── docs/                    # Specifications
├── test/                    # Tests
└── assets/                  # Icons, fonts
```

## Key Features

### Core Features
1. **Local File Viewing**: Images (JPG, PNG, GIF, WebP) and Videos (MP4, WebM, MKV)
2. **Folder Import**: Import entire folders, encrypted with pink-072
3. **Export**: Decrypt and save individual files to device
4. **Delete**: Individual file/folder deletion only (no bulk)
5. **Sort/Filter**: By name, date, size, rating, play count; filter by unviewed/bookmarked
6. **PIN Lock**: 4-6 digit numeric code for app protection
7. **View History**: Track recently viewed files
8. **Video Resume**: Remember and auto-resume last playback position
9. **Post-Import Cleanup**: Option to delete original files after import
10. **Offline-first**: No network dependency, fully local
11. **Wake Lock**: Screen stays on while app is active (prevents auto-sleep)
12. **One-Handed Mode**: Controls grouped left or right for single-hand operation
13. **Orientation Lock**: Override OS rotation (portrait/landscape/auto)
14. **Bookmarks**: Mark favorite files and video scenes
15. **Rating**: 1-5 star rating per file
16. **Playlists**: Create custom ordered collections with auto-advance
17. **Random Mode**: Shuffle browsing within or across folders
18. **Panic Mode**: Shake to instantly hide (fake calculator/notes/weather screen)
19. **Quick Mute**: One-tap mute button always visible on video player

**Not Supported** (intentionally simple):
- Folder reorganization / file moving
- Folder / file renaming
- New folder creation
- Search functionality

### Unified Viewer
A single viewer component that automatically detects file type:
- **Image Display**: Vertical scroll, horizontal scroll, single page modes
- **Video Display**: Play/pause, seek, volume, slow motion, frame step
- **Auto-Detection**: File type determines display mode automatically
- **Zoom**: Pinch to zoom (resets on next open)
- **Rotation**: 90°/180°/270° rotation (persisted per file)
- **Fullscreen Support**: All platforms

### Security Features
- **Passphrase**: User sets 9-character passphrase on first launch (e.g., "a3f7b2c1e")
  - Exactly 9 characters (8 bytes × 9 = 72 bits → pink-072)
  - Looks like revision ID / commit hash
  - Cannot be changed after initial setup
  - Required for import and viewing
  - No recovery if forgotten
- **App Sandbox Only**: No access to device-wide file system
- **Encrypted Storage**: All files (including thumbnails) encrypted with pink-072
- **Real-time Decryption**: Files decrypted to memory only, never stored decrypted on disk
- **No Cloud Sync**: All data stays local

### UI/UX
- **Theme**: Dark mode only
- **Icon Disguise**: Alternative app icons available
- **Languages**: Japanese + English (i18n ready)

## Development Commands

```bash
# Create Flutter project
flutter create --org com.selona selona_app

# Run on specific platform
flutter run -d windows
flutter run -d macos
flutter run -d linux
flutter run -d chrome  # for web testing
flutter run             # auto-select device

# Build
flutter build apk
flutter build ios
flutter build windows
flutter build macos
flutter build linux

# Generate l10n
flutter gen-l10n

# Run tests
flutter test

# Rust bridge code generation
flutter_rust_bridge_codegen generate
```

## Coding Conventions

- **Language**: Dart (Flutter), Rust (for encryption)
- **Style**: Follow official Dart style guide
- **Naming**:
  - Files: snake_case
  - Classes: PascalCase
  - Variables/Functions: camelCase
- **Comments**: English for code, Japanese for user-facing strings
- **Error Handling**: Never expose internal errors to users

## Important Notes

1. **Copyright**: This app does NOT download or distribute content. It only views locally imported files.
2. **Privacy**: No analytics, no tracking, no network calls (except for future updates check if implemented)
3. **Encryption Crate**: pink-072 is an external dependency - ensure it's properly integrated via flutter_rust_bridge

## Related Documentation

- [Specification](docs/specification.md)
- [UI Design](docs/ui-design.md)
- [Architecture](docs/architecture.md)
