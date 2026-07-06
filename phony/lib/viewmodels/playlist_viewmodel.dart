import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phony/models/playlist.dart';
import 'package:phony/repositories/playlist_repository.dart';

class PlaylistViewmodel extends ChangeNotifier {
  final PlaylistRepository _playlistRepository;
  List<Playlist> playlists = [];
  Map<int, Set<int>> _memberships = {};
  StreamSubscription<List<Playlist>>? _playlistStreamSubscription;
  StreamSubscription<Map<int, Set<int>>>? _membershipSubscription;

  PlaylistViewmodel(this._playlistRepository) {
    _playlistStreamSubscription = _playlistRepository.watchAll().listen((data) {
      playlists = data;
      notifyListeners();
    });

    _membershipSubscription = _playlistRepository.watchSongMembership().listen((
      data,
    ) {
      _memberships = data;
      notifyListeners();
    });
  }

  Future<int> create(String name) => _playlistRepository.create(name);

  Future<void> delete(int id) => _playlistRepository.delete(id);

  Future<void> addSong(int playlistId, int songId) {
    final Playlist playlist = playlists.firstWhere((p) => p.id == playlistId);

    return _playlistRepository.addSong(playlistId, songId, playlist.songCount);
  }

  Future<void> removeSong(int playlistId, int songId) =>
      _playlistRepository.removeSong(playlistId, songId);

  Future<void> rename(int id, String name) =>
      _playlistRepository.rename(id, name);

  Set<int> playlistsContaining(int songId) =>
      _memberships[songId] ?? const <int>{};

  @override
  void dispose() {
    _playlistStreamSubscription?.cancel();
    _membershipSubscription?.cancel();
    super.dispose();
  }
}
