import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:phony/models/enums/repeat_mode.dart';
import 'package:phony/models/enums/source_type.dart';
import 'package:phony/models/player_state.dart';
import 'package:phony/models/playlist.dart';
import 'package:phony/models/queue_source.dart';
import 'package:phony/models/song.dart';
import 'package:phony/repositories/app_player_state_repository.dart';
import 'package:phony/repositories/playlist_repository.dart';
import 'package:phony/repositories/song_repository.dart';
import 'package:phony/services/audio_player_service.dart';

class PlayerViewmodel extends ChangeNotifier {
  PlayerViewmodel(
    this._audioPlayerService,
    this._songRepository,
    this._playlistRepository,
    this._stateRepository,
  ) {
    DateTime lastPositionSave = DateTime.now();

    _positionSub = _audioPlayerService.position.listen((Duration p) {
      position = p;
      notifyListeners();

      if (isPlaying &&
          DateTime.now().difference(lastPositionSave) >=
              const Duration(seconds: 5)) {
        lastPositionSave = DateTime.now();

        unawaited(_saveState());
      }
    });

    _durationSub = _audioPlayerService.duration.listen((Duration d) {
      duration = d;
      notifyListeners();
    });

    _playingSub = _audioPlayerService.playing.listen((bool p) {
      isPlaying = p;
      notifyListeners();
    });

    _completedSub = _audioPlayerService.completed
        .where((bool done) => done)
        .listen((_) => _onTrackCompleted());

    _songsSub = _songRepository.watchAll().listen(_onLibraryChanged);

    unawaited(_restoreState());
  }

  final AudioPlayerService _audioPlayerService;
  final SongRepository _songRepository;
  final PlaylistRepository _playlistRepository;
  final AppPlayerStateRepository _stateRepository;

  List<Song> _queue = [];
  List<Song> _originalQueue = [];
  int _currentIndex = -1;
  QueueSource? source;

  Song? get currentSong => (_currentIndex >= 0 && _currentIndex < _queue.length)
      ? _queue[_currentIndex]
      : null;

