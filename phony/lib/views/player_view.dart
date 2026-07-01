import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phony/models/song.dart';
import 'package:phony/themes/theme.dart' as t;
import 'package:phony/views/components/cover_art.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({
    super.key,
    this.song,
    required this.scrollController,
    required this.closeCommand,
  });

  final Song? song;
  final ScrollController scrollController;
  final VoidCallback closeCommand;

  String _formatDuration(double seconds) {
    final int total = seconds.round();
    final String m = (total ~/ 60).toString();
    final String s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    // TODO: final vm = context.watch<PlayerViewModel>();
    const double position = 0.4; // TODO: vm.position
    final double duration = (song?.duration ?? 0).toDouble();

    return Container(
      color: t.backgroundDark,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Scale the cover art to the available space rather than a fixed
          // size, so it works on narrow phones and wide desktop windows alike.
          final double coverSize = math
              .min(constraints.maxWidth * 0.8, constraints.maxHeight * 0.45)
              .clamp(140.0, 360.0);

          return SingleChildScrollView(
            controller: scrollController,
            child: ConstrainedBox(
              // Fill the viewport so the Spacers can distribute space, but
              // still allow scrolling if the sheet is shorter than the content.
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    // Cap the width so the layout stays readable on desktop.
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          children: [
                          Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down),
                            onPressed: closeCommand,
                          ),
                        ),
                        const Spacer(),
                        CoverArt(size: coverSize, imagePath: song?.imagePath),
                        const SizedBox(height: 32),
                        Text(
                          song?.title ?? '-',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: t.onPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (song?.artist != null && song!.artist!.isNotEmpty)
                    Text(
                    song!.artist!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: t.onPrimaryMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(color: t.onPrimaryMuted),
                      ),
                      Expanded(
                        child: Slider(
                          value: position,
                          max: 1, // TODO: duration,
                          activeColor: t.primary,
                          onChanged: (double value) {},
                          // TODO: vm.seek(value)
                        ),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(color: t.onPrimaryMuted),
                      ),
                    ],
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          iconSize: 24,
                          color: t.onPrimaryMuted,
                          icon: const Icon(Icons.shuffle_rounded),
                          onPressed: () {}, // TODO: vm.toggleShuffle()
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          iconSize: 40,
                          color: t.onPrimary,
                          icon: const Icon(Icons.skip_previous_rounded),
                          onPressed: () {}, // TODO: vm.previous()
                        ),
                        const SizedBox(width: 8),
                        Stack(
                          alignment: AlignmentGeometry.center,
                          children: [
                            Icon(
                              Icons.circle,
                              color: t.onPrimary,
                              size: 60,
                            ),
                            IconButton(
                              iconSize: 64,
                              color: t.primary,
                              // TODO: swap with pause based on vm.isPlaying
                              icon: const Icon(
                                Icons.play_circle_fill_rounded,
                              ),
                              onPressed: () {}, // TODO: vm.togglePlay()
                            ),
                          ],
                        ),
                        IconButton(
                          iconSize: 40,
                          color: t.onPrimary,
                          icon: const Icon(Icons.skip_next_rounded),
                          onPressed: () {}, // TODO: vm.next()
                        ),
                        IconButton(
                          iconSize: 24,
                          color: t.onPrimaryMuted,
                          icon: const Icon(Icons.repeat_rounded),
                          onPressed: () {}, // TODO: vm.toggleRepeat()
                        ),
                      ],
                    ),
                    const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),)
          ,
          );
        },
      ),
    );
  }
}
