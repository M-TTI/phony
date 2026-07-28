import 'package:audio_service/audio_service.dart';

class MediaSessionHandler extends BaseAudioHandler {
  Future<void> Function()? onPlay;
  Future<void> Function()? onPause;
  Future<void> Function()? onNext;
  Future<void> Function()? onPrevious;
  Future<void> Function()? onStop;
  Future<void> Function(Duration position)? onSeek;

  @override
  Future<void> play() async => onPlay?.call();

  @override
  Future<void> pause() async => onPause?.call();

  @override
  Future<void> skipToNext() async => onNext?.call();

  @override
  Future<void> skipToPrevious() async => onPrevious?.call();

  @override
  Future<void> stop() async {
    await onStop?.call();
    playbackState.add(
      playbackState.value.copyWith(processingState: .idle, playing: false),
    );

    await super.stop(); // Removes the notification
  }

  @override
  Future<void> seek(Duration position) async => onSeek?.call(position);

  void setItem({
    required String id,
    required String title,
    String? artist,
    Uri? artUri,
    Duration? duration,
  }) {
    mediaItem.add(
      MediaItem(
        id: id,
        title: title,
        artist: artist,
        artUri: artUri,
        duration: duration,
      ),
    );
  }

  void setPlaybackState({
    required bool playing,
    required Duration position,
    AudioProcessingState processingState = .ready,
  }) {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {.seek},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: processingState,
        playing: playing,
        updatePosition: position,
      ),
    );
  }
}
