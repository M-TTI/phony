import 'package:phony/models/song_file.dart';

class Song {
  final int id;
  final String title;
  final String? artist;
  final SongFile file;
  final int duration; // seconds
  final String? imagePath;
  final bool hasMetaData;

  const Song({
    required this.id,
    required this.title,
    this.artist,
    required this.file,
    required this.duration,
    this.imagePath,
    required this.hasMetaData,
  });
}