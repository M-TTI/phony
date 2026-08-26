import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:crypto/crypto.dart';
import 'package:external_path/external_path.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:phony/models/song.dart';
import 'package:phony/models/song_file.dart';
import 'package:phony/repositories/song_file_repository.dart';
import 'package:phony/repositories/song_repository.dart';
import 'package:phony/services/cover_art_service.dart';

class ScanResult {
  final int added;
  final int covered;
  final int moved;
  final int skipped;
  final int failed;

  const ScanResult({
    required this.added,
    required this.covered,
    required this.moved,
    required this.skipped,
    required this.failed,
  });
}

class LibraryScanService {
  LibraryScanService(
    this._songRepository,
    this._songFileRepository,
    this._coverArtService,
  );

  final SongRepository _songRepository;
  final SongFileRepository _songFileRepository;
  final CoverArtService _coverArtService;

  static const Set<String> _supportedExtensions = {
    '.mp3',
    '.flac',
    '.ogg',
    '.wav',
  };

  static const int _coverBatchSize = 100;

  Future<String> _resolveMusicDirectory() async {
    if (Platform.isAndroid) {
      return await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_MUSIC,
      );
    }

    if (Platform.isLinux) {
      final String home = Platform.environment['HOME'] ?? '';

      try {
        final ProcessResult result = await Process.run('xdg-user-dir', [
          'MUSIC',
        ]);
        final String path = (result.stdout as String).trim();
        if (result.exitCode == 0 && path.isNotEmpty && path != home) {
          return path;
        }
      } on ProcessException {
        // fall through the default below.
      }

      return '$home/Music';
    }

    return '';
  }

  Future<String> _checksum(File file) async =>
      (await md5.bind(file.openRead()).first).toString();

  AudioMetadata _readMetadata(File file) {
    try {
      return readMetadata(file, getImage: true);
    } catch (_) {
      return readMetadata(file, getImage: false);
    }
  }

  Future<bool> _insertNewSong(File file, String checksum) async {
    final AudioMetadata metadata = _readMetadata(file);
    final FileStat stat = await file.stat();
    final String fallbackTitle = p.basenameWithoutExtension(file.path);

    String? imagePath;

    try {
      imagePath = await _coverArtService.resolve(file, metadata);
    } catch (_) {
      imagePath = null;
    }

    await _songRepository.insertScanned(
      Song(
        id: 0,
        title: metadata.title ?? fallbackTitle,
        artist: metadata.artist,
        hasMetaData: metadata.title != null,
        duration: metadata.duration?.inSeconds ?? 0,
        imagePath: imagePath,
        file: SongFile(
          id: 0,
          path: file.path,
          name: p.basename(file.path),
          artist: metadata.artist,
          duration: metadata.duration?.inSeconds ?? 0,
          checksum: checksum,
          size: stat.size,
          lastModified: stat.modified,
        ),
      ),
      coverChecked: true,
    );

    return imagePath != null;
  }

  Future<Directory?> _resolveScannableDirectory() async {
    if (Platform.isAndroid) {
      final PermissionStatus status = await Permission.audio.request();
      if (!status.isGranted) return null;
    }

    final Directory dir = Directory(await _resolveMusicDirectory());
    return await dir.exists() ? dir : null;
  }

  Future<({int added, int moved, int covered, int skipped, int failed})>
  _scanDirectory(Directory dir) async {
    int added = 0;
    int covered = 0;
    int moved = 0;
    int skipped = 0;
    int failed = 0;

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
          if (await _insertNewSong(file, checksum)) covered++;
          insertedChecksums.add(checksum);
          added++;
        }
      } catch (_) {
        failed++;
      }
    }

    return (
      added: added,
      covered: covered,
      moved: moved,
      skipped: skipped,
      failed: failed,
    );
  }

  // Phase 3
  Future<int> _backfillCovers() async {
    final List<Song> needsCover = await _songRepository
        .getSongsNeedingCoverCheck();
    final Map<int, String?> resolved = {};
    int covered = 0;

    for (final Song song in needsCover) {
      final File file = File(song.file.path);
      if (!await file.exists()) continue;

      String? imagePath;
      try {
        imagePath = await _coverArtService.resolve(file, _readMetadata(file));
      } catch (_) {
        imagePath = null;
      }

      resolved[song.id] = imagePath;
      if (imagePath != null) covered++;

      if (resolved.length >= _coverBatchSize) {
        await _songRepository.setCoverArt(resolved);
        resolved.clear();
      }
    }

    if (resolved.isNotEmpty) await _songRepository.setCoverArt(resolved);

    return covered;
  }

  Future<ScanResult> scan() async {
    _coverArtService.clearCache();

    final Directory? dir = await _resolveScannableDirectory();
    final ({int added, int covered, int failed, int moved, int skipped}) files =
        dir == null
        ? (added: 0, covered: 0, moved: 0, skipped: 0, failed: 0)
        : await _scanDirectory(dir);

    final int covered = await _backfillCovers() + files.covered;

    return ScanResult(
      added: files.added,
      covered: covered,
      moved: files.moved,
      skipped: files.skipped,
      failed: files.failed,
    );
  }
}
