class SongMetadata {
  final String title;
  final String? artist;
  final String? album;
  final int duration;
  final String filePath;
  final List<int>? pictureBytes;

  SongMetadata({
    required this.title,
    this.artist,
    this.album,
    required this.duration,
    required this.filePath,
    this.pictureBytes,
  });
}