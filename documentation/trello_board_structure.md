# Music Player - Trello Board Structure

## Board Lists (Columns)
1. Backlog
2. Week 1: Minimal Backend
3. Week 2-3: Core UI
4. Week 4: Audio Playback
5. Week 5: Advanced Features
6. Week 6: Polish
7. In Progress
8. Review/Testing
9. Done

---

## BACKLOG
*Future features and ideas not in v1 scope*

### Should Have (Post-v1)
- [ ] Android support
- [ ] Windows support
- [ ] Queue reordering (drag and drop)
- [ ] Search functionality
- [ ] Advanced metadata editing
- [ ] Keyboard shortcuts

### Could Have (Nice to have)
- [ ] Multiple playlist shuffle modes
- [ ] Cross-platform config sync
- [ ] Repeat modes (repeat one, repeat all)
- [ ] Export/Import playlists

### Research Tasks
- [ ] Flutter image caching for local files
- [ ] Drift relation hydration patterns
- [ ] Android battery optimization
- [ ] StreamBuilder best practices

---

## WEEK 1: MINIMAL BACKEND
*Goal: Just enough backend to have real songs to display in UI*

### Project Setup
- [ ] Initialize clean Flutter project (remove existing messy code)
- [ ] Set up folder structure (models, repositories, viewmodels, views, services, widgets)
- [ ] Configure git + .gitignore
- [ ] Add core dependencies to pubspec.yaml (drift, path_provider, provider)
- [ ] Set up Trello board with this structure

**Estimated: 0.5 days**

---

### Minimal Database Layer
- [ ] Create simple Song table only (id, title, artist, filePath, duration, imagePath)
- [ ] Create Drift database file with Songs table
- [ ] Create Song model class
- [ ] Run build_runner to generate Drift code
- [ ] Test basic insert/select with CLI tool

**Estimated: 1 day**

**Dependencies:** Project setup complete

**Note:** Keep it minimal - no artists/albums/playlists tables yet. Add those later when needed.

---

### Basic Song Repository
- [ ] Create SongRepository class
- [ ] Implement getAllSongs() -> Stream<List<Song>>
- [ ] Implement getSongById(id) -> Future<Song?>
- [ ] Implement insertSong(song) -> Future<int>
- [ ] Implement deleteSong(id) -> Future<void>

**Estimated: 0.5 days**

**Dependencies:** Database layer complete

**Note:** No complex queries yet - just CRUD basics.

---

### Seed Data for Development
- [ ] Create a dev helper to insert 5-10 fake songs
- [ ] Use real MP3 files from your computer (or generate dummy paths)
- [ ] Include varied data (different titles, artists, durations)
- [ ] Add some test album art images

**Estimated: 0.5 days**

**Dependencies:** Basic repository complete

**Note:** This gives you real data to work with immediately in UI.

---

### Provider Setup
- [ ] Add provider dependency
- [ ] Create basic SongsViewModel
- [ ] Connect to SongRepository
- [ ] Expose songs stream
- [ ] Set up Provider in main.dart

**Estimated: 0.5 days**

**Dependencies:** Repository complete

---

### Week 1 Milestone
**Deliverable:** Database with 5-10 real songs, accessible via ViewModel. Ready to display in UI!

---

## WEEK 2-3: CORE UI
*Goal: Build all screens with real data from minimal backend*

### UI Foundation & Theme
- [ ] Create app theme (colors, typography, Material 3)
- [ ] Define reusable text styles
- [ ] Define spacing constants
- [ ] Create main scaffold structure
- [ ] Set up top tab bar (Songs | Files | Playlists)
- [ ] Set up drawer navigation
- [ ] Set up basic routing

**Estimated: 1 day**

**Dependencies:** Week 1 complete (have data to display)

---

### Songs Tab - List View
- [ ] Create SongsView widget
- [ ] Connect to SongsViewModel (Provider)
- [ ] Build ListView with StreamBuilder
- [ ] Create SongListTile widget (reusable song item)
- [ ] Display: album art thumbnail, title, artist, duration
- [ ] Format duration (MM:SS)
- [ ] Add loading state
- [ ] Add empty state ("No songs yet")
- [ ] Test with seed data

**Estimated: 1.5 days**

