# Music Player Project - Technical Context

## Project Goal
Building a local-only music player in Flutter for importing and playing music from osu! beatmaps (.osz files). School graduation project targeting Linux (v1), then Android/Windows.

---

## Architecture

### Patterns
- **MVVM** - ViewModels handle business logic, Views are thin UI
- **Repository Pattern** - Data access abstraction layer
- **Provider** - State management

### Folder Structure
```
lib/
├── models/          # Data models
├── repositories/    # Data access layer
├── viewmodels/      # Business logic & state
├── views/           # UI screens
├── services/        # Utilities (audio, file management)
└── widgets/         # Reusable UI components
```

---

## Tech Stack

### Core Dependencies
- `drift` + `drift_flutter` + `sqlite3_flutter_libs` - Database ORM
- `just_audio` - Audio playback
- `provider` - State management
- `path_provider` + `path` - Platform-aware paths
- `archive` - .osz extraction

### Platform
- **Current target:** Linux
- Use `xdg-user-dir` for locale-aware directories (Music vs Musique)
- Platform-agnostic code preferred, platform-specific when necessary

---

## Database Schema

### Current (Minimal)
```dart
class Songs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get filePath => text()();
  IntColumn get duration => integer()(); // seconds
  TextColumn get imagePath => text().nullable()();
}
```

### Future Additions
```dart
class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get imagePath => text().nullable()();
}

class PlaylistSongs extends Table {
  IntColumn get playlistId => integer()();
  IntColumn get songId => integer()();
  IntColumn get sortIndex => integer()();
  // Primary key: (playlistId, songId)
}

// Optional: Artists, Albums tables with many-to-many relationships
```

---

## Core Features

### Audio Playback
- Play, pause, skip (forward/backward)
- Seek controls: ±10s buttons + interactive slider
- Queue management with shuffle mode
- Background playback (when minimized)
- Persistent playback state (resume on app restart)

### Library Management
- View/delete songs
- Display: title, artist, duration, album art

### Playlists
- Create, rename, delete playlists
- Add/remove songs to/from playlists
- Play entire playlist with shuffle

### osu! Beatmap Import
- Extract .osz files (zip archives)
- Parse .osu markup files for metadata (title, artist, source)
- Extract audio file (typically audio.mp3)
- Extract background image (from top difficulty)
- Save to dedicated music directory
- Duplicate detection

---

## File Management

### Music Directory
- Single dedicated directory (default: OS music folder)
- User-configurable
- All imported songs moved to this directory

### .osz Import Flow
1. Extract .osz to temp
2. Parse .osu files for metadata
3. Extract audio + background image
4. Move audio to music directory
5. Save background to app support directory
6. Insert song into database
7. Clean up temp files

---

## UI Structure

### Navigation
- **Top tabs:** Songs | Files | Playlists
- **Drawer:** Settings, About, scanning options

### Key Screens
- **Songs Tab:** List of all songs with swipe actions
- **Mini Player:** Bottom bar (persistent), tappable → Now Playing
- **Now Playing:** Modal view, upper half = controls, lower half = queue
- **Playlists Tab:** List of playlists
- **Files Tab:** File system browser for imports

### Design Reference
Phonograph Plus (similar tab structure and mini player)

---

## Code Preferences

- Clean, readable code with helpful comments
- Explicit types over `var` for clarity
- Comprehensive error handling
- Platform-aware paths (never hardcoded)
- Use `const` constructors where possible
- Duration format: MM:SS consistently

## Instruction for the Claude Code agent

- When asked to code something **NEVER** do it yourself unless you are explicitly prompted to do so. Instead show the user how to do it and explain why it is done that way.
