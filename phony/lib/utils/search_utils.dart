import 'package:diacritic/diacritic.dart';
import 'package:phony/models/song.dart';

String buildSearchHaystack(Song song) {
  return normalizeString(
    [
      song.title,
      song.titleUnicode,
      song.artist,
      song.artistUnicode,
    ].nonNulls.join(' '),
  );
}

String normalizeString(String text) {
  return removeDiacritics(text).toLowerCase();
}

bool matchesTerms(String haystack, List<String> terms) {
  return terms.every((t) => haystack.contains(t));
}
