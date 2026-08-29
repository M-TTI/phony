import 'package:flutter/material.dart';
import 'package:phony/models/song.dart';
import 'package:phony/themes/theme.dart' as t;
import 'package:phony/viewmodels/player_viewmodel.dart';
import 'package:provider/provider.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key, required this.openCommand});

  final GestureTapCallback openCommand;

  @override
  Widget build(BuildContext context) {
    final playerVm = context.read<PlayerViewmodel>();
    final watchedPlayerVm = context.watch<PlayerViewmodel>();
    final Song? song = watchedPlayerVm.currentSong;
    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: openCommand,
      child: Container(
        color: t.backgroundMuted,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: watchedPlayerVm.duration.inMilliseconds == 0
                  ? 0.0
                  : (watchedPlayerVm.position.inMilliseconds /
                            watchedPlayerVm.duration.inMilliseconds)
                        .clamp(0.0, 1.0),
              minHeight: 3,
              backgroundColor: t.background,
              valueColor: const AlwaysStoppedAnimation<Color>(t.primary),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(child: Text(song.title, overflow: .ellipsis)),
                IconButton(
                  onPressed: () => playerVm.togglePlay(),
                  icon: Icon(
                    watchedPlayerVm.isPlaying ? t.pauseIcon : t.playIcon,
                    color: t.onPrimary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const Padding(padding: .only(bottom: 4)),
          ],
        ),
      ),
    );
  }
}
