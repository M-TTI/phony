import 'dart:io';
import 'package:audiotags/audiotags.dart';
import 'package:phony/models/song_metadata.dart';

class MetadataExtractor {
  Future<SongMetadata?> extractMetadata(File file) async {
    try {
      final tag = await AudioTags.read(file.path);

      if (tag == null) {
        print('Could not read metadata from file ${file.path}');

        return null;
      }

      return SongMetadata(
        title: tag.title ?? _getFilenameWithoutExtension(file.path),
        artist: tag.albumArtist,
        album: tag.album,
        duration: tag.duration ?? 0,
        filePath: file.path,
        pictureBytes: tag.pictures.isNotEmpty ? tag.pictures.first.bytes : null,
      );
    } catch (e) {
      print('Error extracting metadata from file ${file.path}: $e');

      return null;
    }
  }

  String _getFilenameWithoutExtension(String path) {
    final filename = path.split('/').last;
    return filename.split('.').first;
  }
}