# Selona - Specification Document

## 1. Product Overview

### 1.1 Product Name
**Selona** (セロナ)

### 1.2 Product Definition
Selona is a cross-platform private media viewer for personally collected files. Users can safely manage and view their image and video files within a secure, sandboxed environment.

### 1.3 Brand Concept
| Element | Description |
|---------|-------------|
| Name Origin | "Sel" evokes: Serenity, Secret, Self, Selene (moon goddess), Silence, Shelter, Self-care |
| Tagline | "Your private serenity space" |
| Image | Quiet, safe, elegant, non-embarrassing |
| Target | Adults who want to privately manage personal media |

### 1.4 Core Principles
- **Privacy First**: All data stays local, no cloud sync, no analytics
- **Non-Embarrassing**: App name and appearance reveal nothing about contents
- **Self-Responsibility**: Users are responsible for the files they import
- **No Copyright Infringement**: App does not download or distribute content

---

## 2. Technical Stack

### 2.1 Framework & Languages
| Component | Technology |
|-----------|------------|
| UI Framework | Flutter |
| Primary Language | Dart |
| Native Integration | Rust (via flutter_rust_bridge) |
| Encryption | pink-072 crate |

### 2.2 Target Platforms
All platforms supported simultaneously from initial release:
- iOS
- Android
- Windows
- macOS
- Linux

### 2.3 Architecture Pattern
- Feature-based modular architecture
- State Management: TBD (Riverpod recommended)
- Local Database: SQLite or Hive for metadata

---

## 3. Feature Requirements

### 3.1 Core Features

#### 3.1.1 File Management
| Feature | Description |
|---------|-------------|
| Storage | App sandbox only (no device-wide access) |
| Organization | Folder-based hierarchy |
| Import | Folder picker - import entire folders at once |
| Supported Images | JPG, PNG, GIF, WebP |
| Supported Videos | MP4, WebM, MKV |

#### 3.1.2 Import & Encryption Flow
```
User selects folder via file picker
    │
    ▼
App scans folder for supported media files
    │
    ▼
Each file is encrypted with pink-072 and stored in sandbox
    │
    ▼
Encrypted thumbnails are generated
    │
    ▼
User prompted: "Delete original files?"
    │
    ├─► Yes: Original folder/files deleted from device
    │
    └─► No: Original files kept (user's responsibility)
```

| Step | Description |
|------|-------------|
| Selection | User picks folder via system file picker |
| Scanning | App identifies all supported image/video files |
| Encryption | Each file encrypted with pink-072, stored in app sandbox |
| Thumbnails | Encrypted thumbnails generated during import |
| Cleanup Option | User can choose to delete original files after import |
| Metadata | File metadata (name, size, type) stored in local database |

#### 3.1.3 Export (Decrypt & Save)
| Feature | Description |
|---------|-------------|
| Decrypt Export | Export file as original unencrypted format |
| Destination | User chooses save location via file picker |
| Single File | Export one file at a time |
| Authentication | Requires PIN authentication before export |

#### 3.1.4 Delete
| Feature | Description |
|---------|-------------|
| Scope | Individual file or folder deletion only |
| No Bulk Delete | Cannot select multiple items for deletion |
| Confirmation | Requires confirmation dialog |
| Permanent | Deleted files cannot be recovered |

#### 3.1.5 Sort & Filter
| Feature | Description |
|---------|-------------|
| Sort by Name | Alphabetical A-Z / Z-A |
| Sort by Date | Import date newest/oldest first |
| Sort by Size | File size largest/smallest first |
| Sort by Rating | Star rating high/low |
| Sort by Play Count | Most/least viewed |
| Filter: Unviewed | Show only never-viewed files |
| Filter: Bookmarked | Show only bookmarked files |
| Filter: Rating | Show files with specific rating |

**Not Supported**:
- Folder reorganization / file moving
- Folder / file renaming
- New folder creation
- Search functionality
- Tag-based filtering (no tagging feature)

#### 3.1.6 Unified Media Viewer
A single viewer component that automatically detects and handles file type:
- **Image Files**: Display as image with viewer controls
- **Video Files**: Display as video with player controls

The viewer determines the display mode based on file extension/MIME type.

#### 3.1.7 Image Viewing Modes
| Mode | Description |
|------|-------------|
| Vertical Scroll | Scroll vertically through images |
| Horizontal Scroll | Scroll horizontally (swipe left/right) |
| Single Page | One image at a time, tap to navigate |

