# Backlog

Pre-beta work, roughly in the order it should be done.

## Beta blockers

### 1. Busy indicator for scan / import
**Status:** done

`SongViewmodel` tracked `isScanning` / `isImporting` already; nothing in the UI read
either flag, so importing looked like the app had hung.

- `OszImportService.importFiles` takes an optional `onProgress(done, total)`, fired
  at the end of each loop iteration *outside* the try/catch so a corrupt archive
  still advances the bar. It counts archives, not songs — a mapset holds several,
  so `ImportResult.imported` legitimately exceeds `importTotal`.
- `SongViewmodel` exposes `importDone` / `importTotal`, set after the re-entrancy
  guard and reset to 0 in `finally`. The reset is load-bearing: `TopBar` picks
  determinate vs indeterminate by testing `importTotal > 0`, so a stale total would
  render the next *scan* as a bar frozen at 100%.
- `TopBar` reserves 4px permanently (`kToolbarHeight + kTextTabBarHeight +
  _progressHeight`) and wraps `TabBar` + the bar in a `PreferredSize`. `TabBar` is
  pinned in an explicit `SizedBox` so the arithmetic can't drift from the render and
  overflow the app bar.
- The bar is its own `_ImportProgressBar` widget using `context.select` on a record.
  Deliberate: `SongViewmodel` notifies on every song-list emission, and a `watch` in
  `TopBar` — or progress passed down from `MainTabsView` — would rebuild the whole
  Scaffold, including `TabBarView`, on every tick. `select` + record equality means
  only the 4px strip rebuilds.
- Colors via `progressIndicatorTheme` in `buildTheme()`, not inline. The default
  pulls `colorScheme.primary`, which is the same pink as the app bar behind it —
  an invisible bar.

**Isolate work turned out not to be needed for beta.** The original worry — that
synchronous `ZipDecoder`/`md5` work would freeze the bar — was wrong: the inner loop
in `_importOne` has three real suspension points per song (`writeAsBytes`, `stat`,
`insertScanned`), so the event loop is serviced repeatedly per archive. Measured
`decodeBytes` at **225ms** on the heaviest mapset on hand (Camellia -
Operation: Zenithfall, no video) — about 13 dropped frames, a single visible hitch
per archive, not a hang. Moved to item 7.

Still unmeasured: `md5.convert(audioBytes)` (`osz_import_service.dart:105`). Pure
Dart, runs once *per song* rather than per archive, so it may cost more in aggregate
than the decode. Worth a stopwatch before item 7 is scoped.

### 2. Embedded cover art for scanned files
**Status:** not started

Only osz imports have covers today. `audio_metadata_reader` already parses ID3v2
APIC, FLAC PICTURE blocks, MP4 `covr`, Vorbis and APE — `library_scan_service.dart:69`
explicitly opts out with `getImage: false`. Flipping it to `true` exposes
`metadata.pictures` (`List<Picture>`: `bytes`, `mimetype`, `pictureType`).

- Store as files under `getApplicationSupportDirectory()/covers/`, mirroring the
  `imported/` convention. Not as DB blobs — they would be pulled into every
  `watchAll()` emission.
- Name by hash of the *image* bytes, not the audio checksum: a 40-track album ships
  the same JPEG 40 times, so this collapses to one file on disk.
- Pick `pictureType == PictureType.coverFront`, else `pictures.first`. Derive the
  extension from `mimetype` with a magic-byte sniff as fallback.
- Fallback for files with no embedded art: `cover.jpg` / `folder.jpg` / `front.jpg`
  in the same directory. Common in rips, ~10 lines, no decoding.
- **The real work is backfill.** Existing songs have `imagePath: null` and their
  paths are already in `SongFiles`, so scan phase 1 matches by path and skips them
  forever. Needs a `coverChecked` boolean column so "checked, found nothing" is
  distinguishable from "never checked" — schema change plus `build_runner`.
- Only new files pay the extraction cost; `readMetadata` is called from
  `_insertNewSong` only.

### 3. Song list RAM usage
**Status:** done

`CoverArt` decoded images at native resolution — a 1920x1080 osu background cost
8.3MB of RGBA in the image cache, and cached decodes outlive the widgets that
requested them. Measured 60709 KB for five 48pt thumbnails on screen.

Fixed by decoding at display size in `cover_art.dart`:
`cacheHeight: (size * MediaQuery.devicePixelRatioOf(context)).ceil()`.
Measured 552 KB after — the same five covers, ~110x less.

Only one dimension is passed: `Image.file` funnels into `ResizeImage` with
`ResizeImagePolicy.exact`, so passing both stretches the decode to a square and
`BoxFit.cover` has nothing left to crop. Height is the right single choice because
art is landscape or square, so height is the shorter side for `cover`.

