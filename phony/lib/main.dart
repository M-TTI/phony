import 'package:flutter/material.dart';
import 'database/database.dart';
import 'package:drift/drift.dart';

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
  List<Song> songs = [];

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    await database.insertSong(
      SongsCompanion.insert(
        title: 'Test Song',
        duration: 180,
        filePath: 'this/is/the/path',
        imagePath: Value.absent(),
        fileChecksum: Value.absent(),
        hasCustomMetadata: Value.absent(),
      ),
    );

    final allSongs = await database.getAllSongs();
    setState(() {
      songs = allSongs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: songs.isEmpty
          ? const Center(child: CircularProgressIndicator())
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
    );
  }

  @override
  void dispose() {
    database.close();
    super.dispose();
  }
}
