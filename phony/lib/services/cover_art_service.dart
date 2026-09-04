import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CoverArtService {
  static const List<String> _folderCoverNames = [
    'cover',
    'folder',
    'front',
    'album',
    'albumart',
  ];

  static const Set<String> _imageExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  };

  Directory? _coversDir;
  final Map<String, String?> _folderCovers = {};

  Future<String?> resolve(File audioFile, AudioMetadata audioMetadata) async {
    final Picture? picture = _pickPicture(audioMetadata.pictures);

    if (picture != null) {
      final String? extension = _extensionFor(picture.bytes, picture.mimetype);
      if (extension != null) return _writeCover(picture.bytes, extension);
    }

    return _findFolderCover(audioFile.parent);
  }

  void clearCache() => _folderCovers.clear();

  void reset() {
    _coversDir = null;
    clearCache();
  }

  Picture? _pickPicture(List<Picture> pictures) {
    if (pictures.isEmpty) return null;

    for (final Picture picture in pictures) {
      if (picture.pictureType == .coverFront) return picture;
    }

    return pictures.first;
  }

  Future<String> _writeCover(Uint8List bytes, String extension) async {
    final Directory dir = await _resolveCoversDir();
    final String hash = md5.convert(bytes).toString();
    final File target = File(p.join(dir.path, '$hash$extension'));

    if (!await target.exists()) await target.writeAsBytes(bytes);

    return target.path;
  }

  Future<Directory> _resolveCoversDir() async {
    final Directory? cached = _coversDir;
    if (cached != null) return cached;

    final Directory dir = Directory(
      p.join((await getApplicationSupportDirectory()).path, 'covers'),
    );

    await dir.create(recursive: true);

    return _coversDir = dir;
  }

  Future<String?> _findFolderCover(Directory dir) async {
    if (_folderCovers.containsKey(dir.path)) return _folderCovers[dir.path];

    String? found;
    int bestRank = _folderCoverNames.length;

    try {
      await for (final FileSystemEntity entity in dir.list(
        followLinks: false,
      )) {
        if (entity is! File) continue;
        if (!_imageExtensions.contains(
          p.extension(entity.path).toLowerCase(),
        )) {
          continue;
        }

        final int rank = _folderCoverNames.indexOf(
          p.basenameWithoutExtension(entity.path).toLowerCase(),
        );
        if (rank == -1 || rank >= bestRank) continue;

        bestRank = rank;
        found = entity.path;
      }
    } on FileSystemException {
      // Unreadable directory
    }

    return _folderCovers[dir.path] = found;
  }

  String? _extensionFor(Uint8List bytes, String mimetype) {
    if (_startsWith(bytes, const [0xFF, 0xD8, 0xFF])) return '.jpg';
    if (_startsWith(bytes, const [0x89, 0x50, 0x4E, 0x47])) return '.png';
    if (_startsWith(bytes, const [0x47, 0x49, 0x46, 0x38])) return '.gif';
    if (_startsWith(bytes, const [0x52, 0x49, 0x46, 0x46]) &&
        _startsWith(bytes, const [0x57, 0x45, 0x42, 0x50], offset: 8)) {
      return '.webp';
    }
    if (_startsWith(bytes, const [0x42, 0x4D])) return '.bmp';

    final String type = mimetype.toLowerCase();
    if (type.contains('jpg') || type.contains('jpeg')) return '.jpg';
    if (type.contains('png')) return '.png';
    if (type.contains('gif')) return '.gif';
    if (type.contains('webp')) return '.webp';
    if (type.contains('bmp')) return '.bmp';

    return null;
  }

  bool _startsWith(Uint8List bytes, List<int> mimebytes, {int offset = 0}) {
    if (bytes.length < offset + mimebytes.length) return false;

    for (int i = 0; i < mimebytes.length; i++) {
      if (bytes[offset + i] != mimebytes[i]) return false;
    }

    return true;
  }
}
