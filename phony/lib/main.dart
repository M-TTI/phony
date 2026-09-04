import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:phony/databases/database.dart';
import 'package:phony/repositories/drift_maintenance_repository.dart';
import 'package:phony/repositories/drift_playlist_repository.dart';
import 'package:phony/repositories/drift_song_file_repository.dart';
import 'package:phony/repositories/drift_song_repository.dart';
import 'package:phony/repositories/playlist_repository.dart';
import 'package:phony/repositories/prefs_app_player_state_repository.dart';
import 'package:phony/services/audio_player_service.dart';
import 'package:phony/services/cover_art_service.dart';
import 'package:phony/services/library_reset_service.dart';
import 'package:phony/services/library_scan_service.dart';
import 'package:phony/services/media_session_handler.dart';
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
  final mediaSessionHandler = await AudioService.init(
    builder: () => MediaSessionHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mtti.phony.playback',
      androidNotificationChannelName: 'Phony playback',
      androidNotificationOngoing: true,
    ),
  );
  final audioSession = await AudioSession.instance;
  await audioSession.configure(const AudioSessionConfiguration.music());

  final db = AppDatabase();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final songRepository = DriftSongRepository(db);
  final songFileRepository = DriftSongFileRepository(db);
  final playlistRepository = DriftPlaylistRepository(db);
  final maintenanceRepository = DriftMaintenanceRepository(db);
  final appPlayStateRepository = PrefsAppPlayerStateRepository(prefs);

  final coverArtService = CoverArtService();
  final libraryScanService = LibraryScanService(
    songRepository,
    songFileRepository,
    coverArtService,
  );
  final oszImportService = OszImportService(songRepository, songFileRepository);
  final audioPlayerService = AudioPlayerService();
  final libraryResetService = LibraryResetService(
    maintenanceRepository,
    coverArtService,
    appPlayStateRepository,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SongViewmodel(
            songRepository,
            libraryScanService,
            oszImportService,
            libraryResetService,
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
            mediaSessionHandler,
            audioSession,
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
