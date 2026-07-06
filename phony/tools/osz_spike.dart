// Throwaway spike: inspect a real .osz to validate import design assumptions.
// Usage: dart run tools/osz_spike.dart <path/to/mapset.osz>

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';

void main(List<String> args) {
  final File oszFile = File(args.first);
  final Archive archive = ZipDecoder().decodeBytes(oszFile.readAsBytesSync());

  stdout.writeln('=== archive contents (${archive.length} entries) ===');
  for (final ArchiveFile entry in archive) {
    stdout.writeln('${entry.size.toString().padLeft(9)}  ${entry.name}');
  }

  stdout.writeln('\n=== .osu files ===');
  for (final ArchiveFile entry in archive) {
    if (!entry.name.toLowerCase().endsWith('.osu')) continue;
    stdout.writeln('\n--- ${entry.name} ---');
    final String text = utf8.decode(entry.content as List<int>);
    for (final String line in const LineSplitter().convert(text)) {
      if (line.startsWith('AudioFilename:') ||
          line.startsWith('Title:') ||
          line.startsWith('TitleUnicode:') ||
          line.startsWith('Artist:') ||
          line.startsWith('ArtistUnicode:') ||
          line.startsWith('Creator:') ||
          line.startsWith('0,0,"') ||
          line.startsWith('Video') ||
          line.startsWith('1,0,')) {
        stdout.writeln(line);
      }
    }
  }
}
