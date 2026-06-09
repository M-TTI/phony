import 'package:flutter/material.dart';
import 'package:phony/views/components/mini_player.dart';
import 'package:phony/views/components/top_bar.dart';
import 'package:phony/views/songs_view.dart';
import 'package:phony/themes/theme.dart' as t;

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});
  final String title;

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
                TopBar(title: title),
                Expanded(
                  child: const SongsView(),
                ),
                Column(
                  children: [
                    const MiniPlayer(),
                    Container(
                      color: t.primary,
                      padding: EdgeInsets.all(4),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}