**Dependencies:** UI foundation, SongsViewModel

**Note:** No tap actions yet - just display. Add interactivity later.

---

### Song List Tile - Polish
- [ ] Add placeholder image when no album art
- [ ] Style text (title bold, artist secondary color)
- [ ] Add subtle dividers between items
- [ ] Add hover effect (for desktop)
- [ ] Optimize for performance (use const where possible)

**Estimated: 0.5 days**

**Dependencies:** Songs tab list view

---

### Mini Player Widget
- [ ] Create MiniPlayer widget (stateless for now)
- [ ] Layout: album art (left) | song info (center) | play button (right)
- [ ] Add thin progress bar across top
- [ ] Make entire widget tappable area
- [ ] Position at bottom of screen (above tab bar if using bottom tabs)
- [ ] Make persistent across tab navigation

**Estimated: 1 day**

**Dependencies:** UI foundation

**Note:** Use dummy/hardcoded data for now. Will connect to real player later.

---

### Now Playing View - Layout
- [ ] Create NowPlayingView widget
- [ ] Implement sliding modal (DraggableScrollableSheet)
- [ ] Upper half layout: large album art + controls
- [ ] Add all control buttons (prev, rewind -10s, play/pause, ff +10s, next)
- [ ] Add seek slider (non-functional for now)
- [ ] Add time labels (current / total)
- [ ] Add shuffle toggle button
- [ ] Style controls (proper spacing, icon sizes)

**Estimated: 2 days**

**Dependencies:** UI foundation

**Note:** All buttons are visual only - no functionality yet.

---

### Now Playing View - Queue Section
- [ ] Lower half: queue list (scrollable)
- [ ] Display upcoming songs (use seed data)
- [ ] Highlight "currently playing" song
- [ ] Make queue section swipeable to expand full-screen
- [ ] Add collapse handle/indicator
- [ ] Style queue items (smaller than main song list)

**Estimated: 1 day**

**Dependencies:** Now Playing layout complete

---

### Playlists Tab - List View
- [ ] Create PlaylistsView widget
- [ ] For now, show message: "Coming soon - focus on playback first"
- [ ] Or: show static list of 2-3 placeholder playlists
- [ ] Basic layout only - no functionality needed yet

**Estimated: 0.5 days**

**Dependencies:** UI foundation

**Note:** Playlists are lower priority - just get the UI structure in place.

---

### Files Tab - Basic Browser
- [ ] Create FilesView widget
- [ ] Show current directory path
- [ ] List folders and files from a directory (use real file system)
- [ ] Tappable folders (navigate deeper)
- [ ] Display file icons (folder vs audio file)
- [ ] Add back navigation
- [ ] Start in music directory

**Estimated: 1.5 days**

**Dependencies:** UI foundation

**Note:** Just browsing - no import functionality yet.

---

### Drawer Navigation
- [ ] Add drawer header (app name, version)
- [ ] Add menu items: Settings, About
- [ ] Add placeholder screens for Settings and About
- [ ] Wire up navigation

**Estimated: 0.5 days**

**Dependencies:** UI foundation

---

### Navigation Flow Testing
- [ ] Test tab switching (top tabs)
- [ ] Test drawer open/close
- [ ] Test Now Playing modal slide up/down
- [ ] Test mini player tap → Now Playing
- [ ] Test file browser navigation
- [ ] Ensure smooth animations
- [ ] Fix any navigation bugs

**Estimated: 0.5 days**

**Dependencies:** All UI screens created

---

### UI Polish Pass
- [ ] Consistent padding/margins across all screens
- [ ] Check text overflow (long titles, artist names)
- [ ] Add ripple effects on tappable items
- [ ] Ensure proper dark mode support (if applicable)
- [ ] Test on different screen sizes
- [ ] Fix any visual bugs

**Estimated: 1 day**

**Dependencies:** All UI screens created

---

### Week 2-3 Milestone
**Deliverable:** Complete UI that looks good and navigates smoothly. All screens exist with dummy/seed data. No playback functionality yet, but everything is clickable and feels responsive.
## WEEK 4: AUDIO PLAYBACK
*Goal: Make the app actually play music! Connect UI to real audio*

