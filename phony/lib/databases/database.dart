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
  late final coverChecked = boolean().withDefault(const Constant(false))();
}

@DataClassName('SongFilesData')
class SongFiles extends Table {
  late final id = integer().autoIncrement()();
  late final path = text().unique()();
  late final name = text()();
  late final artist = text().nullable()();
  late final duration = integer()();
  late final checksum = text()();
  late final size = integer()();
  late final lastModified = dateTime()();
}

@DataClassName('PlaylistsData')
class Playlists extends Table {
  late final id = integer().autoIncrement()();
  late final name = text()();
}

@DataClassName('PlaylistEntriesData')
class PlaylistEntries extends Table {
  late final playlistId = integer().references(Playlists, #id)();
  late final songId = integer().references(Songs, #id)();
  late final position = integer()();

  @override
  Set<Column> get primaryKey => {playlistId, songId};
}

@DriftDatabase(tables: [Songs, SongFiles, Playlists, PlaylistEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(songs, songs.coverChecked);
      }
    },
  );

  ///
  /// Songs
  ///
  Stream<List<(SongsData, SongFilesData)>> watchAllSongs() =>
      (select(songs).join([
        innerJoin(songFiles, songFiles.id.equalsExp(songs.songFileId)),
      ])).watch().map(
        (rows) => rows
            .map((row) => (row.readTable(songs), row.readTable(songFiles)))
            .toList(),
      );

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

  Future<bool> deleteSong(int id) => transaction(() async {
    final SongsData? song = await (select(
      songs,
    )..where((s) => s.id.equals(id))).getSingleOrNull();

    if (song == null) return false;

    await (delete(playlistEntries)..where((e) => e.songId.equals(id))).go();
    await (delete(songs)..where((s) => s.id.equals(id))).go();
    await (delete(
      songFiles,
    )..where((sf) => sf.id.equals(song.songFileId))).go();

    return true;
  });

  Future<List<(SongsData, SongFilesData)>> getSongsNeedingCoverCheck() async {
    final query = select(songs).join([
      innerJoin(songFiles, songFiles.id.equalsExp(songs.songFileId)),
    ])..where(songs.imagePath.isNull() & songs.coverChecked.equals(false));

    final rows = await query.get();

    return rows
        .map((row) => (row.readTable(songs), row.readTable(songFiles)))
        .toList();
  }

  Future<void> setCoverArt(Map<int, String?> covers) async {
    await batch((b) {
      for (final MapEntry<int, String?> entry in covers.entries) {
        b.update(
          songs,
          SongsCompanion(
            imagePath: Value(entry.value),
            coverChecked: const Value(true),
          ),
          where: ($SongsTable s) => s.id.equals(entry.key),
        );
      }
    });
  }

  ///
  /// SongFiles
  ///
  Future<SongFilesData?> findSongFileById(int id) =>
      (select(songFiles)..where((sf) => sf.id.equals(id))).getSingleOrNull();

  Stream<List<SongFilesData>> watchAllSongFiles() => select(songFiles).watch();

  Future<int> insertSongFile(SongFilesCompanion songFile) =>
      into(songFiles).insert(songFile);

  Future<bool> deleteSongFile(int id) => (delete(
    songFiles,
  )..where((sf) => sf.id.equals(id))).go().then((n) => n > 0);

  Future<List<SongFilesData>> getAllSongFiles() => select(songFiles).get();

  Future<void> updateSongFilePath(int id, String path, String name) =>
      (update(songFiles)..where((sf) => sf.id.equals(id))).write(
        SongFilesCompanion(path: Value(path), name: Value(name)),
      );

  Future<int> insertScannedSong(SongFilesCompanion file, SongsCompanion song) =>
      transaction(() async {
        final int fileId = await into(songFiles).insert(file);
        return into(songs).insert(song.copyWith(songFileId: Value(fileId)));
      });

  ///
  /// Playlists
  ///
  Stream<List<(PlaylistsData, int)>> watchAllPlaylists() {
    final countExp = playlistEntries.songId.count();
    final query =
        select(playlists).join([
            leftOuterJoin(
              playlistEntries,
              playlistEntries.playlistId.equalsExp(playlists.id),
              useColumns: false,
            ),
          ])
          ..addColumns([countExp])
          ..groupBy([playlists.id]);

    return query.watch().map(
      (rows) => rows
          .map((row) => (row.readTable(playlists), row.read(countExp) ?? 0))
          .toList(),
    );
  }

  Stream<List<(SongsData, SongFilesData)>> watchPlayListSongs(int playlistId) =>
      (select(playlistEntries).join([
              innerJoin(songs, songs.id.equalsExp(playlistEntries.songId)),
              innerJoin(songFiles, songFiles.id.equalsExp(songs.songFileId)),
            ])
            ..where(playlistEntries.playlistId.equals(playlistId))
            ..orderBy([OrderingTerm.asc(playlistEntries.position)]))
          .watch()
          .map(
            (rows) => rows
                .map((row) => (row.readTable(songs), row.readTable(songFiles)))
                .toList(),
          );

  Future<int> insertPlaylist(PlaylistsCompanion playlist) =>
      into(playlists).insert(playlist);

  Future<bool> deletePlaylist(int id) => transaction(() async {
    await (delete(playlistEntries)..where((e) => e.playlistId.equals(id))).go();
    final int n = await (delete(playlists)..where((p) => p.id.equals(id))).go();
    return n > 0;
  });

  Future<int> addSongToPlaylist(PlaylistEntriesCompanion entry) =>
      into(playlistEntries).insert(entry, mode: .insertOrIgnore);

  Future<bool> removeSongFromPlaylist(int playlistId, int songId) =>
      (delete(playlistEntries)..where(
            (e) => e.playlistId.equals(playlistId) & e.songId.equals(songId),
          ))
          .go()
          .then((n) => n > 0);

  Future<void> renamePlaylist(int id, String name) =>
      (update(playlists)..where((p) => p.id.equals(id))).write(
        PlaylistsCompanion(name: Value(name)),
      );

  Stream<List<PlaylistEntriesData>> watchAllPlaylistEntries() =>
      select(playlistEntries).watch();

  ///
  /// Maintenance
  ///

  /// Deletes the whole db, should only be called by LibraryResetService.
  Future<void> resetDatabase() => transaction(() async {
    await delete(playlistEntries).go();
    await delete(playlists).go();
    await delete(songs).go();
    await delete(songFiles).go();
  });
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'phony_database.sqlite'));
    return NativeDatabase(file);
  });
}
