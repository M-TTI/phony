import 'package:flutter_test/flutter_test.dart';
import 'package:phony/models/song.dart';
import 'package:phony/models/song_file.dart';
import 'package:phony/utils/search_utils.dart';

Song _song({
  required String title,
  String? titleUnicode,
  String? artist,
  String? artistUnicode,
}) {
  final DateTime stamp = DateTime(2025);
  return Song(
    id: 1,
    title: title,
    titleUnicode: titleUnicode,
    artist: artist,
    artistUnicode: artistUnicode,
    file: SongFile(
      id: 1,
      path: '/music/song.mp3',
      name: 'song.mp3',
      duration: 0,
      checksum: '',
      size: 0,
      createdAt: stamp,
      updatedAt: stamp,
    ),
    duration: 0,
    hasMetaData: true,
    isFromOsz: false,
    createdAt: stamp,
    updatedAt: stamp,
  );
}

bool _matches(Song song, String query) {
  final List<String> terms = normalizeString(
    query.trim(),
  ).split(RegExp(r'\s+'));
  return matchesTerms(buildSearchHaystack(song), terms);
}

void main() {
  final Song yoruNiKakeru = _song(
    title: 'Yoru ni Kakeru',
    titleUnicode: '夜に駆ける',
    artist: 'YOASOBI',
  );
  final Song halo = _song(title: 'Halo', artist: 'Beyoncé');
  final Song untagged = _song(title: 'track01');

  group('buildSearchHaystack', () {
    test('keeps both metadata forms', () {
      final String haystack = buildSearchHaystack(yoruNiKakeru);
      expect(haystack, contains('yoru ni kakeru'));
      expect(haystack, contains('夜に駆ける'));
      expect(haystack, contains('yoasobi'));
    });

    test('skips null fields instead of writing "null"', () {
      expect(buildSearchHaystack(untagged), 'track01');
    });

    test('lowercases and strips diacritics', () {
      expect(buildSearchHaystack(halo), 'halo beyonce');
    });
  });

  group('matchesTerms', () {
    test('matches a partial word', () {
      expect(_matches(yoruNiKakeru, 'yoa'), isTrue);
    });

    test('matches the romanized title of a song titled in japanese', () {
      expect(_matches(yoruNiKakeru, 'kakeru'), isTrue);
    });

    test('matches the unicode title', () {
      expect(_matches(yoruNiKakeru, '駆け'), isTrue);
    });

    test('is case-insensitive', () {
      expect(_matches(yoruNiKakeru, 'KAKERU'), isTrue);
    });

    test('ignores diacritics on either side', () {
      expect(_matches(halo, 'beyonce'), isTrue);
      expect(_matches(halo, 'Beyoncé'), isTrue);
    });

    test('matches terms spread across fields', () {
      expect(_matches(yoruNiKakeru, 'yoasobi kakeru'), isTrue);
    });

    test('tolerates surrounding and repeated whitespace', () {
      expect(_matches(yoruNiKakeru, '  yoasobi   kakeru  '), isTrue);
    });

    test('requires every term to match', () {
      expect(_matches(yoruNiKakeru, 'yoasobi halo'), isFalse);
    });

    test('rejects an unrelated query', () {
      expect(_matches(yoruNiKakeru, 'metallica'), isFalse);
    });

    test('does not match "null" against missing fields', () {
      expect(_matches(untagged, 'null'), isFalse);
    });
  });
}
