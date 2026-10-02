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
      titleUnicode: Value(song.titleUnicode),
      artist: Value(song.artist),
      artistUnicode: Value(song.artistUnicode),
      songFileId: Value(song.file.id),
      duration: Value(song.duration),
      imagePath: Value(song.imagePath),
      hasMetaData: Value(song.hasMetaData),
      isFromOsz: Value(song.isFromOsz),
    ),
  );

  @override
  Future<void> delete(int id) => _db.deleteSong(id);

  @override
  Future<void> insertScanned(Song song, {bool coverChecked = false}) async {
    final SongsCompanion songCompanion = SongsCompanion(
      title: Value(song.title),
      titleUnicode: Value(song.titleUnicode),
      artist: Value(song.artist),
      artistUnicode: Value(song.artistUnicode),
      duration: Value(song.duration),
      hasMetaData: Value(song.hasMetaData),
      imagePath: Value(song.imagePath),
      isFromOsz: Value(song.isFromOsz),
      coverChecked: Value(coverChecked),
    );

    final SongFile file = song.file;

    final SongFilesCompanion songFilesCompanion = SongFilesCompanion(
      path: Value(file.path),
      name: Value(file.name),
      artist: Value(file.artist),
      duration: Value(file.duration),
      checksum: Value(file.checksum),
      size: Value(file.size),
    );

    await _db.insertScannedSong(songFilesCompanion, songCompanion);
  }

  @override
  Future<List<Song>> getSongsNeedingCoverCheck() async {
    final rows = await _db.getSongsNeedingCoverCheck();
    return rows.map((r) => _toModel(r.$1, r.$2)).toList();
  }

  @override
  Future<void> setCoverArt(Map<int, String?> covers) => _db.setCoverArt(covers);

  Song _toModel(SongsData song, SongFilesData file) => Song(
    id: song.id,
    title: song.title,
    titleUnicode: song.titleUnicode,
    artist: song.artist,
    artistUnicode: song.artistUnicode,
    file: SongFile(
      id: file.id,
      name: file.name,
      path: file.path,
      artist: file.artist,
      duration: file.duration,
      checksum: file.checksum,
      size: file.size,
      createdAt: file.createdAt,
      updatedAt: file.updatedAt,
    ),
    duration: song.duration,
    imagePath: song.imagePath,
    hasMetaData: song.hasMetaData,
    isFromOsz: song.isFromOsz,
    createdAt: song.createdAt,
    updatedAt: song.updatedAt,
  );
}
