import 'package:drift/drift.dart';
import 'package:phony/models/song.dart';
import 'package:phony/databases/database.dart';
import 'package:phony/models/song_file.dart';
import 'package:phony/repositories/song_repository.dart';

class DriftSongRepository implements SongRepository {
  final AppDatabase _db;

  DriftSongRepository(this._db);

  @override
  Future<Song?> findById(int id) async {
    final row = await _db.findSongById(id);
    return row == null ? null : _toModel(row.$1, row.$2);
  }

  @override
  Stream<List<Song>> watchAll() => _db.watchAllSongs()
      .map((rows) => rows.map((r) => _toModel(r.$1, r.$2)).toList());

  @override
  Future<void> insert(Song song) => _db.insertSong(
    SongsCompanion(
      title: Value(song.title),
      artist: Value(song.artist),
      songFileId: Value(song.file.id),
      duration: Value(song.duration),
      imagePath: Value(song.imagePath),
      hasMetaData: Value(song.hasMetaData),
    ),
  );

  @override
  Future<void> delete(int id) => _db.deleteSong(id);

  Song _toModel(SongsData song, SongFilesData file) => Song(
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
    ),
    duration: song.duration,
    imagePath: song.imagePath,
    hasMetaData: song.hasMetaData,
  );
}