### just_audio Setup
- [ ] Add just_audio dependency
- [ ] Create AudioService class (use Provider or singleton)
- [ ] Initialize AudioPlayer instance
- [ ] Test basic audio playback with a hardcoded file path
- [ ] Ensure audio plays on Linux

**Estimated: 0.5 days**

**Dependencies:** Week 1 complete (have song file paths in database)

---

### Basic Playback Controls
- [ ] Implement play(songPath) method
- [ ] Implement pause() method
- [ ] Implement resume() method
- [ ] Implement stop() method
- [ ] Expose playback state stream (playing/paused/stopped/loading)
- [ ] Test with real audio files from seed data

**Estimated: 1 day**

**Dependencies:** just_audio setup

---

### Connect Mini Player to AudioService
- [ ] Create AudioViewModel (Provider)
- [ ] Connect to AudioService
- [ ] Update mini player to show currently playing song
- [ ] Wire up play/pause button
- [ ] Listen to playback state stream
- [ ] Update button icon based on state (play ↔ pause)
- [ ] Test: tap song in list → plays in mini player

**Estimated: 1 day**

**Dependencies:** Basic playback, Mini player UI exists

---

### Position & Duration Streams
- [ ] Expose current position stream from AudioService
- [ ] Expose duration stream from AudioService
- [ ] Update mini player progress bar (now interactive visual)
- [ ] Format and display time in Now Playing view
- [ ] Test: position updates smoothly during playback

**Estimated: 0.5 days**

**Dependencies:** Connect mini player complete

---

### Now Playing Controls - Wire Up
- [ ] Connect Now Playing view to AudioViewModel
- [ ] Wire up play/pause button
- [ ] Wire up skip next button (for now, just stop - no queue yet)
- [ ] Wire up skip previous button (for now, restart current song)
- [ ] Wire up ±10s seek buttons
- [ ] Wire up seek slider (seek to position on drag)
- [ ] Update all UI based on playback state streams
- [ ] Test all controls work

**Estimated: 1.5 days**

**Dependencies:** Now Playing UI exists, Position/duration streams

---

### Simple Queue Implementation
- [ ] Create simple Queue class (list of Songs + current index)
- [ ] Add to AudioService: loadQueue(songs, startIndex)
- [ ] Implement skip to next song in queue
- [ ] Implement skip to previous song in queue
- [ ] Auto-advance to next song when current finishes
- [ ] Update Now Playing queue view to show real upcoming songs

**Estimated: 1.5 days**

**Dependencies:** Basic playback working

---

### Connect Song List to Playback
- [ ] Make song list items tappable
- [ ] On tap: load queue with all songs, start at tapped song
- [ ] Update UI to show which song is playing (highlight in list)
- [ ] Test: tap any song → plays immediately → queue loads

**Estimated: 0.5 days**

**Dependencies:** Simple queue, Song list UI

---

### Background Playback (Linux)
- [ ] Configure just_audio for background audio on Linux
- [ ] Test: minimize app → music continues
- [ ] Test: switch to another app → music continues
- [ ] Handle app lifecycle events properly

**Estimated: 0.5 days**

**Dependencies:** Playback working

---

### Shuffle Mode - Basic
- [ ] Add shuffle state to AudioService (bool)
- [ ] Implement toggleShuffle() method
- [ ] When shuffle on: randomize queue order
- [ ] When shuffle off: restore original order
- [ ] Wire up shuffle button in Now Playing view
- [ ] Show visual indication when shuffle is on

**Estimated: 1 day**

**Dependencies:** Queue implementation

---

### Week 4 Milestone
**Deliverable:** Fully functional music player! Can play songs, control playback, see queue, shuffle works. Music continues when app is minimized.
- [ ] Add just_audio dependency
- [ ] Create AudioService class (singleton or via DI)
- [ ] Initialize AudioPlayer instance
- [ ] Implement basic play(songPath) method
- [ ] Implement pause() method
- [ ] Implement stop() method
- [ ] Test basic playback with a single song

**Estimated: 1 day**

**Dependencies:** Database has songs to play

---

### Playback Controls
- [ ] Implement skip to next track
- [ ] Implement skip to previous track
- [ ] Implement seek forward (+10 seconds)
- [ ] Implement seek backward (-10 seconds)
- [ ] Implement seek to position (slider control)
- [ ] Expose current position stream
- [ ] Expose duration stream
- [ ] Expose playback state stream (playing/paused/stopped)

