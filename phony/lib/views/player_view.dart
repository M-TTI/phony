import 'package:flutter/material.dart';
import 'package:phony/models/song.dart';
import 'package:phony/themes/theme.dart' as t;
import 'package:phony/views/components/cover_art.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({
    super.key,
    this.song,
    required this.scrollController,
    required this.closeCommand,
  });

  final Song? song;
  final ScrollController scrollController;
  final closeCommand;

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  double? curent_song_time;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Container(
        height: MediaQuery.sizeOf(context).height,
        color: t.background,
        child: Padding(
          padding: const EdgeInsetsGeometry.all(12),
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width,
                height: 40,
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity! > 0) widget.closeCommand();
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_down),
                onPressed: () => widget.closeCommand(),
              ),
              Center(
                child: Column(
                  crossAxisAlignment: .center,
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
                    CoverArt(size: 256, imagePath: widget.song?.imagePath),
                    Slider(
                      value: curent_song_time ?? 0,
                      onChangeEnd: (_) {}, // TODO: Wire it up to viewmodel
                      onChanged: (value) {
                        setState(() {
                          curent_song_time = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
