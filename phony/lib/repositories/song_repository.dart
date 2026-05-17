import 'package:phony/models/song.dart';

abstract class SongRepository {
  Stream<List<Song>> watchAll();
  Future<Song?> findById(int id);
  Future<void> insert(Song song);
  Future<void> delete(int id);
}