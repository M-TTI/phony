import 'package:phony/models/playlist.dart';
import 'package:phony/models/song.dart';

abstract class PlaylistRepository {
  Stream<List<Playlist>> watchAll();

  Stream<List<Song>> watchSongs(int playlistId);

  Future<int> create(String name);

  Future<void> delete(int id);

  Future<void> addSong(int playlistId, int songId, int position);

  Future<void> removeSong(int playlistId, int songId);

  Future<void> rename(int id, String name);

  Stream<Map<int, Set<int>>> watchSongMembership();
}
