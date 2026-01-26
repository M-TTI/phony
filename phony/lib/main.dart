import 'package:flutter/material.dart';
import 'database/database.dart';
import 'services/file_scanner.dart';

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
  List<Song> songs = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final allSongs = await database.getAllSongs();
    setState(() {
      songs = allSongs;
    });
  }

  Future<void> _scanMusic() async {
    setState(() {
      isScanning = true;
    });

    final files = await scanner.scanMusicDirectory();
    print('Found ${files.length} MP3 files');

    for (final file in files) {
      print(file.path);
    }

    setState(() {
      isScanning = false;
    });
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
