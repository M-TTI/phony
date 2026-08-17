import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phony/models/queue_source.dart';
import 'package:phony/models/song.dart';
import 'package:phony/themes/theme.dart' as t;
import 'package:phony/viewmodels/player_viewmodel.dart';
import 'package:phony/views/components/cover_art.dart';
import 'package:provider/provider.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({
    super.key,
    required this.scrollController,
    required this.closeCommand,
    required this.onSourceTap,
  });

  final ScrollController scrollController;
  final VoidCallback closeCommand;
  final void Function(QueueSource) onSourceTap;

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  double? _dragValue;
  double? _hoverValue;
  double? _hoverDx;

  String _formatDuration(double seconds) {
    final int total = seconds.round();
    final String m = (total ~/ 60).toString();
    final String s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final playerVm = context.watch<PlayerViewmodel>();
    final Song? song = playerVm.currentSong;

    final double maxSeconds = playerVm.duration.inSeconds.toDouble();
    final double sliderMax = maxSeconds > 0 ? maxSeconds : 1.0;
    final double sliderValue =
        (_dragValue ?? playerVm.position.inSeconds.toDouble()).clamp(
          0.0,
          sliderMax,
        );

    final String? artist = song?.artist;
    final String artistLabel = (artist == null || artist.isEmpty)
        ? '-'
        : artist;

    final QueueSource? source = playerVm.source;
    final String? sourceLabel = switch (source) {
      null => null,
      LibraryQueueSource() => 'Library',
      PlaylistQueueSource(:final playlist) => playlist.name,
    };

    return Material(
      color: t.backgroundDark,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double coverSize = math
                .min(constraints.maxWidth * 0.8, constraints.maxHeight * 0.45)
                .clamp(140.0, 360.0);

            return CustomScrollView(
              controller: widget.scrollController,
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Stack(
                          alignment: .center,
                          children: [
                            Align(
                              alignment: .centerLeft,
                              child: IconButton(
                                icon: const Icon(t.arrowDownIcon),
                                onPressed: widget.closeCommand,
                              ),
                            ),
                            if (source != null)
                              InkWell(
                                onTap: () => widget.onSourceTap(source),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  child: Column(
                                    mainAxisSize: .min,
                                    children: [
                                      const Text(
                                        'PLAYING FROM',
                                        style: TextStyle(
                                          fontSize: 10,
                                          letterSpacing: 1.5,
                                          color: t.onPrimaryMuted,
                                        ),
                                      ),
                                      Text(
                                        sourceLabel!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: .w600,
                                          color: t.onPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: .ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 480),
                              child: Column(
                                children: [
                                  const Spacer(),
                                  CoverArt(
                                    size: coverSize,
                                    imagePath: song?.imagePath,
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    song?.title ?? '-',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: .bold,
                                      color: t.onPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: .ellipsis,
                                  ),
                                  Text(
                                    artistLabel,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: t.onPrimaryMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: .ellipsis,
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Text(
                                        _formatDuration(sliderValue),
                                        style: const TextStyle(
                                          color: t.onPrimaryMuted,
                                        ),
                                      ),
                                      Expanded(
                                        child: Builder(
                                          builder: (sliderContext) {
                                            return Stack(
                                              clipBehavior: .none,
                                              children: [
                                                MouseRegion(
                                                  onHover: (event) {
                                                    final Size? size =
                                                        sliderContext.size;
                                                    if (size == null) return;
                                                    const double inset = 24.0;
                                                    final double fraction =
                                                        ((event.localPosition.dx -
                                                                    inset) /
                                                                (size.width -
                                                                    2 * inset))
                                                            .clamp(0.0, 1.0);
                                                    setState(() {
                                                      _hoverValue =
                                                          fraction * sliderMax;
                                                      _hoverDx = event
                                                          .localPosition
                                                          .dx
                                                          .clamp(
                                                            inset,
                                                            size.width - inset,
                                                          );
                                                    });
                                                  },
                                                  onExit: (event) => setState(
                                                    () => _hoverValue = null,
                                                  ),
                                                  child: Slider(
                                                    value: sliderValue,
                                                    max: sliderMax,
                                                    activeColor: t.primary,
                                                    onChanged: (double value) =>
                                                        setState(
                                                          () => _dragValue =
                                                              value,
                                                        ),
                                                    onChangeEnd:
                                                        (double value) {
                                                          context
                                                              .read<
                                                                PlayerViewmodel
                                                              >()
                                                              .seek(
                                                                Duration(
                                                                  seconds: value
                                                                      .round(),
                                                                ),
                                                              );
                                                          setState(
                                                            () => _dragValue =
                                                                null,
                                                          );
                                                        },
                                                    secondaryTrackValue:
                                                        _dragValue == null
                                                        ? _hoverValue?.clamp(
                                                            0.0,
                                                            sliderMax,
                                                          )
                                                        : null,
                                                    secondaryActiveColor:
                                                        t.backgroundMuted,
                                                  ),
                                                ),
                                                if (_hoverValue != null &&
                                                    _hoverDx != null &&
                                                    _dragValue == null)
                                                  Positioned(
                                                    left: _hoverDx,
                                                    bottom: 36,
                                                    child: FractionalTranslation(
                                                      translation: const Offset(
                                                        -0.5,
                                                        0,
                                                      ),
                                                      child: IgnorePointer(
                                                        child: Container(
                                                          padding:
                                                              const .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                          decoration:
                                                              BoxDecoration(
                                                                color: t
                                                                    .background,
                                                                borderRadius:
                                                                    .circular(
                                                                      4,
                                                                    ),
                                                              ),
                                                          child: Text(
                                                            _formatDuration(
                                                              _hoverValue!,
                                                            ),
                                                            style: const TextStyle(
                                                              color: t
                                                                  .onPrimaryMuted,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      Text(
                                        _formatDuration(maxSeconds),
                                        style: const TextStyle(
                                          color: t.onPrimaryMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  FittedBox(
                                    fit: .scaleDown,
                                    child: Row(
                                      mainAxisSize: .min,
                                      children: [
                                        IconButton(
                                          iconSize: 24,
                                          color: t.onPrimaryMuted,
                                          icon: Icon(
                                            t.shuffleIcon,
                                            color: playerVm.shuffleEnabled
                                                ? t.primary
                                                : t.onPrimaryMuted,
                                          ),
                                          onPressed: () =>
                                              playerVm.toggleShuffle(),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          iconSize: 40,
                                          color: t.onPrimary,
                                          icon: const Icon(t.previousIcon),
                                          onPressed: () => playerVm.previous(),
                                        ),
                                        const SizedBox(width: 8),
                                        Stack(
                                          alignment: .center,
                                          children: [
                                            const Icon(
                                              Icons.circle,
                                              color: t.onPrimary,
                                              size: 60,
                                            ),
                                            IconButton(
                                              iconSize: 64,
                                              color: t.primary,
                                              icon: Icon(
                                                playerVm.isPlaying
                                                    ? t.pauseCircleIcon
                                                    : t.playCircleIcon,
                                              ),
                                              onPressed: () =>
                                                  playerVm.togglePlay(),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          iconSize: 40,
                                          color: t.onPrimary,
                                          icon: const Icon(t.skipIcon),
                                          onPressed: () => playerVm.next(),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          iconSize: 24,
                                          color: t.onPrimaryMuted,
                                          icon: switch (playerVm.repeatMode) {
                                            .none => const Icon(
                                              t.repeatIcon,
                                              color: t.onPrimaryMuted,
                                            ),
                                            .all => const Icon(
                                              t.repeatIcon,
                                              color: t.primary,
                                            ),
                                            .one => const Icon(
                                              t.repeatOneIcon,
                                              color: t.primary,
                                            ),
                                          },
                                          onPressed: () =>
                                              playerVm.toggleRepeat(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (Platform.isLinux ||
                                      Platform.isWindows ||
                                      Platform.isMacOS)
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 220,
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              playerVm.volume == 0 ||
                                                      playerVm.isMuted
                                                  ? t.volumeOffIcon
                                                  : playerVm.volume < 50
                                                  ? t.volumeDownIcon
                                                  : t.volumeUpIcon,
                                            ),
                                            iconSize: 20,
                                            visualDensity: .compact,
                                            color: t.onPrimaryMuted,
                                            onPressed: () => context
                                                .read<PlayerViewmodel>()
                                                .toggleMute(),
                                          ),
                                          Expanded(
                                            child: Slider(
                                              padding: const .symmetric(
                                                horizontal: 4,
                                              ),
                                              value: playerVm.isMuted
                                                  ? 0.0
                                                  : playerVm.volume,
                                              max: 100,
                                              activeColor: t.onPrimaryMuted,
                                              onChanged: (double value) =>
                                                  context
                                                      .read<PlayerViewmodel>()
                                                      .setVolume(value),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