**Estimated: 2 days**

**Dependencies:** Audio service setup

---

### Queue Management
- [ ] Create Queue model (list of song IDs + current index)
- [ ] Implement queue in AudioService
- [ ] Add method: loadQueue(songIds, startIndex)
- [ ] Add method: addToQueue(songId)
- [ ] Add method: addNext(songId)
- [ ] Add method: removeFromQueue(index)
- [ ] Add method: clearQueue()
- [ ] Handle queue completion (stop or loop)
- [ ] Expose current queue state stream

**Estimated: 2 days**

**Dependencies:** Playback controls complete

---

### Shuffle Logic
- [ ] Implement shuffle algorithm (randomize without immediate repeats)
- [ ] Add toggleShuffle() method
- [ ] Maintain shuffle state
- [ ] When shuffle enabled: generate shuffled queue from song list
- [ ] When shuffle disabled: restore original order
- [ ] Handle "play next" additions during shuffle

**Estimated: 1.5 days**

**Dependencies:** Queue management complete

---

### Background Playback (Linux)
- [ ] Configure just_audio for background playback on Linux
- [ ] Test playback continues when app minimized
- [ ] Test playback continues when switching to another app

**Estimated: 0.5 days**

**Dependencies:** Playback controls complete

---

### Persistent Playback State
- [ ] Create PlaybackStateService
- [ ] Define state structure (currentSongId, position, queueIds, shuffle)
- [ ] Implement saveState() to SharedPreferences
- [ ] Implement loadState() from SharedPreferences
- [ ] Add versioning/corruption handling (current + previous pattern)
- [ ] Call saveState() periodically during playback (every 10s?)
- [ ] Load state on app startup
- [ ] Handle missing song file scenario

**Estimated: 1.5 days**

**Dependencies:** Queue management, Shuffle logic

---

### Week 3-4 Milestone
**Deliverable:** Can play music with full controls, queue, shuffle, and state persists across app restarts

---

## WEEK 5: ADVANCED FEATURES
*Goal: Add beatmap import, playlists, and persistence*

### Persistent Playback State
- [ ] Create PlaybackStateService
- [ ] Define state structure (currentSongId, position, queueIds, shuffleOn)
- [ ] Implement saveState() to SharedPreferences
- [ ] Implement loadState() from SharedPreferences
- [ ] Add corruption handling (current + previous state pattern)
- [ ] Call saveState() periodically during playback (every 10s)
- [ ] Load state on app startup
- [ ] Handle missing song file gracefully
- [ ] Test: close app mid-song → reopen → resumes at same position

**Estimated: 1.5 days**

**Dependencies:** Playback working

---

### Expand Database Schema
- [ ] Add Playlist table
- [ ] Add PlaylistSong junction table (with sort_index)
- [ ] Add Artist and Album tables (optional - can postpone)
- [ ] Run build_runner
- [ ] Test new tables with CLI

**Estimated: 0.5 days**

**Dependencies:** Minimal database from Week 1

---

### Playlist Repository
- [ ] Create PlaylistRepository
- [ ] Implement getAllPlaylists()
- [ ] Implement createPlaylist(name)
- [ ] Implement deletePlaylist(id)
- [ ] Implement getSongsInPlaylist(playlistId)
- [ ] Implement addSongToPlaylist(songId, playlistId)
- [ ] Implement removeSongFromPlaylist(songId, playlistId)
- [ ] Handle sort_index properly

**Estimated: 1 day**

**Dependencies:** Expanded database schema

---

### Playlists UI - Functional
- [ ] Create PlaylistsViewModel
- [ ] Show real playlists from database
- [ ] Add "Create Playlist" button → dialog
- [ ] Implement create playlist flow
- [ ] Make playlist items tappable → navigate to detail view
- [ ] Show empty state if no playlists

**Estimated: 1 day**

**Dependencies:** Playlist repository, Playlists UI from Week 2

---

### Playlist Detail View
- [ ] Create PlaylistDetailView
- [ ] Create PlaylistDetailViewModel
- [ ] Show playlist name, song count, total duration
- [ ] List songs in playlist
- [ ] Add "Play All" button → loads queue with playlist songs
- [ ] Add "Shuffle All" button
- [ ] Add swipe action on songs: remove from playlist
- [ ] Test full flow

