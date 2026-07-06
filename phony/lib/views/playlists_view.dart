import 'package:flutter/material.dart';
import 'package:phony/viewmodels/playlist_viewmodel.dart';
import 'package:phony/views/components/playlist_tile.dart';
import 'package:provider/provider.dart';

class PlaylistsView extends StatelessWidget {
  const PlaylistsView({super.key});

  @override
  Widget build(BuildContext context) {
    final playlists = context.watch<PlaylistViewmodel>().playlists;

    if (playlists.isEmpty) {
      return const Center(child: Text('No playlists yet'));
    }

    return ListView.builder(
      itemCount: playlists.length,
      itemBuilder: (context, index) => PlaylistTile(playlist: playlists[index]),
    );
  }
}
