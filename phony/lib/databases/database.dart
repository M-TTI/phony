import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DataClassName('SongsData')
class Songs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get filePath => text()();
  IntColumn get duration => integer()();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get hasMetaData => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Songs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<SongsData>> watchAllSongs() => select(songs).watch();

  Future<SongsData?> findSongById(int id) => (select(songs)
    ..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<int> insertSong(SongsCompanion song) => into(songs).insert(song);

  Future<bool> deleteSong(int id) =>
      (delete(songs)..where((s) => s.id.equals(id))).go().then((n) => n > 0);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'phony_database.sqlite'));
    return NativeDatabase(file);
  });
}