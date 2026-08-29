import 'package:drift/drift.dart';
import 'package:phony/databases/database.dart';
import 'package:phony/models/playlist.dart';
import 'package:phony/models/song.dart';
import 'package:phony/models/song_file.dart';
import 'package:phony/repositories/playlist_repository.dart';

class DriftPlaylistRepository implements PlaylistRepository {
  final AppDatabase _db;

  DriftPlaylistRepository(this._db);

  @override
  Stream<List<Playlist>> watchAll() => _db.watchAllPlaylists().map(
    (rows) => rows
        .map((r) => Playlist(id: r.$1.id, name: r.$1.name, songCount: r.$2))
        .toList(),
  );

  @override
  Stream<List<Song>> watchSongs(int playlistId) => _db
      .watchPlayListSongs(playlistId)
      .map((rows) => rows.map((r) => _toSongModel(r.$1, r.$2)).toList());

  @override
  Future<int> create(String name) =>
      _db.insertPlaylist(PlaylistsCompanion(name: Value(name)));

  @override
  Future<void> delete(int id) => _db.deletePlaylist(id);

  @override
  Future<void> addSong(int playlistId, int songId, int position) =>
      _db.addSongToPlaylist(
        PlaylistEntriesCompanion(
          playlistId: Value(playlistId),
          songId: Value(songId),
          position: Value(position),
        ),
      );

  @override
  Future<void> removeSong(int playlistId, int songId) =>
      _db.removeSongFromPlaylist(playlistId, songId);

  @override
  Future<void> rename(int id, String name) => _db.renamePlaylist(id, name);

  @override
  Stream<Map<int, Set<int>>> watchSongMembership() =>
      _db.watchAllPlaylistEntries().map((rows) {
        final Map<int, Set<int>> membership = {};
        for (final row in rows) {
          membership.putIfAbsent(row.songId, () => <int>{}).add(row.playlistId);
        }
        return membership;
      });

  Song _toSongModel(SongsData song, SongFilesData file) => Song(
    id: song.id,
    title: song.title,
    artist: song.artist,
    file: SongFile(
      id: file.id,
      name: file.name,
      path: file.path,
      artist: file.artist,
      duration: file.duration,
      checksum: file.checksum,
      size: file.size,
      lastModified: file.lastModified,
    ),
    duration: song.duration,
    imagePath: song.imagePath,
    hasMetaData: song.hasMetaData,
  );
}
