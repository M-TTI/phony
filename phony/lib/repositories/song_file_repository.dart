import 'package:phony/models/song_file.dart';

abstract class SongFileRepository {
  Future<SongFile?> findById(int id);

  Stream<List<SongFile>> watchAll();

  Future<void> insert(SongFile songFile);

  Future<void> delete(int id);

  Future<List<SongFile>> getAll();

  Future<void> updatePath(int id, String path, String name);
}
