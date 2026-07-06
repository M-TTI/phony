import 'package:flutter/material.dart';
import 'package:phony/models/queue_source.dart';
import 'package:phony/viewmodels/song_viewmodel.dart';
import 'package:phony/views/components/song_tile.dart';
import 'package:provider/provider.dart';

class SongsView extends StatelessWidget {
  const SongsView({super.key});

  @override
  Widget build(BuildContext context) {
    final songs = context.watch<SongViewmodel>().songs;

    if (songs.isEmpty) {
      return const Center(child: Text('No songs yet'));
    }

    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) => SongTile(
        song: songs[index],
        queue: songs,
        index: index,
        source: const LibraryQueueSource(),
      ),
    );
  }
}
