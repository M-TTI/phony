import 'package:flutter/material.dart';
import 'package:phony/viewmodels/song_viewmodel.dart';
import 'package:provider/provider.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SongViewmodel>();
    final songs = vm.songs; // used to create the LazyDatabase connection.
    return Column(
      children: [
        Center(child: Text(title)),
      ],
    );
  }
}