**Estimated: 1 day**

**Dependencies:** Playlists UI functional

---

### Add to Playlist - Song List Swipe Action
- [ ] Implement swipe actions on song list items
- [ ] Add "Add to Playlist" action
- [ ] Show playlist picker dialog
- [ ] Add song to selected playlist
- [ ] Show confirmation feedback (snackbar)
- [ ] Test full flow

**Estimated: 1 day**

**Dependencies:** Playlists functional

---

### osu! Beatmap Import - Backend
- [ ] Add archive package for .osz extraction
- [ ] Create FileService (music directory management)
- [ ] Create BeatmapImporter service
- [ ] Implement .osz extraction to temp
- [ ] Create .osu file parser (extract title, artist, source, bg filename)
- [ ] Find audio file (audio.mp3 or variants)
- [ ] Extract background image
- [ ] Copy audio to music directory
- [ ] Save background to app support directory
- [ ] Insert song into database
- [ ] Clean up temp files
- [ ] Add error handling (corrupted files, missing audio)

**Estimated: 2 days**

**Dependencies:** Expanded database, FileService

---

### osu! Beatmap Import - UI Integration
- [ ] Add "Import Beatmap" button to drawer or Files tab
- [ ] Add file picker for .osz files
- [ ] Show progress indicator during import
- [ ] Show success message with song title
- [ ] Show error message if import fails
- [ ] Imported song appears in Songs tab immediately
- [ ] Test with multiple real .osz files

**Estimated: 0.5 days**

**Dependencies:** Beatmap import backend

---

### Queue Management UI
- [ ] Make queue items in Now Playing view reorderable (if time permits)
- [ ] Add swipe to remove from queue
- [ ] Add "Clear Queue" button
- [ ] Add "Add to Queue" / "Play Next" to song list swipe actions
- [ ] Test queue manipulation during playback

**Estimated: 1 day** (or move to "Should Have" if time constrained)

**Dependencies:** Queue implementation from Week 4

---

### Week 5 Milestone
**Deliverable:** Can import osu! beatmaps, create/manage playlists, playback state persists across restarts. App is feature-complete for v1!
- [ ] Set up Provider for state management
- [ ] Create app theme (colors, typography)
- [ ] Create main scaffold with top tabs (Songs | Files | Playlists)
- [ ] Create drawer navigation structure
- [ ] Set up navigation routes

**Estimated: 1 day**

**Dependencies:** None (can be done earlier)

---

### Songs Tab
- [ ] Create SongsViewModel (using Provider)
- [ ] Connect to SongRepository
- [ ] Build song list view (ListView.builder with StreamBuilder)
- [ ] Display: album art thumbnail, title, artist, duration
- [ ] Implement tap to play
- [ ] Add swipe actions (add to playlist, add to queue, delete)
- [ ] Add loading states
- [ ] Add empty state ("No songs yet")

**Estimated: 2 days**

**Dependencies:** UI foundation, Repository pattern, Audio service

---

### Mini Player
- [ ] Create MiniPlayer widget
- [ ] Display: album art, song title, artist
- [ ] Display: non-interactive progress bar
- [ ] Add play/pause button
- [ ] Make entire area tappable → open Now Playing view
- [ ] Keep persistent across tab navigation
- [ ] Connect to AudioService streams (current song, playback state)

**Estimated: 1.5 days**

**Dependencies:** UI foundation, Audio service

---

### Now Playing View
- [ ] Create NowPlayingViewModel
- [ ] Build sliding modal view (slides up from bottom)
- [ ] Upper half: Large album art, song info, playback controls
- [ ] Add all control buttons (prev, rewind, play/pause, ff, next)
- [ ] Add interactive seek slider
- [ ] Add shuffle toggle button
- [ ] Add 3-dot menu (placeholder for now)
- [ ] Lower half: Queue view (scrollable list)
- [ ] Highlight currently playing song in queue
- [ ] Make queue swipeable to expand full screen
- [ ] Connect to AudioService streams

**Estimated: 2.5 days**

**Dependencies:** Mini player, Queue management

---

