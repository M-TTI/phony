import 'package:flutter/material.dart';
import 'package:phony/viewmodels/song_viewmodel.dart';
import 'package:phony/views/components/mini_player.dart';
import 'package:phony/views/components/top_bar.dart';
import 'package:provider/provider.dart';
import 'package:phony/themes/theme.dart' as t;

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SongViewmodel>();
    final songs = vm.songs; // used to create the LazyDatabase connection.

    return SafeArea(
        child: Material(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Column(
              children: [
                TopBar(title: title),
                Expanded(
                  child: Container(
                    color: t.background,
                    child: Center(
                      child: Text('There shall be songs'),
                    ),
                  ),
                ),
                Column(
                  children: [
                    MiniPlayer(),
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