import 'dart:convert';

import 'package:phony/models/player_state.dart';
import 'package:phony/repositories/app_player_state_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsAppPlayerStateRepository implements AppPlayerStateRepository {
  const PrefsAppPlayerStateRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'player_state';

  @override
  Future<AppPlayerState?> load() async {
    try {
      final String? raw = _prefs.getString(_key);

      if (raw == null) return null;

      return AppPlayerState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null; // state error -> fresh "no state" start
    }
  }

  @override
  Future<void> save(AppPlayerState state) =>
      _prefs.setString(_key, jsonEncode(state.toJson()));

  @override
  Future<void> clear() => _prefs.remove(_key);
}