#### 3.1.8 Video Player Controls
| Control | Description |
|---------|-------------|
| Play/Pause | Basic playback toggle |
| Seek | Progress bar scrubbing |
| Volume | Audio level adjustment |
| Fullscreen | Enter/exit fullscreen mode |
| Resume | Auto-resume from last position |
| Slow Motion | Playback speed control (0.25x, 0.5x, 1x, etc.) |
| Frame Step | Step forward/backward frame by frame when paused |

#### 3.1.9 Zoom & Rotation (Images and Videos)
| Feature | Description |
|---------|-------------|
| Pinch Zoom | Pinch gesture to zoom in/out during playback |
| Zoom Reset | Zoom level resets to default on next open |
| Rotation | Rotate content 90°/180°/270° |
| Rotation Persist | Rotation setting saved per file |
| Double-tap | Double-tap to toggle fit/fill mode |

#### 3.1.10 History & Resume
| Feature | Description |
|---------|-------------|
| View History | Track recently viewed files |
| Video Position | Remember last playback position per video |
| Auto-Resume | Videos resume from last position when reopened |
| History Limit | Configurable (default: last 100 items) |

#### 3.1.11 Screen Wake Lock
| Feature | Description |
|---------|-------------|
| Wake Lock | Prevent screen sleep/auto-off while app is active |
| Scope | Applied when app is in foreground |
| Platform | All platforms (iOS, Android, Windows, macOS, Linux) |
| Release | Wake lock released when app goes to background |

#### 3.1.12 One-Handed Operation
| Feature | Description |
|---------|-------------|
| Handedness | All controls grouped on one side of screen |
| Setting | Choose left-hand or right-hand mode in Settings |
| Layout | Controls positioned for thumb-reachable zones |
| Switching | Instant layout flip without app restart |

#### 3.1.13 Screen Orientation Lock
| Feature | Description |
|---------|-------------|
| Orientation Lock | Override OS auto-rotate setting |
| Options | Portrait / Landscape / Auto (follow OS) |
| Scope | Applied app-wide |
| Platform | All platforms (mobile: portrait/landscape, desktop: window aspect) |

#### 3.1.14 Quick Actions
| Feature | Description |
|---------|-------------|
| Shake to Exit | Shake device to instantly return to library |
| Shake to Close | Shake harder to close app entirely |
| Shake Sensitivity | Configurable in Settings |
| Desktop Alternative | Keyboard shortcut (Esc = back, Esc×2 = close) |

#### 3.1.15 Bookmarks
| Feature | Description |
|---------|-------------|
| File Bookmark | Mark files as favorites |
| Scene Bookmark | Save specific timestamps in videos |
| Image Region | Mark specific regions in images (crop preview) |
| Quick Access | Bookmarks accessible from home screen |

#### 3.1.16 Random / Shuffle Mode
| Feature | Description |
|---------|-------------|
| Random in Folder | Randomly browse files within a folder |
| Random All | Randomly browse across all folders |
| Shuffle Playlist | Play playlist in random order |
| Continuous Random | Auto-advance to random next file |

#### 3.1.17 Rating System
| Feature | Description |
|---------|-------------|
| Star Rating | 1-5 star rating per file |
| Quick Rate | Rate during viewing with gesture or button |
| Sort by Rating | Filter/sort library by rating |
| Unrated Filter | Show only unrated files |

#### 3.1.18 Playlists
| Feature | Description |
|---------|-------------|
| Create Playlist | Group files in custom order |
| Mixed Media | Playlists can contain both images and videos |
| Auto-advance | Automatic progression through playlist |
| Image Duration | Set display time for images in playlist (e.g., 5 sec) |
| Loop | Loop playlist continuously |

### 3.2 Security Features

#### 3.2.1 App Lock
| Feature | Description |
|---------|-------------|
| Method | PIN code only (4-6 digits) |
| Trigger | App launch, return from background |
| Biometrics | Not in initial release |

#### 3.2.2 Panic Mode (Emergency Hide)
| Feature | Description |
|---------|-------------|
| Trigger | Shake device hard (any direction) |
| Action | Instantly switch to fake screen + mute audio |
| Sensitivity | Configurable (gentle/normal/hard) |
| Desktop | Rapid Esc×3 or mouse shake |
| Philosophy | Simple panic → simple escape |

#### 3.2.3 Fake Home Screen
| Feature | Description |
|---------|-------------|
| Calculator | Fully functional calculator disguise |
| Notes | Simple notepad disguise |
| Weather | Static weather display disguise |
| Selection | Choose which fake screen in Settings |
| Return | Enter secret code in fake app to return |

