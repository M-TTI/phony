import 'dart:async';

import 'package:phony/models/song.dart';
import 'package:flutter/foundation.dart';
import 'package:phony/repositories/song_repository.dart';

class SongViewmodel extends ChangeNotifier {
  final SongRepository _songRepository;
  List<Song> songs = [];
  StreamSubscription<List<Song>>? _streamSubscription;

  SongViewmodel(this._songRepository) {
    _streamSubscription = _songRepository.watchAll().listen((data) {
      songs = data;
      notifyListeners();
    });
  }

  Future<void> delete(int id) => _songRepository.delete(id);

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}