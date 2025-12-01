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
3. **Export**: Decrypt and save to device
   - ファイル1つ: そのまま復号化して保存
   - フォルダ1つ: 階層構造を保ったZIPで出力（サブフォルダ再帰）
   - 全体エクスポートは非対応
   - UIはライブラリ画面内（インポートボタンの隣ではない）
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

### Privacy Protection Features

#### 寝落ち対策（Auto-Exit on Idle）
- **無操作タイムアウト**: 設定可能（5分/15分/30分/1時間/無効）
- **タイムアウト時の動作**:
  1. アプリを完全終了（バックグラウンドに残さない）
  2. 最近使ったアプリ一覧からも削除
  3. 次回起動時は必ずPIN入力から
- **Android実装**: `finishAndRemoveTask()` + `FLAG_SECURE`
- **iOS実装**: アプリ終了 + スナップショット無効化

#### タスク履歴からの保護
- **FLAG_SECURE**: 画面キャプチャ・録画を禁止
- **履歴サムネイル**: 空白または偽装画像を表示
- **スクリーンショット禁止**: 全画面で有効

#### カメラ・マイク無効化
- **目的**: 悪意あるアプリによる盗撮・盗聴防止
- **実装方法**:
  - アプリ起動中はカメラ/マイクを使用中としてロック
  - または、他アプリのカメラ/マイクアクセスを検知して警告
- **注意**: OS権限の制約により完全な無効化は困難な場合あり
- **代替策**: カメラ/マイクの使用をユーザーに通知（録音インジケータなど）

#### リベンジポルノ防止（Hash-based Remote Wipe）
- **目的**: 流出が確認されたコンテンツの強制削除
- **仕組み**:
  1. 起動時に専用サーバーへ接続（唯一のネットワーク機能）
  2. 削除対象ハッシュリスト（SHA-256）を取得
  3. ローカルファイルのハッシュと照合
  4. 一致するファイルを自動削除
  5. 削除完了の通知（詳細は表示しない）
- **プライバシー配慮**:
  - ローカルのハッシュはサーバーに送信しない
  - サーバーからハッシュリストを受け取るのみ（一方向）
  - 通信はHTTPS必須
  - オフライン時はスキップ（ブロックしない）
- **オプトアウト**: 設定で無効化可能（自己責任）
- **サーバー**: 別途構築が必要（StopNCII.org等との連携も検討）

### UI/UX
- **Theme**: Dark mode only (no light mode)
- **Icon Disguise**: Alternative app icons available
  - アイコン候補: 電卓、メモ帳、天気、ファイルマネージャ、設定など
  - iOS: Alternate App Icons API（公式サポート）
  - Android: Activity Alias方式（切り替え時にアプリ再起動）
  - デスクトップ: 非対応（ビルド時固定）
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

## Future Feature Ideas

以下は将来的に検討可能な追加機能案です。現在の「シンプルさ」を損なわない範囲での拡張を想定しています。

### 高優先度（ユーザー体験向上）

1. **タグ機能**
   - ファイルに複数タグを付与可能
   - タグでフィルタリング・グループ化
   - プリセットタグ（お気に入り、後で見る、など）

2. **スマートフォルダ**
   - 条件に基づく自動グループ化（未視聴、高評価、最近追加など）
   - ユーザー定義のフィルタ条件

3. **複数パスフレーズ対応**
   - メインと「おとり」パスフレーズ
   - おとりで開くと別のダミーライブラリを表示

4. **ジェスチャーカスタマイズ**
   - スワイプ方向とアクションの割り当て変更
   - ダブルタップ、長押しのカスタマイズ

### 中優先度（利便性向上）

5. **バックアップ・リストア**
   - 暗号化されたままの状態でバックアップ
   - 別デバイスへの移行サポート
   - QRコードでパスフレーズ共有（自己責任）

6. **重複検出**
   - インポート時にハッシュ比較
   - 重複ファイルの警告・スキップオプション

7. **メタデータ表示**
   - EXIF情報（撮影日時、カメラ、GPS削除済み確認）
   - 動画のコーデック、解像度、ビットレート表示

8. **GIF/アニメーション対応強化**
   - GIFの再生速度調整
   - アニメーションWebP対応

9. **Picture-in-Picture (PiP)**
   - 動画の小窓再生（対応プラットフォームのみ）

### 低優先度（将来的な検討）

10. **シンプルな編集機能**
    - トリミング（画像）
    - 動画の切り出し（開始・終了点指定）
    - 結果は新規ファイルとして保存

11. **ウィジェット対応**
    - ホーム画面ウィジェット（最近のファイル、ランダム表示）
    - プライバシーを考慮した設計必須

12. **Wear OS / Watch対応**
    - リモコンとしての操作
    - 再生/一時停止、次へ/前へ

13. **外部ディスプレイ出力**
    - Miracast/AirPlay対応
    - プレゼンテーションモード（メタデータ非表示）

