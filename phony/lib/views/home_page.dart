import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:phony/themes/theme.dart' as t;
import 'package:phony/views/components/mini_player.dart';
import 'package:phony/views/components/top_bar.dart';
import 'package:phony/views/player_view.dart';
import 'package:phony/views/songs_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DraggableScrollableController _playerSheetController =
      DraggableScrollableController();

  @override
  void dispose() {
    _playerSheetController.dispose();
    super.dispose();
  }

  Future<void> openPlayerView() => _playerSheetController.animateTo(
    1.0,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );

  Future<void> closePlayerView() => _playerSheetController.animateTo(
    0.0,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: t.background,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Column(
              children: [
                TopBar(title: widget.title),
                Expanded(child: const SongsView()),
                Column(
                  children: [
                    MiniPlayer(openCommand: openPlayerView),
                    Container(color: t.primary, padding: EdgeInsets.all(4)),
                  ],
                ),
              ],
            ),
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
              ),
              child: DraggableScrollableSheet(
                controller: _playerSheetController,
                initialChildSize: 0.0,
                minChildSize: 0.0,
                maxChildSize: 1.0,
                snap: true,
                snapSizes: [0.0, 1.0],
                builder: (context, scrollController) => PlayerView(
                  scrollController: scrollController,
                  closeCommand: closePlayerView,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
