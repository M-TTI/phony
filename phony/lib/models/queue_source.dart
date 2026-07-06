import 'playlist.dart';

sealed class QueueSource {
  const QueueSource();
}

class LibraryQueueSource extends QueueSource {
  const LibraryQueueSource();
}

class PlaylistQueueSource extends QueueSource {
  const PlaylistQueueSource(this.playlist);

  final Playlist playlist;
}
