import 'package:flutter_test/flutter_test.dart';
import 'package:phony/services/osz_beatmap_parser.dart';

void main() {
  const String fullBeatmap = '''
osu file format v14

[General]
AudioFilename: audio.mp3
AudioLeadIn: 0

[Metadata]
Title:Seishin no Kairi no, Sakebi to Nageki.
TitleUnicode:精神ノ乖離ノ、叫ビト嘆キ。
Artist:Imperial Circus Dead Decadence
ArtistUnicode:Imperial Circus Dead Decadence
Creator:Esutarosa

[Events]
//Background and Video events
Video,0,"video.mp4"
0,0,"bg.jpg",0,0

[TimingPoints]
566,325.0,4,2,1,60,1,0
''';

  test('parses a full beatmap, preferring unicode metadata', () {
    final OszBeatmapInfo? info = OszBeatmapParser.parse(fullBeatmap);
    expect(info, isNotNull);
    expect(info!.audioFilename, 'audio.mp3');
    expect(info.title, '精神ノ乖離ノ、叫ビト嘆キ。');
    expect(info.artist, 'Imperial Circus Dead Decadence');
    expect(info.backgroundFilename, 'bg.jpg');
  });

  test('falls back to ascii when unicode fields are empty', () {
    const String beatmap = '''
[General]
AudioFilename: song.ogg

[Metadata]
Title:Plain Song
TitleUnicode:
Artist:Somebody
ArtistUnicode:
''';
    final OszBeatmapInfo? info = OszBeatmapParser.parse(beatmap);
    expect(info!.title, 'Plain Song');
    expect(info.artist, 'Somebody');
  });

  test('video events are not mistaken for a background', () {
    const String beatmap = '''
[General]
AudioFilename: audio.mp3

[Metadata]
Title:No BG Here

[Events]
Video,0,"clip.mp4"
''';
    final OszBeatmapInfo? info = OszBeatmapParser.parse(beatmap);
    expect(info!.backgroundFilename, isNull);
  });

  test('returns null when AudioFilename is missing', () {
    const String beatmap = '''
[Metadata]
Title:Orphan
''';
    expect(OszBeatmapParser.parse(beatmap), isNull);
  });

  test('keeps colons inside metadata values', () {
    const String beatmap = '''
[General]
AudioFilename: audio.mp3

[Metadata]
Title:Re:Union
''';
    expect(OszBeatmapParser.parse(beatmap)!.title, 'Re:Union');
  });
}
