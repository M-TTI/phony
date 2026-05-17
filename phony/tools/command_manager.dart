import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

Map<String, String> commandHelper = {
  'List all songs': '1',
  'Seed database with test songs': '2',
  'Wipe database': '3',
};

int main(List<String> args) {
  String? input;

  if (args.isEmpty || args.contains('-h') || args.contains('--help')) {
    stdout.writeln('List of commands available');
    commandHelper.forEach((name, number) {
      stdout.writeln(' - $name:\t$number');
    });
    stdout.write('Enter the corresponding number to run a command: ');

    input = stdin.readLineSync();
  } else {
    input = args[0];
  }

  try {
    switch (input) {
      case '1':
        String dbPath = _getDatabasePath();
        _findAllSongs(dbPath);
      case '2':
        String dbPath = _getDatabasePath();
        _seedDatabase(dbPath);
      case '3':
        String dbPath = _getDatabasePath();
        _wipeDatabase(dbPath);
        stdout.writeln('Database wiped.');
      default:
        stdout.writeln('No argument provided');
    }
  } catch (e) {
    stdout.writeln(e);
  }

  return 0;
}

String _getDatabasePath() {
  if (Platform.isLinux) {
    final xdgDataHome = Platform.environment['XDG_DATA_HOME'];
    final home = Platform.environment['HOME'];

    final dataDir = (xdgDataHome != null && xdgDataHome.isNotEmpty)
        ? xdgDataHome
        : '$home/.local/share';

    return '$dataDir/com.example.phony/phony_database.sqlite';
  }

  throw Exception('Database commands not implemented on ${Platform.operatingSystem}');
}

void _seedDatabase(String dbPath) {
  final file = File(dbPath);
  if (!file.existsSync()) {
    throw Exception('Database not found at: $dbPath');
  } else {
    Database db = sqlite3.open(dbPath);
    final sql = 'INSERT INTO songs (title, artist, file_path, duration, has_meta_data) VALUES'
        '("Phony", "Kafu", "/home/mtti/Music/phony.mp3", 190, false),'
        '("Lagtrain", "Will Stetson, Inabakumori", "/home/mtti/Music/Lagtrain.mp3", 253, false),'
        '("Niramenkko", "", "/home/mtti/Music/Niramenkko.ogg", 158, false),'
        '("The Pretender", "Infected Mushrooms", "/home/mtti/Music/\'The Pretender\'.mp3", 394, false),'
        '("Yomi Yori", "Imperial Circus Dead Decadence", "/home/mtti/Music/\'Yomi Yori.ogg\'.mp3", 498, false);';

    try {
      stdout.writeln('Inserting songs');
      db.execute(sql);
    } catch (e) {
      stdout.writeln('Could not seed the database: $e');
    }
  }
}

void _wipeDatabase(String dbPath) {
  final file = File(dbPath);
  if (!file.existsSync()) {
    throw Exception('Database not found at: $dbPath');
  } else {
    file.deleteSync();
  }
}

void _findAllSongs(String dbPath) {
  final file = File(dbPath);
  if (!file.existsSync()) {
    throw Exception('Database not found at: $dbPath');
  } else {
    Database db = sqlite3.open(dbPath);
    final result = db.select('SELECT * FROM songs');

    stdout.writeln('${'title'.padRight(30)} | duration');
    stdout.writeln('${'-' * 30}-+---------');
    for (final row in result) {
      final duration = _formatDuration(row['duration'] as int);
      final title = row['title'] as String;
      stdout.writeln('${title.padRight(30)} | $duration');
    }

    db.dispose();
  }
}

String _formatDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;

  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}