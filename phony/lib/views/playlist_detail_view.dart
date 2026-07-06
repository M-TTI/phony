import 'package:flutter/material.dart';
import 'package:phony/models/playlist.dart';
import 'package:phony/models/queue_source.dart';
import 'package:phony/repositories/playlist_repository.dart';
import 'package:phony/themes/theme.dart' as t;
import 'package:phony/viewmodels/playlist_detail_viewmodel.dart';
import 'package:phony/views/components/song_tile.dart';
import 'package:provider/provider.dart';

class PlaylistDetailView extends StatelessWidget {
  const PlaylistDetailView({super.key, required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    final songs = context.watch<PlaylistDetailViewmodel>().songs;

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        leading: const BackButton(color: t.onPrimary),
        title: Text(playlist.name, overflow: .ellipsis),
        backgroundColor: t.primary,
        shadowColor: t.shadow,
        elevation: 8,
      ),
      body: songs.isEmpty
          ? const Center(child: Text('No songs in this playlist'))
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) => SongTile(
                song: songs[index],
                queue: songs,
                index: index,
                source: PlaylistQueueSource(playlist),
              ),
            ),
    );
  }

  static Route<void> route(Playlist playlist) => MaterialPageRoute(
    builder: (BuildContext context) => ChangeNotifierProvider(
      create: (BuildContext context) => PlaylistDetailViewmodel(
        context.read<PlaylistRepository>(),
        playlist.id,
      ),
      child: PlaylistDetailView(playlist: playlist),
    ),
  );
}
