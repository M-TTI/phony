import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

Map<String, String> commandHelper = {
  'List all songs': '1',
  'Wipe database': '2',
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
        String dbPath = getDatabasePath();
        findAllSongs(dbPath);
      case '2':
        String dbPath = getDatabasePath();
        wipeDatabase(dbPath);
        stdout.writeln('Database wiped.');
      default:
        stdout.writeln('No argument provided');
    }
  } catch (e) {
    stdout.writeln(e);
  }

  return 0;
}

String getDatabasePath() {
  String? documentsPath;
  try {
    final result = Process.runSync('xdg-user-dir', ['DOCUMENTS']);
    if (result.exitCode == 0) {
      documentsPath = result.stdout.toString().trim();
    }
  } catch (e) {
    stdout.writeln('Error running xdg-user-dir: $e');
  }

  if (documentsPath == null || documentsPath.isEmpty) {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) {
      throw Exception('Could not find home path');
    }

    documentsPath = '$home/Documents';
  }

  if (Platform.isLinux) {
    return '$documentsPath/app_database.sqlite';
  }

  throw Exception('Database commands not implemented on ${Platform.operatingSystem}');
}

void wipeDatabase(String dbPath) {
  final file = File(dbPath);
  if (!file.existsSync()) {
    throw Exception('Database not found at: $dbPath');
  } else {
    file.deleteSync();
  }
}

void findAllSongs(String dbPath) {
  final file = File(dbPath);
  if (!file.existsSync()) {
    throw Exception('Database not found at: $dbPath');
  } else {
    Database db = sqlite3.open(dbPath);
    final result = db.select('SELECT * FROM songs');

    stdout.writeln('${'title'.padRight(30)} | duration');
    stdout.writeln('${'-' * 30}-+---------');
    for (final row in result) {
      final duration = formatDuration(row['duration'] as int);
      final title = row['title'] as String;
      stdout.writeln('${title.padRight(30)} | $duration');
    }

    db.dispose();
  }
}

String formatDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;

  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}