import 'package:flutter/material.dart';
import 'package:phony/models/queue_source.dart';
import 'package:phony/models/song.dart';
import 'package:phony/themes/theme.dart' as t;
import 'package:phony/viewmodels/player_viewmodel.dart';
import 'package:phony/views/components/cover_art.dart';
import 'package:phony/views/components/song_context_menu.dart';
import 'package:provider/provider.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.queue,
    required this.index,
    required this.source,
  });

  final Song song;
  final List<Song> queue;
  final int index;
  final QueueSource source;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          context.read<PlayerViewmodel>().playQueue(queue, index, source),
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
                CoverArt(size: 48, imagePath: song.imagePath),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: t.onPrimary,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song.artist ?? '-',
                        style: const TextStyle(
                          color: t.onPrimaryMuted,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _formatDuration(song.duration),
                      style: const TextStyle(
                        color: t.onPrimaryMuted,
                        fontSize: 12,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8, left: 4),
                      child: SongContextMenu(song: song),
                    ),
                  ],
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

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;

    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
