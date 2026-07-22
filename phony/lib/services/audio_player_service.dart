import 'package:media_kit/media_kit.dart';

class AudioPlayerService {
  final Player _player = Player();

  Stream<Duration> get position => _player.stream.position;

  Stream<Duration> get duration => _player.stream.duration;

  Stream<bool> get playing => _player.stream.playing;

  Stream<bool> get completed => _player.stream.completed;

  Future<void> play(String path) => _player.open(Media(path));

  // Future<void> pause() => _player.pause();

  Future<void> pause() async {
    print(_player.platform?.state.volume);
    _player.pause();
  }

  Future<void> resume() => _player.play();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> stop() => _player.stop();

  Future<void> dispose() => _player.dispose();

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  Future<void> load(String path) => _player.open(Media(path), play: false);
}
