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
- **Rust Integration**: flutter_rust_bridge v2.6
- **Encryption**: pink072 crate v1.1 (external Rust library)
- **State Management**: Riverpod
- **Local Storage**: SQLite (encrypted as .pnk)

## Architecture

```
selona/
├── lib/
│   ├── main.dart
│   ├── app/                 # App-level configuration (theme, routes)
│   ├── core/                # Core utilities, constants, services
│   │   ├── constants/       # Storage paths, app constants
│   │   ├── database/        # SQLite database, repositories
│   │   ├── errors/          # Custom exceptions
│   │   └── services/        # CryptoService, ImportService, ThumbnailService, PanicService
│   ├── features/            # Feature modules
│   │   ├── auth/            # PIN lock, passphrase setup
│   │   ├── panic/           # Fake screens (calculator, notes, weather)
│   │   ├── viewer/          # Image/video viewer
│   │   ├── library/         # File management, import
│   │   └── settings/        # App settings
│   ├── l10n/                # Localization (ja, en)
│   └── shared/              # Shared widgets, models, utils
│       ├── models/          # MediaFile, Folder, AppSettings, etc.
│       ├── utils/           # ResponsiveGrid, OrientationHelper
│       └── widgets/         # Common widgets
├── rust/                    # Rust code for flutter_rust_bridge
│   ├── Cargo.toml           # Dependencies: pink072, flutter_rust_bridge
│   └── src/
│       └── api/
│           └── crypto.rs    # pink072 integration
├── windows/                 # Windows platform files
├── macos/                   # macOS platform files
├── linux/                   # Linux platform files
├── android/                 # Android platform files
├── ios/                     # iOS platform files
├── docs/                    # Specifications
├── test/                    # Tests
└── assets/                  # Icons, fonts
```

## Storage Architecture

### File Storage
- **1 file = 1 UUID.pnk** (flat storage in `vault/` directory)
- **Folder structure**: Managed in SQLite database, not filesystem
- **File names**: UUIDs only (original names stored in DB)
- **Thumbnails**: Stored as `vault/thumbs/{uuid}.pnk`

### Database Protection
- SQLite database encrypted as `selona.pnk`
- On startup: decode selona.pnk → temp DB → use
- On exit: encode temp DB → selona.pnk → delete temp

### Temporary Files
- Decoded files go to temp directory for viewing
- Automatically cleaned up after viewing
- Never persisted in decrypted form

## Key Features

### Core Features
1. **Local File Viewing**: Images (JPG, PNG, GIF, WebP, BMP) and Videos (MP4, WebM, MKV, AVI, MOV, M4V)
2. **Folder Import**: Import entire folders, preserving structure in DB, encrypted with pink072
3. **Export**: Decrypt and save individual files to device
4. **Delete**: Individual file/folder deletion only (no bulk)
5. **Sort/Filter**: By name, date, size, rating, play count; filter by unviewed/bookmarked
6. **PIN Lock**: 4-6 digit numeric code for app protection
7. **View History**: Track recently viewed files
8. **Video Resume**: Remember and auto-resume last playback position
9. **Post-Import Cleanup**: Option to delete original files after import
10. **Offline-first**: No network dependency, fully local
11. **Wake Lock**: Screen stays on while app is active (prevents auto-sleep)
12. **One-Handed Mode**: Controls positioned left or right based on handedness setting
13. **Orientation Lock**: Override OS rotation (auto/portrait-only/landscape-only)
14. **Bookmarks**: Mark favorite files and video scenes
15. **Rating**: 1-5 star rating per file
16. **Playlists**: Create custom ordered collections with auto-advance
17. **Random Mode**: Shuffle browsing within or across folders
18. **Panic Mode**: Shake to instantly show fake screen + mute audio (calculator/notes/weather)

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
  - Exactly 9 characters → maps to pink072's 9-byte seed
  - Looks like revision ID / commit hash
  - Cannot be changed after initial setup
  - Required for import and viewing
  - No recovery if forgotten
- **App Sandbox Only**: No access to device-wide file system
- **Encrypted Storage**: All files (including thumbnails and DB) encrypted with pink072
- **Temporary Decryption**: Files decrypted to temp file for viewing, then deleted
- **No Cloud Sync**: All data stays local

### Panic Mode Details
- **Trigger**: Shake detection (configurable sensitivity: gentle/normal/hard)
- **Actions**: Instantly mute audio + show fake screen
- **Fake Screens**:
  - Calculator (functional, AC long-press to exit)
  - Notes (triple-tap title to exit)
  - Weather (long-press temperature to exit)

### UI/UX
- **Theme**: Dark mode only (no light mode)
- **Icon Disguise**: Alternative app icons available
- **Languages**: Japanese + English (i18n ready)
- **Responsive Grid**: Adapts column count based on screen width
- **Minimum Window Size**: 400x600 (desktop platforms)

## Platform-Specific Notes

### Build Requirements
| Platform | Requirements | Build Machine |
|----------|-------------|---------------|
| Android | Android Studio + SDK | Windows/Mac/Linux |
| iOS | Xcode | Mac only |
| Windows | Visual Studio | Windows only |
| macOS | Xcode | Mac only |
| Linux | GCC + GTK | Linux only |

### Distribution
- **Windows**: ZIP distribution (folder with exe + DLLs)
- **macOS**: DMG or ZIP
- **Linux**: tar.gz or AppImage
- **Android**: APK or Google Play
- **iOS**: TestFlight or App Store

### Video Thumbnails
- Uses `fc_native_video_thumbnail` package
- Supported: Android, iOS, Windows, macOS
- Linux: Falls back to generic video icon (not supported)

## Development Commands

```bash
# Run on specific platform
flutter run -d linux
flutter run -d windows
flutter run -d macos
flutter run -d chrome  # for web testing
flutter run             # auto-select device

# Build
flutter build apk
flutter build ios
flutter build windows
flutter build macos
flutter build linux

# Analyze
flutter analyze

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
2. **Privacy**: No analytics, no tracking, no network calls
3. **Encryption**: pink072 crate handles all encryption via flutter_rust_bridge
4. **Memory Management**: Large files (videos) use temp file approach, not memory loading

## Related Documentation

- [Specification](docs/specification.md)
- [UI Design](docs/ui-design.md)
- [Architecture](docs/architecture.md)
