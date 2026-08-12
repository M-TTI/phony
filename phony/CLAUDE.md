# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Critical Instruction

**When asked to code something, NEVER do it yourself unless explicitly prompted. Instead, show the user how to do it and explain why it should be done that way.**

## Project Overview

Phony is a Flutter music player. Songs come primarily from scanning a music directory, with osu! beatmap import (`.osz` files) as a secondary source. Started as a school graduation project (presented July 2026); now aiming for real releases — Play Store, RPM, AUR — targeting Linux first, then Android/Windows. Release quality (packaging, platform support, polish) is in scope.

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
dart run tools/command_manager.dart 2  # Seed database with test songs
dart run tools/command_manager.dart 3  # Wipe database (deletes the file)
```

**Linux runtime requirement**: media_kit does NOT bundle libmpv on Linux — the system library is required (`mpv-libs` on Fedora, `libmpv2` on Debian/Ubuntu). Release TODO: bundle `libmpv.so.2` in the app's `lib/` dir or document the requirement.

## Architecture

MVVM + Repository Pattern + Provider for state management.

```
lib/
├── models/            # Plain data classes: Song, SongFile, Playlist, QueueSource (sealed), PlayerState, RepeatMode
├── repositories/      # Abstract interfaces + implementations (song, song_file, playlist → Drift; player_state → shared_preferences)
├── databases/         # Drift schema, AppDatabase, generated *.g.dart files
├── viewmodels/        # SongViewmodel, PlaylistViewmodel, PlaylistDetailViewmodel, PlayerViewmodel
├── views/             # Screens: home, main tabs, songs, playlists, playlist detail, player, settings
│   └── components/    # Reusable UI: tiles, context menus, dialogs, top bar, drawer, mini player
├── themes/            # theme.dart — color/icon constants + buildTheme()
└── services/          # AudioPlayerService (media_kit), LibraryScanService, OszImportService + OszBeatmapParser
```

Views should contain no business logic. ViewModels hold state and call repositories/services.

### App shell & navigation

- `main.dart`: `WidgetsFlutterBinding.ensureInitialized()` → `MediaKit.ensureInitialized()` → `await SharedPreferences.getInstance()`, builds repositories/services, registers a `MultiProvider`: app-wide `SongViewmodel`, `PlaylistViewmodel`, `PlayerViewmodel` (ChangeNotifier), plus the raw `PlaylistRepository` for route-scoped viewmodels.
- `HomePage` is the shell: a nested `Navigator` behind a `GlobalKey` (pushed routes stay under the mini player), a persistent `MiniPlayer` bottom bar, and `PlayerView` in a `DraggableScrollableSheet` overlay that snaps between hidden and fullscreen. `HomePage.navigateToSource(QueueSource)` is the only place that performs "playing from" navigation: closes the sheet, pops the nested navigator to root, switches tab / pushes the playlist detail (after looking up the live playlist by id — handles rename/delete).
- `MainTabsView` is a `StatefulWidget` with a **public** `MainTabsViewState` that owns its `TabController` (no `DefaultTabController`) and exposes `switchToTab(int)`; `HomePage` reaches it via `GlobalKey<MainTabsViewState>`. Three tabs (Songs, Playlists, Files) + tab-aware FAB (Playlists tab only, creates a playlist). `TopBar` receives the controller as a parameter.
- `PlaylistDetailViewmodel` is route-scoped: `PlaylistDetailView.route(playlist)` (static) builds the `MaterialPageRoute` wrapped in its `ChangeNotifierProvider` — always push via this route so the provider is never forgotten.
- `AppDrawer` (hamburger in `TopBar`): "Scan music directory" (primary way to add songs), "Import .osz" (TODO), Settings.

### ViewModel conventions

- ViewModels subscribe to repository/service streams in their constructor, assign into a public field, and `notifyListeners()`; subscriptions are cancelled in `dispose()`.
- Mutations are thin passthroughs to the repository — the UI updates via the watch stream, never by manual refresh.
- Views use `context.watch` for reactive reads in `build`, `context.read` inside callbacks.
- Reconcile lists by **id, not index** — positions shift when items are removed (see `PlayerViewmodel._onLibraryChanged`, un-shuffle, restore).

## Key Technical Details

### Database
- Drift ORM with SQLite, stored via `getApplicationSupportDirectory()` (not a hardcoded path)
- Four tables: `Songs`, `SongFiles` (physical file: path, checksum, size, lastModified, duration), `Playlists`, `PlaylistEntries` (composite PK playlistId+songId, ordered by `position`)
- `Songs.songFileId` references `SongFiles` 1:1; song queries join both tables and return `(SongsData, SongFilesData)` records
- Every table uses `@DataClassName('...Data')` so Drift row types (`SongsData`, etc.) stay separate from the plain models in `lib/models/`
- `deleteSong` runs in a transaction removing the `PlaylistEntries` rows, the `Songs` row, AND the `SongFiles` row — an orphaned `SongFiles` row would act as a tombstone blocking re-import on rescan
- `watchAllPlaylists()` returns each playlist with its song count via a grouped left join
- After any schema change, run `dart run build_runner build` to regenerate `*.g.dart` files
- `tools/command_manager.dart` is a standalone CLI for DB inspection (uses raw `sqlite3` package, not drift)

### Repository Pattern
- Abstract interfaces (`song_repository.dart`, `song_file_repository.dart`, `playlist_repository.dart`, `player_state_repository.dart`) with implementations that map storage types → plain models
- ViewModels depend only on the abstract interfaces, never on `AppDatabase`, Drift row types, or `SharedPreferences`
- Adding an operation touches each layer top-down: `AppDatabase` query → interface method → impl → viewmodel method

### Library scan (`LibraryScanService`)
- **Checksum = identity, path = location.** MD5 streamed via `md5.bind(file.openRead()).first`.
- Music dir resolved via `xdg-user-dir MUSIC`, falling back to `$HOME/Music` (also when xdg returns bare `$HOME`).
- Three-phase reconciliation: (1) path match against known `SongFiles` → skip without hashing; (2) hash unknown paths — checksum match on an unseen record = move/rename (update path), match on a seen record or an already-inserted checksum = duplicate skip, no match = insert `SongFiles`+`Songs` in one transaction; (3) additive-only in v1 — missing files are NOT removed.
- Tags read via `audio_metadata_reader` (`readMetadata(file, getImage: false)`) — replaced `audiotags`, which failed to build on Windows. Untagged files fall back to the filename as title (`hasMetaData` false). `AudioMetadata.duration` is a `Duration` from audio properties (mp3 values are estimates, can be off by ~1s vs the engine); `getImage: true` additionally exposes `metadata.pictures` (`List<Picture>`: `bytes`, `mimetype`, `pictureType`) for embedded cover art.

### Playback
- **media_kit as a single-track engine** behind `AudioPlayerService` — only this file imports media_kit. Verbs: `play(path)` (open + autoplay), `load(path)` (open paused, for restore), pause/resume/seek/stop/setVolume (0–100 scale, not 0.0–1.0), plus position/duration/playing/completed streams (`completed` emits false too — filter `.where((done) => done)`).
- **The queue lives in `PlayerViewmodel`** (app-wide), never in media_kit's playlist: `playQueue(List<Song>, startIndex, QueueSource)` is the entry point (`SongTile` passes the list it was built from). next/previous (5s restart threshold), auto-advance, shuffle (`_originalQueue` preserved for un-shuffle), repeat (none/all/one) are pure viewmodel logic.
- **The queue is a snapshot** — library additions don't touch it; deletions are reconciled via a `SongRepository.watchAll()` subscription (`_onLibraryChanged`): removed songs drop out of both queues, index re-anchors by id, deleting the current song behaves like track completion, an emptied queue stops playback and clears saved state.
- `QueueSource` (sealed: `LibraryQueueSource` / `PlaylistQueueSource`) records where the queue came from — drives the tappable "PLAYING FROM" label in `PlayerView` and `HomePage.navigateToSource`.
- Volume/mute invariant: engine volume is always `isMuted ? 0 : volume`; every mutation must preserve it (`setVolume` unmutes). Volume slider is desktop-only (`Platform.isLinux || isWindows || isMacOS`), gated in the view only.

### Saved player state
- One versioned JSON blob under a single shared_preferences key, behind `PlayerStateRepository` (`PrefsPlayerStateRepository`; prefs instance injected in `main`). Stores ids, never objects: queue + original queue ids, current index, position seconds, volume/mute, shuffle/repeat, source type + playlist id.
- Save: `unawaited(_saveState())` at the end of every user mutation; position saves throttled to ≥5s intervals while playing (pause captures the exact position). Empty queue → `clear()`.
- Restore (`_restore()`, fired unawaited from the `PlayerViewmodel` constructor): treat stored state as untrusted — any parse/version failure → `load()` returns null → fresh start. Hydrates ids against the first `watchAll()` emission, drops dead ids, re-anchors index by id, resolves the playlist source live (deleted → no label), then loads the current track **paused** at the saved position (never auto-plays). Restore writes fields directly — going through public mutators would trigger saves that clobber the state being restored. Guard after every await: bail if the user already started a queue.
- Seek-after-open race: arm `duration.firstWhere((d) => d > Duration.zero)` (with timeout) BEFORE calling `load()`, then await it, then seek — subscribing after could miss the emission forever.

### Theming & UI conventions
- All colors and icons are constants in `lib/themes/theme.dart`, consumed as `t.primary`, `t.moreIcon`, etc. (`import ... as t`) — never hardcode colors in widgets
- Component styling goes in `buildTheme()` at the `ThemeData` level (FAB, tab bar, menus, drawer, filled buttons) rather than per-widget
- Hover/pressed states use `WidgetStateProperty.resolveWith` with the `primaryHovered`/`primaryPressed`/`inkHovered`/`inkPressed` constants
- Context menus are `MenuAnchor`-based components (`song_context_menu.dart`, `playlist_context_menu.dart`) triggered by a compact more-icon `IconButton` in the tile
- Dialogs with text fields are `StatefulWidget`s owning their `TextEditingController` (see `playlist_name_dialog.dart`) — never dispose a controller right after `await showDialog`, the dialog's exit animation still uses it
- Destructive actions confirm via `AlertDialog`; check `context.mounted` after every `await` before using the context
- Sliders: the **seek** slider defers — local `_dragValue` follows the finger, commit in `onChangeEnd` only (seeking per-pixel stutters mpv); the **volume** slider commits live in `onChanged` (volume is cheap and hearing it change is the point). Guard degenerate ranges: fall back to `max: 1.0` when duration is zero — `PlayerView`/`MiniPlayer` are built at startup with nothing playing and must survive it (no `!` on `currentSong` in views).
- `PlayerView` toggle buttons show state by color (`t.primary` = active); play/pause icon shows the action it will perform, not the current state.

### Song sources
1. **Scan music directory** (implemented, primary): see Library scan above.
2. **osu! import** (implemented): drawer → `file_picker` multi-select of `.osz` (zip archives). `OszImportService` decodes the archive **in memory** (no temp dir — mapsets can hold 300+ storyboard files) and writes only the audio + background image to `getApplicationSupportDirectory()/imported/`, named by checksum (idempotent, collision-free). `OszBeatmapParser` (unit-tested, `test/`) reads the `.osu` `[General]`/`[Metadata]`/`[Events]` sections: Unicode-first metadata (`TitleUnicode` falls back to `Title`; check the `Unicode` prefix BEFORE the plain one — `startsWith('Title')` matches both), one Song per unique `AudioFilename` (mapsets ship many difficulties per audio), background from `0,0,"..."` lines only (`Video,` lines and archive-missing references must be tolerated). Dedupe by checksum against the DB AND within the batch; imported songs get `hasMetaData: true` and `imagePath` set (cover art). Missing audio entry = fail that file; missing image = import without art. Deferred: deleting on-disk files under `imported/` when their song is deleted; drag-and-drop import (attempted, cancelled — `onDragExited` unreliable on GTK); "open with" association (release-packaging milestone).

### Platform Paths
- Use `xdg-user-dir` for locale-aware directories on Linux (e.g., `xdg-user-dir MUSIC`)
- Fall back to `$HOME/Music` if `xdg-user-dir` fails
- Never hardcode paths

## Code Style

- Explicit types over `var`
- `const` constructors wherever possible
- Dot-shorthand enum/constant syntax where the context type is known (`.zero`, `.none`, `padding: .zero`)
- Duration format: `MM:SS` consistently
- Platform-agnostic code preferred; platform-specific only when necessary (and gated as high in the widget tree as possible)