## Performance ceiling

Not beta blockers. Only the first is something you would feel at current library
sizes; the rest are worth knowing before shipping.

### 4. Scan write storm — quadratic
`insertScannedSong` (`database.dart:121`) opens one transaction per song, and the
scan loop calls it once per file. Drift fires `watch()` after every commit, so a
2000-song scan means 2000 fsyncs, 2000 full re-runs of the `watchAllSongs()` join,
~2 million `_toModel` allocations, and 2000 wakeups of both `SongViewmodel` and
`PlayerViewmodel._onLibraryChanged`.

Fix: wrap chunks of ~100 insert pairs in a single `transaction`. Drift's `batch()`
does not fit directly because each `SongFiles` id is needed to build its `Songs`
row. Chunking rather than one giant transaction keeps memory flat and lets progress
stay visible.

Now that item 1 has shipped, this is the most likely thing to make the scan bar look
wrong: the indeterminate animation keeps moving, but each successive song takes
longer than the last, so a large scan appears to slow to a crawl near the end. The
bar makes the quadratic cost visible rather than causing it.

### 5. `SongContextMenu` couples every tile to playlists
`song_context_menu.dart:16-19` calls `context.watch<PlaylistViewmodel>()` inside
every `SongTile`. Any playlist mutation rebuilds every visible tile, and
`menuChildren` eagerly builds one `MenuItemButton` per playlist per tile even
while the menu is closed.

Fix: drop the top-level `watch`, put a `Consumer<PlaylistViewmodel>` inside
`menuChildren` around the `SubmenuButton` contents only.

### 6. `itemExtent` on the songs list
`SongTile` is a hardcoded 80px (`song_tile.dart:36`) but `ListView.builder` does not
know that, so it lays out children to compute scroll extent. `itemExtent: 80` makes
offsets arithmetic — scrollbar drag and jump-to-position go O(n) to O(1). Hoist the
80 into a shared constant first.

### 7. osz import: whole archives in RAM, and decoded on the UI isolate
Two problems in the same code, to be fixed as one change.

**Memory:** `osz_import_service.dart:74-76` does `readAsBytes()` then
`ZipDecoder().decodeBytes`. A 100MB mapset is 100MB resident plus decoded entries.
`InputFileStream` + `decodeStream` reads lazily off disk.

**Jank:** the synchronous spans — `decodeBytes`, `utf8.decode` per `.osu`,
`md5.convert`, `readMetadata` — run on the UI isolate. Measured 225ms for
`decodeBytes` on the heaviest mapset available, i.e. one ~13-frame hitch per archive.
Tolerable today (see item 1), worse for bigger libraries and bigger archives.

Move the per-archive body (decode, parse, checksum, write audio/image files) into
`Isolate.run`. Three constraints:

- The closure may only capture sendable values. `Isolate.run(() => _importOne(...))`
  captures `this`, which reaches `AppDatabase` — that throws at runtime, not compile
  time. The isolate body must be a **top-level or static** function taking plain data
  (archive path, target dir path, known checksums).
- Split at the DB: all file and CPU work inside, every repository call outside.
  Return small records, not bytes — writing extracted files inside the isolate is
  fine and keeps the payload tiny.
- `knownChecksums` is mutated across archives for within-batch dedupe
  (`osz_import_service.dart:44`). Pass a copy in, merge new checksums out, keep the
  authoritative set on the main isolate.

`Isolate.run` spawns per call; ~1ms against archive decoding is not worth a
persistent worker until profiling says so.

### 8. Scan hashing is sequential
Phase 2 awaits each MD5 before starting the next (`library_scan_service.dart:143`).
It is I/O bound; 4-8 concurrent hashes would cut wall time on SSD. Needs a bounded
pool — `Future.wait` over the whole list would open thousands of file handles.

Explicitly rejected: hashing only the first N MB. "Checksum = identity" is what the
move/rename/dedupe logic rests on.

### 9. Two indexes
`SongFiles.checksum` UNIQUE (correctness guard first, speed second) and
`PlaylistEntries.songId` for `watchSongMembership`. Both are schema changes.

## Deferred

- Delete on-disk files under `imported/` when their song is deleted. Once covers are
  no longer checksum-named (item 2 folder fallbacks), a path could be reused with
  different bytes and show stale art — the fix then is `FileImage(File(path)).evict()`
  on delete.
- Drag-and-drop import — attempted and cancelled, `onDragExited` unreliable on GTK.
- "Open with" file association — release-packaging milestone.
- Bundle `libmpv.so.2` or document the system dependency (`mpv-libs` on Fedora,
  `libmpv2` on Debian/Ubuntu). media_kit does not ship it on Linux.
