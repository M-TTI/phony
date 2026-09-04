import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:phony/repositories/app_player_state_repository.dart';
import 'package:phony/repositories/maintenance_repository.dart';
import 'package:phony/services/cover_art_service.dart';

class LibraryResetService {
  const LibraryResetService(
    this._maintenanceRepository,
    this._coverArtService,
    this._playerStateRepository,
  );

  final MaintenanceRepository _maintenanceRepository;
  final CoverArtService _coverArtService;
  final AppPlayerStateRepository _playerStateRepository;

  Future<void> reset() async {
    await _maintenanceRepository.resetLibrary();

    final Directory support = await getApplicationSupportDirectory();
    for (final String name in const ['imported', 'covers']) {
      final Directory dir = Directory(p.join(support.path, name));
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }

    _coverArtService.reset();
    await _playerStateRepository.clear();
  }
}