#### 3.2.4 Quick Mute Button
| Feature | Description |
|---------|-------------|
| Location | Always visible on video player (one-tap) |
| Hardware | Volume button quick-press also mutes |
| Visual Indicator | Clear mute state indicator |
| Remember | Option to start videos muted by default |

#### 3.2.5 File Encryption
| Feature | Description |
|---------|-------------|
| Library | pink-072 (Rust crate) |
| Integration | flutter_rust_bridge |
| Scope | All imported files encrypted at rest |
| Thumbnails | Also encrypted with pink-072 |
| Decryption | Real-time decryption for viewing (never stored decrypted) |

**Passphrase (Encryption Key)**:
| Feature | Description |
|---------|-------------|
| Format | Exactly 9 characters (8 bytes × 9 = 72 bits → pink-072) |
| Appearance | Looks like revision ID / git commit hash prefix |
| Characters | Alphanumeric (a-z, 0-9 recommended) |
| Set Once | Configured on first launch, cannot be changed |
| Required For | Import (encryption) and viewing (decryption) |
| Storage | Stored securely in platform keychain (never plaintext) |
| Recovery | No recovery possible - if forgotten, data is lost |
| PIN Bypass | After PIN authentication, passphrase not required for session |

```
First Launch Flow:
┌─────────────────────────────────────────────────────────┐
│                    Welcome to Selona                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Set your passphrase (exactly 9 characters)             │
│  (This cannot be changed later)                         │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  a3f7b2c1e                                      │   │
│  └─────────────────────────────────────────────────┘   │
│                         9/9 characters                  │
│                                                         │
│  Looks like: revision ID, commit hash                   │
│  Example: "a3f7b2c1e", "8d4e9f0a1"                      │
│                                                         │
│  ⚠️ WARNING: Cannot be recovered if forgotten           │
│                                                         │
│              [ Confirm Passphrase ]                     │
│                                                         │
└─────────────────────────────────────────────────────────┘

Import Flow:
1. User selects folder to import
2. User enters passphrase → verified against stored hash
3. Files encrypted with passphrase-derived key
4. Encrypted files stored in sandbox

View Flow:
1. User opens file
2. Passphrase verified (may be cached in session)
3. File decrypted to memory with passphrase-derived key
4. Content displayed
```

**Encryption Architecture**:
```
┌─────────────────────────────────────────────────────────────┐
│                     App Sandbox                             │
├─────────────────────────────────────────────────────────────┤
│  encrypted_files/                                           │
│    ├── {uuid}.enc           (encrypted media files)         │
│    └── thumbs/                                              │
│        └── {uuid}_thumb.enc (encrypted thumbnails)          │
│                                                             │
│  metadata.db                (SQLite: file info, no content) │
│  settings.db                (app configuration)             │
└─────────────────────────────────────────────────────────────┘

Viewing Flow:
1. User taps file in library
2. App reads encrypted file from sandbox
3. pink-072 decrypts to memory buffer (never to disk)
4. Viewer displays from memory buffer
5. Buffer cleared when viewer closes
```

#### 3.2.6 Privacy Protection
- No network calls (fully offline)
- No analytics or tracking
- No cloud synchronization
- Sandboxed storage only

### 3.3 UI/UX Features

#### 3.3.1 Theme
| Feature | Description |
|---------|-------------|
| Theme | Dark mode only |
| Color Palette | Moonlight whites, midnight blues, mist grays |
| Typography | Clean, modern sans-serif |

#### 3.3.2 Icon Disguise
| Feature | Description |
|---------|-------------|
| Default | Selona branded icon |
| Alternatives | Multiple disguise icons available |
| Switching | Settings > Appearance |

#### 3.3.3 Localization
| Language | Priority |
|----------|----------|
| Japanese | Primary |
| English | Primary |
| Others | Future expansion (i18n ready) |

---

## 4. Screen Flow

### 4.1 App Launch Flow
```
App Start
    │
    ▼
PIN Lock Screen (if enabled)
    │
    ▼
Library (Home) Screen
    │
    ├─► Folder Navigation
    │       │
    │       ▼
    │   File List
    │       │
    │       ▼
    │   Unified Viewer (Image or Video based on file type)
    │
    └─► Settings
            │
            ├─► Security (PIN)
            ├─► Appearance (Theme, Icon)
            └─► About
```

### 4.2 Main Screens

| Screen | Purpose |
|--------|---------|
| PIN Lock | Authentication gate |
| Library | Browse folders and files |
| Unified Viewer | View images or play videos |
| Settings | App configuration |
| Import | File picker interface |

