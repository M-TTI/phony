import 'package:flutter/material.dart';
import 'package:phony/models/queue_source.dart';
import 'package:phony/viewmodels/song_viewmodel.dart';
import 'package:phony/views/components/song_tile.dart';
import 'package:provider/provider.dart';

class SongsView extends StatelessWidget {
  const SongsView({super.key});

  @override
  Widget build(BuildContext context) {
    final songVm = context.watch<SongViewmodel>();
    final filteredSongs = songVm.filteredSongs;

    if (songVm.songs.isEmpty) {
      return const Center(child: Text('No songs yet'));
    }

    if (filteredSongs.isEmpty) {
      return const Center(child: Text('No results'));
    }

    return ListView.builder(
      itemCount: filteredSongs.length,
      itemBuilder: (context, index) => SongTile(
        song: filteredSongs[index],
        queue: filteredSongs,
        index: index,
        source: const LibraryQueueSource(),
      ),
    );
  }
}
