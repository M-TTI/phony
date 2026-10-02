class Playlist {
  final int id;
  final String name;
  final int songCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Playlist({
    required this.id,
    required this.name,
    required this.songCount,
    required this.createdAt,
    required this.updatedAt,
  });
}
