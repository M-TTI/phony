class SongFile {
  final int id;
  final String path;
  final String name;
  final String? artist;
  final int duration;
  final String checksum;
  final int size;
  final DateTime lastModified;

  const SongFile({
    required this.id,
    required this.path,
    required this.name,
    this.artist,
    required this.duration,
    required this.checksum,
    required this.size,
    required this.lastModified,
  });
}
