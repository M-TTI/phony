import 'package:drift/drift.dart';
import 'package:phony/databases/database.dart';
import 'package:phony/models/song.dart';
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
  Stream<List<Song>> watchAll() => _db.watchAllSongs().map(
    (rows) => rows.map((r) => _toModel(r.$1, r.$2)).toList(),
  );

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

  @override
  Future<void> insertScanned(Song song) async {
    final SongsCompanion songCompanion = SongsCompanion(
      title: Value(song.title),
      artist: Value(song.artist),
      duration: Value(song.duration),
      hasMetaData: Value(song.hasMetaData),
      imagePath: Value(song.imagePath),
    );

    final SongFile file = song.file;

    final SongFilesCompanion songFilesCompanion = SongFilesCompanion(
      path: Value(file.path),
      name: Value(file.name),
      artist: Value(file.artist),
      duration: Value(file.duration),
      checksum: Value(file.checksum),
      size: Value(file.size),
      lastModified: Value(file.lastModified),
    );

    await _db.insertScannedSong(songFilesCompanion, songCompanion);
  }

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
      size: file.size,
      lastModified: file.lastModified,
    ),
    duration: song.duration,
    imagePath: song.imagePath,
    hasMetaData: song.hasMetaData,
  );
}
