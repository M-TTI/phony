import 'dart:io';

import 'package:audiotags/audiotags.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:phony/models/song.dart';
import 'package:phony/models/song_file.dart';
import 'package:phony/repositories/song_file_repository.dart';
import 'package:phony/repositories/song_repository.dart';

class ScanResult {
  final int added;
  final int moved;
  final int skipped;
  final int failed;

  const ScanResult({
    required this.added,
    required this.moved,
    required this.skipped,
    required this.failed,
  });
}

class LibraryScanService {
  LibraryScanService(this._songRepository, this._songFileRepository);

  final SongRepository _songRepository;
  final SongFileRepository _songFileRepository;

  static const Set<String> _supportedExtensions = {
    '.mp3',
    '.flac',
    '.ogg',
    '.m4a',
    '.wav',
  };

  Future<String> _resolveMusicDirectory() async {
    final String home = Platform.environment['HOME'] ?? '';

    try {
      final ProcessResult result = await Process.run('xdg-user-dir', ['MUSIC']);
      final String path = (result.stdout as String).trim();
      if (result.exitCode == 0 && path.isNotEmpty && path != home) {
        return path;
      }
    } on ProcessException {
      // fall through the default below.
    }

    return '$home/Music';
  }

  Future<String> _checksum(File file) async =>
      (await md5.bind(file.openRead()).first).toString();

  Future<void> _insertNewSong(File file, String checksum) async {
    final Tag? tag = await AudioTags.read(file.path);
    final FileStat stat = await file.stat();
    final String fallbackTitle = p.basenameWithoutExtension(file.path);

    await _songRepository.insertScanned(
      Song(
        id: 0,
        title: tag?.title ?? fallbackTitle,
        artist: tag?.trackArtist,
        hasMetaData: tag?.title != null,
        duration: tag?.duration ?? 0,
        imagePath: null,
        file: SongFile(
          id: 0,
          path: file.path,
          name: p.basename(file.path),
          artist: tag?.trackArtist,
          duration: tag?.duration ?? 0,
          checksum: checksum,
          size: stat.size,
          lastModified: stat.modified,
        ),
      ),
    );
  }

  Future<ScanResult> scan() async {
    int added = 0;
    int moved = 0;
    int skipped = 0;
    int failed = 0;

    final Directory dir = Directory(await _resolveMusicDirectory());
    if (!await dir.exists()) {
      return const ScanResult(added: 0, moved: 0, skipped: 0, failed: 0);
    }

    final List<SongFile> known = await _songFileRepository.getAll();
    final Map<String, SongFile> byPath = {for (final f in known) f.path: f};
    final Map<String, SongFile> byChecksum = {
      for (final f in known) f.checksum: f,
    };
    final Set<int> seenIds = {};
    final Set<String> insertedChecksums = {};

    // Phase 1
    final List<File> unknown = [];
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      if (!_supportedExtensions.contains(
        p.extension(entity.path).toLowerCase(),
      )) {
        continue;
      }

      final SongFile? match = byPath[entity.path];

      if (match != null) {
        seenIds.add(match.id);
        skipped++;
      } else {
        unknown.add(entity);
      }
    }

    // Phase 2
    for (final File file in unknown) {
      try {
        final String checksum = await _checksum(file);
        final SongFile? existing = byChecksum[checksum];
        if (existing != null && !seenIds.contains(existing.id)) {
          await _songFileRepository.updatePath(
            existing.id,
            file.path,
            p.basename(file.path),
          );
          seenIds.add(existing.id);
          moved++;
        } else if (existing != null || insertedChecksums.contains(checksum)) {
          skipped++;
        } else {
          await _insertNewSong(file, checksum);
          insertedChecksums.add(checksum);
          added++;
        }
      } catch (_) {
        failed++;
      }
    }

    return ScanResult(
      added: added,
      moved: moved,
      skipped: skipped,
      failed: failed,
    );
  }
}
