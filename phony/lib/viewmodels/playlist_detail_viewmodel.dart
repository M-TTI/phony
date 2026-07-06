import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:phony/models/song.dart';
import 'package:phony/repositories/playlist_repository.dart';

class PlaylistDetailViewmodel extends ChangeNotifier {
  final PlaylistRepository _playlistRepository;
  final int playlistId;
  List<Song> songs = [];
  StreamSubscription<List<Song>>? _songStreamSubscription;

  PlaylistDetailViewmodel(this._playlistRepository, this.playlistId) {
    _songStreamSubscription = _playlistRepository.watchSongs(playlistId).listen(
      (data) {
        songs = data;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _songStreamSubscription?.cancel();
    super.dispose();
  }
}
