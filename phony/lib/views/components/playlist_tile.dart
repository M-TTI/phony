import 'package:flutter/material.dart';
import 'package:phony/models/playlist.dart';
import 'package:phony/repositories/playlist_repository.dart';
import 'package:phony/themes/theme.dart' as t;
import 'package:phony/viewmodels/playlist_detail_viewmodel.dart';
import 'package:phony/views/components/cover_art.dart';
import 'package:phony/views/components/playlist_context_menu.dart';
import 'package:phony/views/playlist_detail_view.dart';
import 'package:provider/provider.dart';

class PlaylistTile extends StatelessWidget {
  const PlaylistTile({super.key, required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => PlaylistDetailViewmodel(
              context.read<PlaylistRepository>(),
              playlist.id,
            ),
            child: PlaylistDetailView(playlist: playlist),
          ),
        ),
      ),
      overlayColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return t.inkHovered;
        if (states.contains(WidgetState.pressed)) return t.inkPressed;
        return Colors.transparent;
      }),
      mouseCursor: SystemMouseCursors.click,
      child: Stack(
        children: [
          SizedBox(
            height: 80,
            child: Row(
              children: [
                const SizedBox(width: 16),
                const CoverArt(size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: .center,
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        playlist.name,
                        style: const TextStyle(
                          color: t.onPrimary,
                          fontSize: 16,
                        ),
                        overflow: .ellipsis,
                      ),
                      Text(
                        '${playlist.songCount} songs',
                        style: const TextStyle(
                          color: t.onPrimaryMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const .only(right: 8, left: 4),
                  child: PlaylistContextMenu(playlist: playlist),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 80,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: 1,
              child: ColoredBox(color: t.backgroundMuted),
            ),
          ),
        ],
      ),
    );
  }
}
