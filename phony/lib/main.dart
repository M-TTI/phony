import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'database/database.dart';
import 'services/file_scanner.dart';
import 'services/metadata_extractor.dart';
import 'models/song_metadata.dart';
import 'services/checksum_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phony',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Phony'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final database = AppDatabase();
  final scanner = FileScanner();
  final extractor = MetadataExtractor();
  final checksumService = ChecksumService();
  List<Song> songs = [];
  List<SongMetadata> scannedSongs = [];
  bool isScanning = false;

  final isImporting = ValueNotifier<bool>(false);
  final importProgress = ValueNotifier<int>(0);
  final importTotal = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final allSongs = await database.findAllSongs();
    setState(() {
      songs = allSongs;
    });
  }

  Future<void> _scanMusic() async {
    setState(() {
      isScanning = true;
    });

    // Find .mp3 files
    final files = await scanner.scanMusicDirectory();
    print('Found ${files.length} MP3 files');

    // Extract metadata from each file
    for (final file in files) {
      final metadata = await extractor.extractMetadata(file);
      if (metadata != null) {
        scannedSongs.add(metadata);
      }
    }

    setState(() {
      isScanning = false;
    });

    if (mounted) {
      _showImportDialog(scannedSongs.length);
    }
  }

  Future<void> _showImportDialog(int songCount) async {
    return showDialog(
      context: context,
      builder: (buildContext) {
        return AlertDialog(
          title: const Text('Scan complete'),
          content: Text('Found $songCount songs.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _importAllSongs();
              },
              child: const Text('Import All'),
            )
          ],
        );
      },
    );
  }

  Future<void> _importAllSongs() async {
    isImporting.value = true;
    importProgress.value = 0;
    importTotal.value = scannedSongs.length;

    for (int i = 0; i < importTotal.value; i++) {
      final metadata = scannedSongs[i];

      final file = File(metadata.filePath);
      final checksum = await checksumService.generateChecksum(file);

      final existing = await database.findSongByChecksum(checksum);

      if (existing == null) {
        await database.insertSong(
          SongsCompanion.insert(
            title: metadata.title,
            duration: metadata.duration,
            filePath: metadata.filePath,
            imagePath: Value.absent(),
            fileChecksum: Value.absent(),
            hasCustomMetadata: Value(false),
          ),
        );
        print('imported: ${metadata.title}');
      } else {
        print('skipped duplicate: ${metadata.title}');
      }

      importProgress.value = i + 1;
    }

    isImporting.value = false;

    print('Import complete!');
    scannedSongs.clear();

    await _loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
                onPressed: isScanning ? null : _scanMusic,
                child: isScanning
                    ? const Text('Scanning...')
                    : const Text('Scan Music Directory'),
            ),
          ),
          Expanded(
            child: songs.isEmpty
                ? const Center(child: Text('No songs in database'))
                : ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return ListTile(
                        title: Text(song.title),
                        subtitle: Text('${song.duration} seconds'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    database.close();
    super.dispose();
  }
}
