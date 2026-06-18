class SongFile {
  final int id;
  final String path;
  final String name;
  final String? artist;
  final int duration;
  final String checksum;

  const SongFile({
    required this.id,
    required this.path,
    required this.name,
    this.artist,
    required this.duration,
    required this.checksum,
  });
}