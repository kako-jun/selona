# Selona - Architecture Document

## 1. System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Flutter Application                          │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                    Presentation Layer                         │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐        │   │
│  │  │   PIN    │ │ Library  │ │  Viewer  │ │ Settings │        │   │
│  │  │  Screen  │ │  Screen  │ │  Screen  │ │  Screen  │        │   │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘        │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                              │                                       │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                    Application Layer                          │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐        │   │
│  │  │   Auth   │ │  Import  │ │  Media   │ │ History  │        │   │
│  │  │ Service  │ │ Service  │ │ Service  │ │ Service  │        │   │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘        │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                              │                                       │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                      Domain Layer                             │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐        │   │
│  │  │  Folder  │ │MediaFile │ │ Settings │ │ History  │        │   │
│  │  │  Entity  │ │  Entity  │ │  Entity  │ │  Entity  │        │   │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘        │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                              │                                       │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                  Infrastructure Layer                         │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐                      │   │
│  │  │  SQLite  │ │   File   │ │  Crypto  │                      │   │
│  │  │   Repo   │ │   Repo   │ │  Bridge  │                      │   │
│  │  └──────────┘ └──────────┘ └──────────┘                      │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                              │                                       │
├─────────────────────────────────────────────────────────────────────┤
│                    flutter_rust_bridge (FFI)                        │
├─────────────────────────────────────────────────────────────────────┤
│                         Rust Native Layer                           │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                      pink-072 crate                           │   │
│  │           (Encryption / Decryption Functions)                 │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       Platform (OS)                                  │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│   │   iOS   │  │ Android │  │ Windows │  │  macOS  │  │  Linux  │ │
│   └─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. Directory Structure

```
selona/
├── lib/
│   ├── main.dart                    # Entry point
│   │
│   ├── app/
│   │   ├── app.dart                 # MaterialApp configuration
│   │   ├── routes.dart              # Route definitions
│   │   └── theme.dart               # Dark theme configuration
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart   # App-wide constants
│   │   │   └── storage_paths.dart   # File path definitions
│   │   ├── errors/
│   │   │   └── exceptions.dart      # Custom exceptions
│   │   └── utils/
│   │       ├── file_utils.dart      # File type detection
│   │       └── crypto_utils.dart    # Encryption helpers
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   └── pin_repository.dart
│   │   │   ├── domain/
│   │   │   │   └── auth_service.dart
│   │   │   └── presentation/
│   │   │       ├── pin_screen.dart
│   │   │       └── widgets/
│   │   │           └── pin_pad.dart
│   │   │
│   │   ├── library/
│   │   │   ├── data/
│   │   │   │   ├── folder_repository.dart
│   │   │   │   └── media_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── import_service.dart
│   │   │   │   └── library_service.dart
│   │   │   └── presentation/
│   │   │       ├── library_screen.dart
│   │   │       ├── import_screen.dart
│   │   │       └── widgets/
│   │   │           ├── folder_grid.dart
│   │   │           ├── media_grid.dart
│   │   │           └── thumbnail_card.dart
│   │   │
│   │   ├── viewer/
│   │   │   ├── data/
│   │   │   │   └── history_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── media_service.dart
│   │   │   │   └── history_service.dart
│   │   │   └── presentation/
│   │   │       ├── viewer_screen.dart
│   │   │       └── widgets/
│   │   │           ├── image_viewer.dart
│   │   │           ├── video_player.dart
│   │   │           └── viewer_controls.dart
│   │   │
│   │   └── settings/
│   │       ├── data/
│   │       │   └── settings_repository.dart
│   │       ├── domain/
│   │       │   └── settings_service.dart
│   │       └── presentation/
│   │           ├── settings_screen.dart
│   │           └── widgets/
│   │               └── icon_picker.dart
│   │
│   ├── l10n/
│   │   ├── app_en.arb               # English strings
│   │   └── app_ja.arb               # Japanese strings
│   │
│   └── shared/
│       ├── models/
│       │   ├── folder.dart
│       │   ├── media_file.dart
│       │   ├── view_history.dart
│       │   └── app_settings.dart
│       └── widgets/
│           ├── loading_indicator.dart
│           └── error_dialog.dart
│
├── rust/
│   ├── Cargo.toml                   # Rust dependencies
│   └── src/
│       ├── lib.rs                   # FFI exports
│       └── api/
│           ├── mod.rs
│           └── crypto.rs            # pink-072 wrapper
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── assets/
│   ├── icons/
│   │   ├── default/
│   │   └── disguise/
│   └── fonts/
│
├── docs/
│   ├── specification.md
│   ├── ui-design.md
│   └── architecture.md
│
├── pubspec.yaml
├── CLAUDE.md
└── README.md
```

