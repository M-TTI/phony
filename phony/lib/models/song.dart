import 'package:phony/models/song_file.dart';

class Song {
  final int id;
  final String title;
  final String? titleUnicode;
  final String? artist;
  final String? artistUnicode;
  final SongFile file;
  final int duration; // seconds
  final String? imagePath;
  final bool hasMetaData;
  final bool isFromOsz;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Song({
    required this.id,
    required this.title,
    this.titleUnicode,
    this.artist,
    this.artistUnicode,
    required this.file,
    required this.duration,
    this.imagePath,
    required this.hasMetaData,
    required this.isFromOsz,
    required this.createdAt,
    required this.updatedAt,
  });

  String get titleLabel => titleUnicode ?? title;

  String? get artistLabel => artistUnicode ?? artist;
}
