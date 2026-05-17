import 'package:drift/drift.dart';
import 'package:phony/models/song.dart';
import 'package:phony/databases/database.dart';
import 'package:phony/repositories/song_repository.dart';

class DriftSongRepository implements SongRepository {
  final AppDatabase _db;

  DriftSongRepository(this._db);

  @override
  Stream<List<Song>> watchAll() => _db.watchAllSongs()
      .map((rows) => rows.map(_toModel).toList());

  @override
  Future<Song?> findById(int id) async {
    final row = await _db.findSongById(id);
    return row == null ? null : _toModel(row);
  }

  @override
  Future<void> insert(Song song) => _db.insertSong(
    SongsCompanion(
      title: Value(song.title),
      artist: Value(song.artist),
      filePath: Value(song.filePath),
      duration: Value(song.duration),
      imagePath: Value(song.imagePath),
      hasMetaData: Value(song.hasMetaData),
    ),
  );

  @override
  Future<void> delete(int id) => _db.deleteSong(id);

  Song _toModel(SongsData row) => Song(
    id: row.id,
    title: row.title,
    artist: row.artist,
    filePath: row.filePath,
    duration: row.duration,
    imagePath: row.imagePath,
    hasMetaData: row.hasMetaData,
  );
}