---

## 3. Data Flow

### 3.1 Import Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ User Action: Select folder to import                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ ImportService.importFolder(path)                                 │
├─────────────────────────────────────────────────────────────────┤
│ 1. Scan folder for supported files                              │
│ 2. Create Folder record in DB                                   │
│ 3. For each file:                                               │
│    a. Generate UUID                                             │
│    b. Read original file bytes                                  │
│    c. Call Rust: encrypt(bytes) → encrypted_bytes               │
│    d. Write encrypted_bytes to sandbox/{uuid}.enc               │
│    e. Generate thumbnail                                        │
│    f. Encrypt thumbnail → sandbox/thumbs/{uuid}_thumb.enc       │
│    g. Create MediaFile record in DB                             │
│ 4. Prompt: Delete originals?                                    │
│    - Yes: Delete original folder                                │
│    - No: Keep originals                                         │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 View Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ User Action: Tap on media file                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ ViewerScreen.open(mediaFile)                                     │
├─────────────────────────────────────────────────────────────────┤
│ 1. Read encrypted file from sandbox                             │
│ 2. Call Rust: decrypt(encrypted_bytes) → decrypted_bytes        │
│ 3. Create memory buffer with decrypted content                  │
│ 4. Detect file type (image/video)                               │
│ 5. Display in appropriate viewer widget                         │
│    - Image: ImageViewer with scroll modes                       │
│    - Video: VideoPlayer with controls                           │
│ 6. Update ViewHistory in DB                                     │
│ 7. For video: Load lastPlaybackPosition, seek to position       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ (on close)
┌─────────────────────────────────────────────────────────────────┐
│ Cleanup:                                                         │
│ 1. For video: Save current position to MediaFile                │
│ 2. Clear memory buffer (explicitly null out)                    │
│ 3. Request garbage collection hint                              │
└─────────────────────────────────────────────────────────────────┘
```

### 3.3 Thumbnail Display Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ LibraryScreen.loadFolder(folderId)                               │
├─────────────────────────────────────────────────────────────────┤
│ 1. Query MediaFile records from DB                              │
│ 2. For each visible thumbnail:                                  │
│    a. Check thumbnail cache                                     │
│    b. If not cached:                                            │
│       - Read encrypted thumbnail from disk                      │
│       - Decrypt to memory                                       │
│       - Cache in memory (LRU cache)                             │
│    c. Display thumbnail widget                                  │
│ 3. Lazy-load as user scrolls                                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Rust Integration (flutter_rust_bridge)

### 4.1 Rust API Definition

```rust
// rust/src/api/crypto.rs

use pink_072::{encrypt_bytes, decrypt_bytes, Key};

pub fn encrypt(data: Vec<u8>, key: &[u8]) -> Result<Vec<u8>, String> {
    let key = Key::from_slice(key)
        .map_err(|e| format!("Invalid key: {}", e))?;
    encrypt_bytes(&data, &key)
        .map_err(|e| format!("Encryption failed: {}", e))
}

pub fn decrypt(data: Vec<u8>, key: &[u8]) -> Result<Vec<u8>, String> {
    let key = Key::from_slice(key)
        .map_err(|e| format!("Invalid key: {}", e))?;
    decrypt_bytes(&data, &key)
        .map_err(|e| format!("Decryption failed: {}", e))
}

pub fn generate_key() -> Vec<u8> {
    pink_072::generate_key().to_vec()
}
```

### 4.2 Dart Bridge Usage

```dart
// lib/core/utils/crypto_utils.dart

