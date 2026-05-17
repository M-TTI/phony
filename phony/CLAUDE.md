# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Critical Instruction

**When asked to code something, NEVER do it yourself unless explicitly prompted. Instead, show the user how to do it and explain why it should be done that way.**

## Project Overview

Phony is a Flutter music player for importing and playing music from osu! beatmaps (`.osz` files). School graduation project targeting Linux first, then Android/Windows.

## Commands

```bash
# Run the app (Linux)
flutter run -d linux

# Build for Linux
flutter build linux

# Run tests
flutter test

# Regenerate drift database code (required after schema changes)
dart run build_runner build

# Watch and regenerate on changes
dart run build_runner watch

# CLI database inspection tool
dart run tools/command_manager.dart
dart run tools/command_manager.dart 1  # List all songs
dart run tools/command_manager.dart 2  # Wipe database
```

## Architecture

MVVM + Repository Pattern + Provider for state management.

```
lib/
├── models/          # Plain data classes (e.g. Song)
├── repositories/    # Data access layer — abstract interfaces + Drift implementations
├── databases/       # Drift schema, AppDatabase, generated *.g.dart files
├── viewmodels/      # Business logic & state (uses Provider) — not yet implemented
├── views/           # Thin UI screens (consume ViewModels)
├── services/        # Utilities (audio playback, file management) — not yet implemented
└── widgets/         # Reusable UI components — not yet implemented
```

Views should contain no business logic. ViewModels hold state and call repositories/services.

## Key Technical Details

### Database
- Drift ORM with SQLite, stored via `getApplicationSupportDirectory()` (not a hardcoded path)
- `Songs` table uses `@DataClassName('SongsData')` so Drift generates `SongsData` as the row type, keeping it separate from the plain `Song` model in `lib/models/`
- `AppDatabase` exposes: `watchAllSongs()` (Stream), `findSongById(id)`, `insertSong(SongsCompanion)`, `deleteSong(id)`
- After any schema change, run `dart run build_runner build` to regenerate `*.g.dart` files
- `tools/command_manager.dart` is a standalone CLI for DB inspection (uses raw `sqlite3` package, not drift)

### Repository Pattern
- `lib/repositories/song_repository.dart` — abstract interface (`watchAll`, `findById`, `insert`, `delete`)
- `lib/repositories/drift_song_repository.dart` — Drift implementation; maps `SongsData → Song` via `_toModel()`
- ViewModels depend on the abstract `SongRepository`, never on `AppDatabase` or `SongsData` directly

### osu! Import Flow
1. Extract `.osz` (zip) to temp directory
2. Parse `.osu` markup files for metadata (title, artist, source, audio filename, background image)
3. Copy audio + background image to app directories
4. Insert song record into database
5. Clean up temp files

### Platform Paths
- Use `xdg-user-dir` for locale-aware directories on Linux (e.g., `xdg-user-dir MUSIC`)
- Fall back to `$HOME/Music` if `xdg-user-dir` fails
- Never hardcode paths

## Code Style

- Explicit types over `var`
- `const` constructors wherever possible
- Duration format: `MM:SS` consistently
- Platform-agnostic code preferred; platform-specific only when necessary
