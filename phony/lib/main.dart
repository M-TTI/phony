import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:phony/databases/database.dart';
import 'package:phony/repositories/drift_playlist_repository.dart';
import 'package:phony/repositories/drift_song_file_repository.dart';
import 'package:phony/repositories/drift_song_repository.dart';
import 'package:phony/repositories/playlist_repository.dart';
import 'package:phony/repositories/prefs_app_player_state_repository.dart';
import 'package:phony/services/audio_player_service.dart';
import 'package:phony/services/library_scan_service.dart';
import 'package:phony/services/osz_import_service.dart';
import 'package:phony/themes/theme.dart' as t;
import 'package:phony/viewmodels/player_viewmodel.dart';
import 'package:phony/viewmodels/playlist_viewmodel.dart';
import 'package:phony/viewmodels/song_viewmodel.dart';
import 'package:phony/views/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final db = AppDatabase();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final songRepository = DriftSongRepository(db);
  final songFileRepository = DriftSongFileRepository(db);
  final playlistRepository = DriftPlaylistRepository(db);
  final appPlayStateRepository = PrefsAppPlayerStateRepository(prefs);

  final libraryScanService = LibraryScanService(
    songRepository,
    songFileRepository,
  );
  final oszImportService = OszImportService(songRepository, songFileRepository);
  final audioPlayerService = AudioPlayerService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SongViewmodel(
            songRepository,
            libraryScanService,
            oszImportService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PlaylistViewmodel(playlistRepository),
        ),
        Provider<PlaylistRepository>.value(value: playlistRepository),
        ChangeNotifierProvider(
          create: (_) => PlayerViewmodel(
            audioPlayerService,
            songRepository,
            playlistRepository,
            appPlayStateRepository,
          ),
        ),
      ],
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
      debugShowCheckedModeBanner: false,
    );
  }
}
