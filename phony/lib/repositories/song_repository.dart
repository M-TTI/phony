import 'package:phony/models/song.dart';

abstract class SongRepository {
  Future<Song?> findById(int id);

  Stream<List<Song>> watchAll();

  Future<void> insert(Song song);

  Future<void> delete(int id);

  Future<void> insertScanned(Song song, {bool coverChecked = false});

  Future<List<Song>> getSongsNeedingCoverCheck();

  Future<void> setCoverArt(Map<int, String?> covers);
}
