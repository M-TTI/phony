import 'package:flutter/material.dart';
import 'package:phony/models/playlist.dart';
import 'package:phony/models/song.dart';
import 'package:phony/themes/theme.dart' as t;
import 'package:phony/viewmodels/playlist_viewmodel.dart';
import 'package:phony/viewmodels/song_viewmodel.dart';
import 'package:provider/provider.dart';

class SongContextMenu extends StatelessWidget {
  const SongContextMenu({super.key, required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final PlaylistViewmodel playlistVm = context.read<PlaylistViewmodel>();
    final PlaylistViewmodel watchedPlaylistVm = context
        .watch<PlaylistViewmodel>();

    final playlists = watchedPlaylistVm.playlists;
    final containing = watchedPlaylistVm.playlistsContaining(song.id);

    return MenuAnchor(
      builder: (context, controller, child) => IconButton(
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        padding: .zero,
        constraints: const BoxConstraints(),
        visualDensity: .compact,
        icon: const Icon(t.moreIcon, color: t.onPrimary, size: 24),
      ),
      menuChildren: [
        SubmenuButton(
          leadingIcon: Icon(t.addIcon, size: 20),
          menuChildren: [
            if (playlists.isEmpty)
              const MenuItemButton(
                onPressed: null,
                child: Text('No playlists'),
              ),
            for (final playlist in playlists)
              MenuItemButton(
                leadingIcon: containing.contains(playlist.id)
                    ? const Icon(t.checkIcon, size: 20, color: t.primary)
                    : const SizedBox(width: 20),
                onPressed: () {
                  containing.contains(playlist.id)
                      ? _confirmRemove(context, playlist)
                      : playlistVm.addSong(playlist.id, song.id);
                },
                child: Text(
                  playlist.name,
                  style: TextStyle(
                    color: containing.contains(playlist.id) ? t.primary : null,
                  ),
                  overflow: .ellipsis,
                ),
              ),
          ],
          child: const Text('Add to playlist'),
        ),
        // MenuItemButton(
        //   leadingIcon: Icon(t.playIcon, size: 20),
        //   onPressed: () => {},
        //   child: const Text('Play next'),
        // ),
        MenuItemButton(
          leadingIcon: Icon(t.trashIcon, size: 20),
          onPressed: () => _confirmDelete(context),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  Future<void> _confirmRemove(BuildContext context, Playlist playlist) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Remove "${song.title}" from "${playlist.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<PlaylistViewmodel>().removeSong(playlist.id, song.id);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete "${song.title}"?'),
        content: const Text('This removes the song from your library.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<SongViewmodel>().delete(song.id);
    }
  }
}
