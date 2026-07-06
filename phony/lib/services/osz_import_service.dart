import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:audiotags/audiotags.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:phony/models/song.dart';
import 'package:phony/models/song_file.dart';
import 'package:phony/repositories/song_file_repository.dart';
import 'package:phony/repositories/song_repository.dart';
import 'package:phony/services/osz_beatmap_parser.dart';

class ImportResult {
  const ImportResult({
    required this.imported,
    required this.skipped,
    required this.failed,
  });

  final int imported;
  final int skipped;
  final int failed;
}

class OszImportService {
  OszImportService(this._songRepository, this._songFileRepository);

  final SongRepository _songRepository;
  final SongFileRepository _songFileRepository;

  Future<ImportResult> importFiles(List<String> oszPaths) async {
    int imported = 0;
    int skipped = 0;
    int failed = 0;

    final Directory targetDir = Directory(
      p.join((await getApplicationSupportDirectory()).path, 'imported'),
    );
    await targetDir.create(recursive: true);

    final List<SongFile> known = await _songFileRepository.getAll();
    final Set<String> knownChecksums = {
      for (final SongFile f in known) f.checksum,
    };

    for (final String path in oszPaths) {
      try {
        final (int i, int s) = await _importOne(
          File(path),
          targetDir,
          knownChecksums,
        );
        imported += i;
        skipped += s;
      } catch (_) {
        failed++;
      }
    }

    return ImportResult(imported: imported, skipped: skipped, failed: failed);
  }

  Future<(int, int)> _importOne(
    File oszFile,
    Directory targetDir,
    Set<String> knownChecksums,
  ) async {
    final Archive archive = ZipDecoder().decodeBytes(
      await oszFile.readAsBytes(),
    );

    final Map<String, ArchiveFile> entriesByName = {
      for (final ArchiveFile e in archive) e.name.toLowerCase(): e,
    };

    // Group difficulties: one OszBeatmapInfo per unique audio file.
    final Map<String, OszBeatmapInfo> byAudio = {};
    for (final ArchiveFile entry in archive) {
      if (!entry.name.toLowerCase().endsWith('.osu')) continue;
      final OszBeatmapInfo? info = OszBeatmapParser.parse(
        utf8.decode(entry.content as List<int>),
      );
      if (info != null) {
        byAudio.putIfAbsent(info.audioFilename.toLowerCase(), () => info);
      }
    }
    if (byAudio.isEmpty) throw const FormatException('no usable .osu files');

    int imported = 0;
    int skipped = 0;
    for (final OszBeatmapInfo info in byAudio.values) {
      final ArchiveFile? audioEntry =
          entriesByName[info.audioFilename.toLowerCase()];
      if (audioEntry == null) {
        throw const FormatException('referenced audio missing from archive');
      }

      final Uint8List audioBytes = audioEntry.content;
      final String checksum = md5.convert(audioBytes).toString();
      if (knownChecksums.contains(checksum)) {
        skipped++;
        continue;
      }

      final String audioPath = p.join(
        targetDir.path,
        '$checksum${p.extension(info.audioFilename)}',
      );
      await File(audioPath).writeAsBytes(audioBytes);

      String? imagePath;
      final ArchiveFile? bgEntry = info.backgroundFilename == null
          ? null
          : entriesByName[info.backgroundFilename!.toLowerCase()];
      if (bgEntry != null) {
        imagePath = p.join(
          targetDir.path,
          '${checksum}_bg${p.extension(info.backgroundFilename!)}',
        );
        await File(imagePath).writeAsBytes(bgEntry.content);
      }

      final Tag? tag = await AudioTags.read(audioPath);
      final FileStat stat = await File(audioPath).stat();
      final String? artist = info.artist.isEmpty ? null : info.artist;

      await _songRepository.insertScanned(
        Song(
          id: 0,
          title: info.title,
          artist: artist,
          hasMetaData: true,
          duration: tag?.duration ?? 0,
          imagePath: imagePath,
          file: SongFile(
            id: 0,
            path: audioPath,
            name: p.basename(audioPath),
            artist: artist,
            duration: tag?.duration ?? 0,
            checksum: checksum,
            size: stat.size,
            lastModified: stat.modified,
          ),
        ),
      );
      knownChecksums.add(checksum);
      imported++;
    }

    return (imported, skipped);
  }
}
