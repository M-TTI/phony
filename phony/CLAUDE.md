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
├── models/          # Data models
├── repositories/    # Data access layer (abstracts DB queries)
├── viewmodels/      # Business logic & state (uses Provider)
├── views/           # Thin UI screens (consume ViewModels)
├── services/        # Utilities (audio playback, file management)
└── widgets/         # Reusable UI components
```

Views should contain no business logic. ViewModels hold state and call repositories/services.

## Key Technical Details

### Database
- Drift ORM with SQLite, stored at `$DOCUMENTS/app_database.sqlite` on Linux
- After any schema change, run `dart run build_runner build` to regenerate `*.g.dart` files
- `tools/command_manager.dart` is a standalone CLI for DB inspection (uses raw `sqlite3` package, not drift)

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
