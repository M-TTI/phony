import 'dart:io';

class FileScanner {
  Future<List<File>> scanDirectory(String directoryPath) async {
    final directory = Directory(directoryPath);
    final List<File> mp3Files = [];
    
    if (!await directory.exists()) {
      print('Directory does not exist : $directoryPath');
      
      return mp3Files;
    }
    
    await for (final entity in directory.list(recursive: false)) {
      if (entity is File && entity.path.endsWith('.mp3')) {
        mp3Files.add(entity);
      } else if (entity is Directory) {
        final subEntities = await scanDirectory(entity.path);
        mp3Files.addAll(subEntities);
      }
    }
    
    return mp3Files;
  }
  
  Future<List<File>> scanMusicDirectory() async {
    String? musicPath;
    
    if (Platform.isLinux) {
      try {
        final result = await Process.run('xdg-user-dir', ['MUSIC']);
        if (result.exitCode == 0) {
          musicPath = result.stdout.toString().trim();
        }
      } catch (e) {
        print('Error running xdg-user-dir: $e');
      }
    }
    
    if (musicPath == null || musicPath.isEmpty) {
      final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
      if (home == null) {
        print('Could not find home directory');
        
        return [];
      }
      musicPath = '$home/Music';
    }
    
    print('Scanning: $musicPath');
    
    return await scanDirectory(musicPath);
  }
}