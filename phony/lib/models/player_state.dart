import 'package:phony/models/enums/repeat_mode.dart';
import 'package:phony/models/enums/source_type.dart';

class AppPlayerState {
  const AppPlayerState({
    required this.queueIds,
    required this.originalQueueIds,
    required this.currentIndex,
    required this.positionSeconds,
    required this.volume,
    required this.isMuted,
    required this.shuffleEnabled,
    required this.repeatMode,
    required this.sourceType,
    this.sourcePlaylistId,
  });

  static const int currentVersion = 1;

  final List<int> queueIds;
  final List<int> originalQueueIds;
  final int currentIndex;
  final int positionSeconds;
  final double volume;
  final bool isMuted;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;
  final SourceType sourceType;
  final int? sourcePlaylistId;

  Map<String, dynamic> toJson() => {
    'version': currentVersion,
    'queueIds': queueIds,
    'originalQueueIds': originalQueueIds,
    'currentIndex': currentIndex,
    'positionSeconds': positionSeconds,
    'volume': volume,
    'isMuted': isMuted,
    'shuffleEnabled': shuffleEnabled,
    'repeatMode': repeatMode.name,
    'sourceType': sourceType.name,
    'sourcePlaylistId': sourcePlaylistId,
  };

  factory AppPlayerState.fromJson(Map<String, dynamic> json) {
    if (json['version'] != currentVersion) {
      throw const FormatException('unsupported player state version');
    }

    return AppPlayerState(
      queueIds: (json['queueIds'] as List).cast<int>(),
      originalQueueIds: (json['originalQueueIds'] as List).cast<int>(),
      currentIndex: json['currentIndex'] as int,
      positionSeconds: json['positionSeconds'] as int,
      volume: (json['volume'] as num).toDouble(),
      isMuted: json['isMuted'] as bool,
      shuffleEnabled: json['shuffleEnabled'] as bool,
      repeatMode: RepeatMode.values.byName(json['repeatMode'] as String),
      sourceType: SourceType.values.byName(json['sourceType'] as String),
      sourcePlaylistId: json['sourcePlaylistId'] as int?,
    );
  }
}
