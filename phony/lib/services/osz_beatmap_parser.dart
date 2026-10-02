import 'dart:convert';

class OszBeatmapInfo {
  OszBeatmapInfo({
    required this.audioFilename,
    required this.title,
    this.titleUnicode,
    required this.artist,
    this.artistUnicode,
    required this.backgroundFilename,
  });

  final String audioFilename;
  final String title;
  final String? titleUnicode;
  final String artist;
  final String? artistUnicode;
  final String? backgroundFilename;
}

class OszBeatmapParser {
  static OszBeatmapInfo? parse(String content) {
    String section = '';
    String? audioFilename;
    String title = '';
    String titleUnicode = '';
    String artist = '';
    String artistUnicode = '';
    String? backgroundFilename;

    for (final String rawLine in const LineSplitter().convert(content)) {
      final String line = rawLine.trim();
      if (line.isEmpty || line.startsWith('//')) continue;

      if (line.startsWith('[') && line.endsWith(']')) {
        section = line;

        if (section == '[TimingPoints]' || section == '[HitObjects]') break;
        continue;
      }

      switch (section) {
        case '[General]':
          if (line.startsWith('AudioFilename')) {
            audioFilename = _valueAfterColon(line);
          }
        case '[Metadata]':
          if (line.startsWith('TitleUnicode')) {
            titleUnicode = _valueAfterColon(line);
          } else if (line.startsWith('Title')) {
            title = _valueAfterColon(line);
          } else if (line.startsWith('ArtistUnicode')) {
            artistUnicode = _valueAfterColon(line);
          } else if (line.startsWith('Artist')) {
            artist = _valueAfterColon(line);
          }
        case '[Events]':
          if (backgroundFilename == null && line.startsWith('0,0,"')) {
            final int closingQuote = line.indexOf('"', 5);
            if (closingQuote > 5) {
              backgroundFilename = line.substring(5, closingQuote);
            }
          }
      }
    }

    if (audioFilename == null || audioFilename.isEmpty || title.isEmpty) {
      return null;
    }

    return OszBeatmapInfo(
      audioFilename: audioFilename,
      title: title,
      titleUnicode: titleUnicode,
      artist: artist,
      artistUnicode: artistUnicode,
      backgroundFilename: backgroundFilename,
    );
  }

  static String _valueAfterColon(String line) {
    final int colon = line.indexOf(':');
    return colon == -1 ? '' : line.substring(colon + 1).trim();
  }
}
