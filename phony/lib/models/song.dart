class Song {
  final int id;
  final String title;
  final String? artist;
  final String filePath;
  final int duration; // seconds
  final String? imagePath;

  const Song({
    required this.id,
    required this.title,
    this.artist,
    required this.filePath
  });
}