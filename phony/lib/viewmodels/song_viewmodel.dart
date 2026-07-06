import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:phony/models/song.dart';
import 'package:phony/repositories/song_repository.dart';
import 'package:phony/services/library_scan_service.dart';
import 'package:phony/services/osz_import_service.dart';

class SongViewmodel extends ChangeNotifier {
  final SongRepository _songRepository;

  final LibraryScanService _scanService;
  final OszImportService _importService;

  List<Song> songs = [];
  StreamSubscription<List<Song>>? _streamSubscription;

  bool isScanning = false;
  bool isImporting = false;

  SongViewmodel(this._songRepository, this._scanService, this._importService) {
    _streamSubscription = _songRepository.watchAll().listen((data) {
      songs = data;
      notifyListeners();
    });
  }

  Future<void> delete(int id) => _songRepository.delete(id);

  Future<ScanResult?> scanLibrary() async {
    if (isScanning) return null;
    isScanning = true;
    notifyListeners();

    try {
      return await _scanService.scan();
    } finally {
      isScanning = false;
      notifyListeners();
    }
  }

  Future<ImportResult?> importOsz(List<String> paths) async {
    if (isImporting) return null;
    isImporting = true;
    notifyListeners();

    try {
      return await _importService.importFiles(paths);
    } finally {
      isImporting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