---

## 5. Data Model

### 5.1 Folder
```dart
class Folder {
  String id;
  String name;
  String? parentId;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### 5.2 MediaFile
```dart
class MediaFile {
  String id;
  String name;
  String folderId;
  MediaType type; // image, video
  String encryptedPath;
  String? encryptedThumbnailPath;
  int fileSize;
  DateTime importedAt;
  DateTime? lastViewedAt;
  Duration? lastPlaybackPosition; // for videos only
  Rotation rotation; // persisted rotation setting
  int rating; // 0-5 stars (0 = unrated)
  bool isBookmarked;
}

enum MediaType { image, video }

enum Rotation {
  none,      // 0°
  cw90,      // 90° clockwise
  cw180,     // 180°
  cw270      // 270° clockwise (= 90° counter-clockwise)
}
```

### 5.3 Bookmark
```dart
class Bookmark {
  String id;
  String mediaFileId;
  BookmarkType type;
  Duration? timestamp; // for video scene bookmarks
  Rect? region; // for image region bookmarks
  String? note; // optional user note
  DateTime createdAt;
}

enum BookmarkType { file, scene, region }
```

### 5.4 Playlist
```dart
class Playlist {
  String id;
  String name;
  List<PlaylistItem> items;
  int imageDurationSeconds; // display time for images
  bool loop;
  bool shuffle;
  DateTime createdAt;
  DateTime updatedAt;
}

class PlaylistItem {
  String id;
  String playlistId;
  String mediaFileId;
  int order;
}
```

### 5.5 ViewHistory
```dart
class ViewHistory {
  String id;
  String mediaFileId;
  DateTime viewedAt;
  Duration? playbackPosition; // for videos, null for images
}
```

### 5.6 AppSettings
```dart
class AppSettings {
  // Encryption (immutable after first launch)
  String passphraseHash; // hash of user's passphrase, set once, never changes
  bool isInitialized; // true after first passphrase setup

  // Security
  bool pinEnabled;
  String? pinHash;
  String appIcon; // 'default' or disguise variant
  String locale; // 'ja', 'en'
  ImageViewMode defaultViewMode;
  Handedness handedness; // left or right hand mode
  ScreenOrientation orientationLock; // screen orientation override

  // Panic mode settings
  bool panicModeEnabled;
  ShakeSensitivity shakeSensitivity;
  FakeScreenType fakeScreen;
  String fakeScreenReturnCode; // secret code to return from fake screen

  // Playback defaults
  bool startVideosMuted;
}

enum ImageViewMode { vertical, horizontal, single }

enum Handedness { left, right }

enum ScreenOrientation {
  auto,       // follow OS setting
  portrait,   // lock to portrait
  landscape   // lock to landscape
}

enum ShakeSensitivity { gentle, normal, hard }

enum FakeScreenType { calculator, notes, weather }
```

---

## 6. Non-Functional Requirements

### 6.1 Performance
| Metric | Target |
|--------|--------|
| App Launch | < 2 seconds |
| File Import | < 1 second per file |
| Image Load | < 500ms |
| Video Start | < 1 second |

### 6.2 Storage
| Consideration | Approach |
|---------------|----------|
| Large Files | Streaming for video, lazy loading for images |
| Thumbnails | Generate and cache on import |
| Encryption Overhead | Acceptable 10-20% size increase |

### 6.3 Compatibility
| Platform | Minimum Version |
|----------|-----------------|
| iOS | 12.0+ |
| Android | API 21+ (5.0) |
| Windows | Windows 10+ |
| macOS | 10.14+ |
| Linux | Ubuntu 18.04+ equivalent |

---

## 7. Future Considerations (Not in v1)

Items explicitly deferred to future versions:
- Biometric authentication (Face ID, fingerprint)
- Cloud backup/sync
- Share sheet import (iOS/Android)
- Drag & drop import (desktop)
- Pattern lock
- Advanced video features (speed, subtitles, picture-in-picture)
- 2-page spread view for images
- Custom themes / light mode
- Multiple language support beyond ja/en

---

## 8. Glossary

| Term | Definition |
|------|------------|
| Sandbox | Isolated app storage area, inaccessible to other apps |
| pink-072 | External Rust crate for file encryption |
| flutter_rust_bridge | Library for calling Rust code from Flutter |
| Unified Viewer | Single component that displays images or videos based on file type |
| Icon Disguise | Feature to change app icon appearance |
