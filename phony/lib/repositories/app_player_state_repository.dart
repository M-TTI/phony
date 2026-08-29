import 'package:phony/models/player_state.dart';

abstract class AppPlayerStateRepository {
  Future<AppPlayerState?> load();

  Future<void> save(AppPlayerState state);

  Future<void> clear();
}
