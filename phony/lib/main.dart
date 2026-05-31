import 'package:flutter/material.dart';
import 'package:phony/databases/database.dart';
import 'package:phony/repositories/drift_song_repository.dart';
import 'package:phony/viewmodels/song_viewmodel.dart';
import 'package:phony/views/home_page.dart';
import 'package:provider/provider.dart';
import 'package:phony/themes/theme.dart' as t;

void main() {
  final db = AppDatabase();
  final songRepository = DriftSongRepository(db);

  runApp(
    ChangeNotifierProvider(
      create: (_) => SongViewmodel(songRepository),
      child: const PhonyApp(),
    ),
  );
}

class PhonyApp extends StatelessWidget {
  const PhonyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phony',
      home: const HomePage(title: 'Phony'),
      theme: t.buildTheme(),
    );
  }
}