### Playlists Tab
- [ ] Create PlaylistsViewModel
- [ ] Build playlist list view
- [ ] Add "Create Playlist" button
- [ ] Implement create playlist dialog (name input)
- [ ] Display playlist items (name, song count, duration)
- [ ] Implement tap → navigate to Playlist Detail view

**Estimated: 1 day**

**Dependencies:** UI foundation, Repository pattern

---

### Playlist Detail View
- [ ] Create PlaylistDetailViewModel
- [ ] Build playlist detail screen (header + song list)
- [ ] Display playlist metadata
- [ ] Add "Shuffle All" / "Play All" buttons
- [ ] List songs in playlist
- [ ] Add swipe action: remove from playlist
- [ ] Implement back navigation

**Estimated: 1 day**

**Dependencies:** Playlists tab, Audio service

---

### Files Tab
- [ ] Create file browser view
- [ ] Display current directory path (breadcrumb)
- [ ] List folders and files
- [ ] Implement folder navigation (tap to go deeper)
- [ ] Add "Import" button for .osz files
- [ ] Show file picker for .osz selection
- [ ] Trigger BeatmapImporter on selection
- [ ] Show import progress indicator
- [ ] Show success/error feedback

**Estimated: 1.5 days**

**Dependencies:** UI foundation, BeatmapImporter service

---

### Week 5 Milestone
**Deliverable:** Fully functional UI - can browse, play, manage playlists, import beatmaps

---

## WEEK 6: POLISH & TESTING
*Goal: Bug fixes, testing, documentation, presentation prep*

### Bug Fixes & Edge Cases
- [ ] Test playback with empty queue
- [ ] Test rapid skip button presses
- [ ] Test playback with corrupted audio files
- [ ] Test shuffle with 1-2 songs
- [ ] Test queue with manual additions during shuffle
- [ ] Test playlist creation/deletion edge cases
- [ ] Test beatmap import with unusual .osz structures
- [ ] Fix any UI jank or performance issues
- [ ] Handle all error states gracefully

**Estimated: 2 days**

---

### Testing
- [ ] Manual testing checklist for all features
- [ ] Test with large library (import 100+ songs)
- [ ] Test playback state persistence (kill app at various points)
- [ ] Test with missing song files
- [ ] Test all swipe gestures
- [ ] Test navigation flows
- [ ] Performance testing (scrolling large lists)

**Estimated: 1.5 days**

---

### Documentation
- [ ] Write README.md (project overview, setup instructions, features)
- [ ] Document architecture decisions
- [ ] Add code comments to complex logic
- [ ] Create user guide (how to import beatmaps, create playlists, etc.)
- [ ] Document known limitations

**Estimated: 1 day**

---

### School Requirements
- [ ] Prepare project presentation
- [ ] Document design process (this design doc)
- [ ] Document planning/versioning usage (Trello, Git)
- [ ] Demonstrate architecture patterns (MVVM, DI, Repository)
- [ ] Prepare demo scenarios
- [ ] Create slides or demo script

**Estimated: 1.5 days**

---

### Buffer Time
- [ ] Address any remaining issues
- [ ] Final polish
- [ ] Practice presentation

**Estimated: 1 day**

---

### Week 6 Milestone
**Deliverable:** Graduation-ready project with documentation and presentation

---

## IN PROGRESS
*Currently working on - move cards here when you start them*

---

## REVIEW/TESTING
*Completed but needs validation - move here before marking done*

---

## DONE
*Completed and verified - your victory column!*

---

## Labels (Suggested)
- 🔴 Critical (blocking)
- 🟡 Important
- 🟢 Nice to have
- 🔵 Bug
- 🟣 Research
- ⚫ Documentation

## Estimation Guide
- 0.5 days = 4 hours
- 1 day = 8 hours (full dev day)
- Be realistic: account for learning time, debugging, distractions

## Daily Workflow
1. Start of day: Pick top card from current week's list → move to "In Progress"
2. Working: Update card with notes, blockers, questions
3. Completed: Move to "Review/Testing"
4. Verified: Move to "Done"
5. End of day: Review progress, plan tomorrow

## Weekly Review
- Every Sunday: Review completed work, adjust upcoming week estimates
- Identify blockers early
- Celebrate progress!
