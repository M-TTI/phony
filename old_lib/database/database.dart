import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Songs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get duration => integer()();
  TextColumn get filePath => text()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get fileChecksum => text().nullable()();
  BoolColumn get hasCustomMetadata => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Songs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<int> insertSong(SongsCompanion song) async {
    return into(songs)
        .insert(song);
  }

  Future<List<Song>> findAllSongs() async {
    return select(songs)
        .get();
  }

  Future<Song?> findSongById(int id) async {
    return (select(songs)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  Future<Song?> findSongByChecksum(String checksum) async {
    return (select(songs)..where((s) => s.fileChecksum.equals(checksum)))
        .getSingleOrNull();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database.sqlite'));
    return NativeDatabase(file);
  });
}