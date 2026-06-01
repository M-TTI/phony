import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phony/models/song.dart';
import 'package:phony/themes/theme.dart' as t;

class SongCard extends StatelessWidget {
  const SongCard({super.key, required this.song});

  final Song song;

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;

    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        SizedBox(
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 16),
              _coverArt(),
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
                      song.artist ?? 'Unknown artist',
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
                    padding: EdgeInsets.only(right: 12, left: 4),
                    child: IconButton(
                      onPressed: () => {},
                      icon: Icon(Icons.more_vert_rounded, color: t.onPrimary, size: 24),
                    ),
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
          child: SizedBox(height: 1, child: ColoredBox(color: t.backgroundMuted)),
        ),
      ],
    );
  }

  Widget _coverArt() {
    final BorderRadius radius = BorderRadius.circular(4);
    final Widget placeholder = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: t.backgroundMuted, borderRadius: radius),
    );

    if (song.imagePath == null) return placeholder;

    return ClipRRect(
      borderRadius: radius,
      child: Image.file(
        File(song.imagePath!),
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}