  bool isPlaying = false;
  Duration position = .zero;
  Duration duration = .zero;
  bool shuffleEnabled = false;
  RepeatMode repeatMode = .none;
  double volume = 100;
  bool isMuted = false;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<bool>? _completedSub;
  StreamSubscription<List<Song>>? _songsSub;

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playingSub?.cancel();
    _completedSub?.cancel();
    _songsSub?.cancel();
    super.dispose();
  }

  ///
  /// Player Controls
  ///
  Future<void> playQueue(
    List<Song> songs,
    int startIndex,
    QueueSource queueSource,
  ) async {
    if (songs.isEmpty) return;
    _originalQueue = List.of(songs);
    _queue = List.of(songs);
    _currentIndex = startIndex;
    source = queueSource;
    if (shuffleEnabled) _shuffleKeepingCurrent();
    notifyListeners();
    await _audioPlayerService.play(currentSong!.file.path);

    unawaited(_saveState());
  }

  Future<void> togglePlay() async {
    if (currentSong == null) return;
    isPlaying
        ? await _audioPlayerService.pause()
        : await _audioPlayerService.resume();

    unawaited(_saveState());
  }

  Future<void> seek(Duration target) => _audioPlayerService.seek(target);

  Future<void> next() async {
    if (_queue.isEmpty) return;
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
    } else if (repeatMode == .all) {
      _currentIndex = 0;
    } else {
      return;
    }

    notifyListeners();
    await _audioPlayerService.play(currentSong!.file.path);

    unawaited(_saveState());
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;
    if (position.inSeconds > 5 || _currentIndex == 0) {
      await _audioPlayerService.seek(.zero);

      return;
    }
    _currentIndex--;
    notifyListeners();
    await _audioPlayerService.play(currentSong!.file.path);

    unawaited(_saveState());
  }

  Future<void> _onTrackCompleted() async {
    if (currentSong == null) return;
    if (repeatMode == .one) {
      await _audioPlayerService.play(currentSong!.file.path);

      return;
    }

    await next();
  }

  void toggleRepeat() {
    repeatMode = switch (repeatMode) {
      .none => .all,
      .all => .one,
      .one => .none,
    };
    notifyListeners();

    unawaited(_saveState());
  }

  Future<void> toggleShuffle() async {
    shuffleEnabled = !shuffleEnabled;
    if (_queue.isEmpty) {
      notifyListeners();
      return;
    }
    if (shuffleEnabled) {
      _shuffleKeepingCurrent();
    } else {
      final int? id = currentSong?.id;
      _queue = List.of(_originalQueue);
      _currentIndex = _queue.indexWhere((Song s) => s.id == id);
    }
    notifyListeners();

    unawaited(_saveState());
  }

  void _shuffleKeepingCurrent() {
    final Song current = _queue.removeAt(_currentIndex);
    _queue.shuffle();
    _queue.insert(0, current);
    _currentIndex = 0;
  }

  Future<void> _onLibraryChanged(List<Song> songs) async {
    if (_queue.isEmpty) return;
    final Set<int> ids = {for (final Song s in songs) s.id};
    if (_queue.every((Song s) => ids.contains(s.id))) return;

    final int? currentId = currentSong?.id;
    _originalQueue.removeWhere((Song s) => !ids.contains(s.id));
    _queue.removeWhere((Song s) => !ids.contains(s.id));

    if (currentId != null && ids.contains(currentId)) {
      _currentIndex = _queue.indexWhere((Song s) => s.id == currentId);
    } else if (_currentIndex < _queue.length) {
      await _audioPlayerService.play(_queue[_currentIndex].file.path);
    } else {
      _currentIndex = -1;
      source = null;
      await _audioPlayerService.stop();
    }
    notifyListeners();

    unawaited(_saveState());
  }

  Future<void> setVolume(double value) async {
    volume = value;
    isMuted = false;
    notifyListeners();
    await _audioPlayerService.setVolume(value);

    unawaited(_saveState());
  }

  Future<void> toggleMute() async {
    isMuted
        ? await _audioPlayerService.setVolume(volume)
        : await _audioPlayerService.setVolume(0);

    isMuted = !isMuted;
    notifyListeners();

    unawaited(_saveState());
  }

  ///
  /// Player State
  ///
  AppPlayerState _buildState() {
    final (SourceType sourceType, int? sourcePlaylistId) = switch (source) {
      null => (SourceType.none, null),
      LibraryQueueSource() => (SourceType.library, null),
      PlaylistQueueSource(:final playlist) => (
        SourceType.playlist,
        playlist.id,
      ),
    };

    return AppPlayerState(
      queueIds: [for (final Song s in _queue) s.id],
      originalQueueIds: [for (final Song s in _originalQueue) s.id],
      currentIndex: _currentIndex,
      positionSeconds: position.inSeconds,
      volume: volume,
      isMuted: isMuted,
      shuffleEnabled: shuffleEnabled,
      repeatMode: repeatMode,
      sourceType: sourceType,
      sourcePlaylistId: sourcePlaylistId,
    );
  }

  Future<void> _saveState() => _queue.isEmpty
      ? _stateRepository.clear()
      : _stateRepository.save(_buildState());

  Future<void> _restoreState() async {
    final AppPlayerState? state = await _stateRepository.load();
    if (state == null) return;

    volume = state.volume;
    isMuted = state.isMuted;
    shuffleEnabled = state.shuffleEnabled;
    repeatMode = state.repeatMode;
    await _audioPlayerService.setVolume(
      Platform.isAndroid
          ? 100.0
          : isMuted
          ? 0
          : volume,
    );

    final List<Song> library = await _songRepository.watchAll().first;
    if (_queue.isNotEmpty) return;

    final Map<int, Song> byId = {for (final Song s in library) s.id: s};
    final List<Song> queue = state.queueIds
        .map((int id) => byId[id])
        .nonNulls
        .toList();

    final List<Song> original = state.originalQueueIds
        .map((int id) => byId[id])
        .nonNulls
        .toList();

    if (queue.isEmpty) {
      await _stateRepository.clear();
      notifyListeners();
      return;
    }

    final int? currentId =
        (state.currentIndex >= 0 && state.currentIndex < state.queueIds.length)
        ? state.queueIds[state.currentIndex]
        : null;

    int index = queue.indexWhere((Song s) => s.id == currentId);
    Duration target = Duration(seconds: state.positionSeconds);
    if (index == -1) {
      index = 0;
      target = .zero;
    }

    QueueSource? restoredSource;
    switch (state.sourceType) {
      case .library:
        restoredSource = const LibraryQueueSource();
      case .playlist:
        restoredSource = await _resolvePlaylist(state.sourcePlaylistId);
      case .none:
    }

    _queue = queue;
    _originalQueue = original;
    _currentIndex = index;
    source = restoredSource;
    position = target;
    notifyListeners();

    try {
      final Future<Duration> ready = _audioPlayerService.duration
          .firstWhere((Duration d) => d > .zero)
          .timeout(const Duration(seconds: 5));
      await _audioPlayerService.load(_queue[index].file.path);
      await ready;
      if (target > .zero) await _audioPlayerService.seek(target);
    } catch (_) {
      // engine couldn't prepare the file
    }
  }

  Future<QueueSource?> _resolvePlaylist(int? id) async {
    if (id == null) return null;
    final List<Playlist> playlists = await _playlistRepository.watchAll().first;
    final Playlist? match = playlists
        .where((Playlist p) => p.id == id)
        .firstOrNull;

    return match == null ? null : PlaylistQueueSource(match);
  }
}
