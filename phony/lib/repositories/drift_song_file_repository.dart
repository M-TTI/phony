import 'package:drift/drift.dart';
import 'package:phony/databases/database.dart';
import 'package:phony/models/song_file.dart';
import 'package:phony/repositories/song_file_repository.dart';

class DriftSongFileRepository implements SongFileRepository{
  final AppDatabase _db;

  DriftSongFileRepository(this._db);

  @override
  Future<SongFile?> findById(int id) async {
    final row = await _db.findSongFileById(id);
    return row == null ? null : _toModel(row);
  }

  @override
  Stream<List<SongFile>> watchAll() =>
      _db.watchAllSongFiles()
      .map((rows) => rows.map(_toModel).toList());

  @override
  Future<void> insert(SongFile songFile) =>
    _db.insertSongFile(
      SongFilesCompanion(
        name: Value(songFile.name),
        path: Value(songFile.path),
        artist: Value(songFile.artist),
        duration: Value(songFile.duration),
        checksum: Value(songFile.checksum),
      ),
    );

  @override
  Future<void> delete(int id) => _db.deleteSongFile(id);

  SongFile _toModel(SongFilesData row) => SongFile(
    id: row.id,
    name: row.name,
    path: row.path,
    artist: row.artist,
    duration: row.duration,
    checksum: row.checksum,
  );
}