14. **音声コントロール**
    - 「次へ」「戻る」「一時停止」などの音声コマンド
    - オフラインで動作する軽量モデル使用

### 実装しない機能（設計方針）

以下の機能は意図的に実装しません：

- **クラウド同期**: プライバシー最優先のためローカルのみ
- **SNS共有**: 誤操作による流出リスク回避
- **ファイル検索**: シンプルさ維持、フォルダ構造で十分
- **自動整理・AI分類**: プライバシー懸念、複雑化回避
- **DRM対応**: 著作権管理は本アプリの目的外
- **一般的なネットワーク機能**: オフラインファースト（例外: リベンジポルノ防止用ハッシュ確認のみ）

## Implementation Status

### ✅ 実装済み
- ダークテーマ（ライトモードなし）
- レスポンシブグリッド（画面幅に応じたカラム数調整）
- 最小ウィンドウサイズ（デスクトップ: 400x600）
- 画面回転ロック（自動/縦固定/横固定）
- Wake Lock（画面スリープ防止）
- パニックモードUI（偽装画面: 電卓、メモ、天気）
- シェイク検知サービス（パニック発動 + ミュート）
- 片手モード（左右のコントロール配置）
- ビューア基本UI（PageView、コントロールオーバーレイ）
- スライドショー（タイマー、間隔調整、操作で解除）
- 画像/動画の回転（0°/90°/180°/270°、ファイル単位保存）
- フルスクリーン切り替え
- 動画コントロール（再生速度、コマ送り）
- 動画レジューム（再生位置の保存/復元）UI
- サムネイル生成サービス（画像リサイズ、動画フレーム抽出）
- **pink072暗号化統合**（flutter_rust_bridge v2.11.1経由でRust FFI接続済み）
- CryptoService（encode/decode/hash各種メソッド）
- i18n基盤（日本語/英語）
- **SQLiteデータベース**（メタデータ管理、folders/media_files/playlists/bookmarks/view_history）
- **ファイルインポート機能**（フォルダ/ファイル選択 → pink072暗号化 → vault保存）
- **サムネイル表示**（暗号化サムネイルのリアルタイム復号表示）
- **画像ビューア**（復号 → 一時ファイル → 表示 → 削除）

### 🚧 UI実装済み・バックエンド未接続
- PIN認証画面（検証ロジック未実装）
- パスフレーズ設定画面（暗号化未接続）
- 設定画面（DB保存未実装）
- ブックマーク/レーティング（DB保存未実装）
- 動画レジューム（DB保存未実装）
- 画像/動画の回転保存（DB保存未実装）

### ❌ 未実装
- **動画再生**（復号 → 一時ファイル → 再生）
- **エクスポート機能**（ファイル/フォルダ → 復号化/ZIP出力）
- **データベース暗号化**（selona.pnk として保存）
- **アイコン偽装**（iOS: Alternate Icons、Android: Activity Alias）
- **寝落ち対策**（無操作タイムアウト → 自動終了）
- **FLAG_SECURE**（スクリーンショット/画面録画禁止）
- **タスク履歴からの保護**（サムネイル非表示）
- **カメラ/マイク無効化**
- **リベンジポルノ防止**（リモートハッシュチェック）
- **プレイリスト**
- **ランダムモード**
- **閲覧履歴**
- **ソート/フィルタ機能**

## Data Storage Locations

### Linux
```
~/Documents/
├── vault/                    # 暗号化ファイル
│   ├── {uuid}.pnk           # メディアファイル（pink072暗号化）
│   └── thumbs/              # サムネイル
│       └── {uuid}.pnk
└── selona.pnk               # 暗号化DB（アプリ終了時に作成）

/tmp/selona_decode/
└── selona.db                # 復号化DB（稼働中のみ）
```

### SQLite Tables
- `folders` - フォルダ構造（id, name, parent_id, created_at, updated_at）
- `media_files` - ファイルメタデータ（id, name, original_extension, folder_id, media_type, encrypted_path, ...）
- `playlists` - プレイリスト
- `playlist_items` - プレイリスト内のアイテム
- `bookmarks` - ブックマーク
- `view_history` - 閲覧履歴
- `app_settings` - アプリ設定

## Known Issues / Technical Notes

### flutter_rust_bridge v2.11.1
- `frb_generated.io.dart` で `typedef bool = ...` が生成される問題あり
- dart:ffi の `Bool` と競合するため、手動で削除が必要
- 再生成時に再発する可能性あり

### Linux Build
- Rust ライブラリは別途ビルドが必要: `cd rust && cargo build --release`
- `libselona_rust.so` を `build/linux/x64/debug/bundle/lib/` にコピー

## Related Documentation

- [Specification](docs/specification.md)
- [UI Design](docs/ui-design.md)
- [Architecture](docs/architecture.md)