import 'package:selona/src/rust/api/crypto.dart' as rust_crypto;

class CryptoService {
  late final Uint8List _masterKey;

  Future<void> initialize() async {
    // Load or generate master key (stored securely)
    _masterKey = await _loadOrGenerateKey();
  }

  Future<Uint8List> encrypt(Uint8List data) async {
    return await rust_crypto.encrypt(
      data: data,
      key: _masterKey,
    );
  }

  Future<Uint8List> decrypt(Uint8List data) async {
    return await rust_crypto.decrypt(
      data: data,
      key: _masterKey,
    );
  }
}
```

---

## 5. State Management

### 5.1 Recommended: Riverpod

```dart
// Provider definitions

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(pinRepositoryProvider));
});

final libraryProvider = FutureProvider.family<List<MediaFile>, String>((ref, folderId) async {
  final repo = ref.read(mediaRepositoryProvider);
  return repo.getFilesInFolder(folderId);
});

final currentMediaProvider = StateProvider<MediaFile?>((ref) => null);

final viewHistoryProvider = FutureProvider<List<ViewHistory>>((ref) async {
  final service = ref.read(historyServiceProvider);
  return service.getRecentHistory(limit: 100);
});
```

---

## 6. Database Schema

### 6.1 SQLite Tables

```sql
-- folders table
CREATE TABLE folders (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    parent_id TEXT REFERENCES folders(id),
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

-- media_files table
CREATE TABLE media_files (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    folder_id TEXT NOT NULL REFERENCES folders(id),
    media_type TEXT NOT NULL CHECK (media_type IN ('image', 'video')),
    encrypted_path TEXT NOT NULL,
    encrypted_thumbnail_path TEXT,
    file_size INTEGER NOT NULL,
    imported_at INTEGER NOT NULL,
    last_viewed_at INTEGER,
    last_playback_position INTEGER  -- milliseconds, for videos
);

-- view_history table
CREATE TABLE view_history (
    id TEXT PRIMARY KEY,
    media_file_id TEXT NOT NULL REFERENCES media_files(id),
    viewed_at INTEGER NOT NULL,
    playback_position INTEGER  -- milliseconds, for videos
);

-- app_settings table (single row)
CREATE TABLE app_settings (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    pin_enabled INTEGER NOT NULL DEFAULT 0,
    pin_hash TEXT,
    app_icon TEXT NOT NULL DEFAULT 'default',
    locale TEXT NOT NULL DEFAULT 'ja',
    default_view_mode TEXT NOT NULL DEFAULT 'horizontal'
);

-- Indexes
CREATE INDEX idx_media_files_folder ON media_files(folder_id);
CREATE INDEX idx_view_history_file ON view_history(media_file_id);
CREATE INDEX idx_view_history_date ON view_history(viewed_at DESC);
```

---

## 7. Security Considerations

### 7.1 Key Storage

| Platform | Secure Storage Method |
|----------|----------------------|
| iOS | Keychain |
| Android | Android Keystore / EncryptedSharedPreferences |
| Windows | DPAPI / Windows Credential Manager |
| macOS | Keychain |
| Linux | libsecret / Secret Service API |

### 7.2 Memory Security

- Clear decrypted buffers immediately after use
- Use `Uint8List` with explicit zeroing
- Avoid unnecessary string conversions of binary data
- Consider `SecureRandom` for any random generation

### 7.3 PIN Security

- Store PIN as salted hash (e.g., Argon2 or bcrypt)
- Implement rate limiting on failed attempts
- Lock app after X failed attempts (configurable)

---

## 8. Platform-Specific Considerations

### 8.1 iOS
- File picker: `file_picker` package with proper entitlements
- App icon switching: Use `flutter_dynamic_icon`
- Background handling: Clear sensitive data on background

### 8.2 Android
- Scoped storage compliance (Android 10+)
- File picker: `file_picker` with SAF support
- Split APK for architecture-specific Rust binaries

### 8.3 Desktop (Windows/macOS/Linux)
- Window management: Handle minimize/restore for security
- File picker: Native dialogs via `file_picker`
- Tray icon: Optional, for quick-hide functionality
