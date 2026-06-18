import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// Tables

@DataClassName('SongsData')
class Songs extends Table {
  late final id = integer().autoIncrement()();
  late final title = text()();
  late final artist = text().nullable()();
  late final songFileId = integer().unique().references(SongFiles, #id)();
  late final duration = integer()();
  late final imagePath = text().nullable()();
  late final hasMetaData = boolean().withDefault(const Constant(false))();
}

@DataClassName('SongFilesData')
class SongFiles extends Table {
  late final id = integer().autoIncrement()();
  late final path = text()();
  late final name = text()();
  late final artist = text().nullable()();
  late final duration = integer()();
  late final checksum = text()();
}

@DriftDatabase(tables: [Songs, SongFiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  ///
  /// Songs
  ///
  Stream<List<(SongsData, SongFilesData)>> watchAllSongs() =>
      (select(songs).join([
        innerJoin(songFiles, songFiles.id.equalsExp(songs.songFileId)),
      ])).watch().map((rows) => rows.map((row) => (
        row.readTable(songs),
        row.readTable(songFiles),
      )).toList());

  Future<(SongsData, SongFilesData)?> findSongById(int id) async {
    final query = select(songs).join([
      innerJoin(songFiles, songFiles.id.equalsExp(songs.songFileId)),
    ])..where(songs.id.equals(id));

    final row = await query.getSingleOrNull();
    return row == null
        ? null
        : (row.readTable(songs), row.readTable(songFiles));
  }

  Future<int> insertSong(SongsCompanion song) => into(songs).insert(song);

  Future<bool> deleteSong(int id) =>
      (delete(songs)..where((s) => s.id.equals(id))).go().then((n) => n > 0);

  ///
  /// SongFiles
  ///
  Future<SongFilesData?> findSongFileById(int id) => (select(songFiles)
    ..where((sf) => sf.id.equals(id))).getSingleOrNull();

  Stream<List<SongFilesData>> watchAllSongFiles() => select(songFiles).watch();
  
  Future<int> insertSongFile(SongFilesCompanion songFile) => into(songFiles).insert(songFile);

  Future<bool> deleteSongFile(int id) =>
      (delete(songFiles)..where((sf) => sf.id.equals(id))).go().then((n) => n > 0);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'phony_database.sqlite'));
    return NativeDatabase(file);
  });
}