import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:phony/services/library_scan_service.dart';
import 'package:phony/services/osz_import_service.dart';
import 'package:phony/themes/theme.dart' as t;
import 'package:phony/viewmodels/song_viewmodel.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: .zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: t.primary),
            child: Align(
              alignment: .bottomLeft,
              child: Text(
                'Phony',
                style: TextStyle(color: t.onPrimary, fontSize: 24),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(t.scanIcon, color: t.onPrimary),
            title: const Text(
              'Scan music directory',
              style: TextStyle(color: t.onPrimary),
            ),
            onTap: () async {
              final SongViewmodel vm = context.read<SongViewmodel>();
              final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
                context,
              );

              Navigator.pop(context);
              final ScanResult? result = await vm.scanLibrary();
              if (result != null) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Scan complete: ${result.added} added, ${result.moved} moved, ${result.skipped} skipped, ${result.failed} failed',
                    ),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(t.downloadIcon, color: t.onPrimary),
            title: const Text(
              'Import .osz',
              style: TextStyle(color: t.onPrimary),
            ),
            onTap: () async {
              final SongViewmodel songVm = context.read<SongViewmodel>();
              final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
                context,
              );
              Navigator.pop(context);

              final List<String> paths;

              if (Platform.isAndroid) {
                final FilePickerResult? picked = await FilePicker.pickFiles(
                  allowMultiple: true,
                  dialogTitle: 'Select .osz beatmaps',
                );

                paths = (picked?.paths.nonNulls ?? const <String>[])
                    .where((p) => p.toLowerCase().endsWith('.osz'))
                    .toList();
              } else {
                final FilePickerResult? picked = await FilePicker.pickFiles(
                  allowMultiple: true,
                  type: .custom,
                  allowedExtensions: ['osz'],
                  dialogTitle: 'Select .osz beatmaps',
                );

                paths = picked?.paths.nonNulls.toList() ?? [];
              }

              if (paths.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('None of the selected files were .osz'),
                  ),
                );
              }

              final ImportResult? result = await songVm.importOsz(paths);
              if (result != null) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Import complete: ${result.imported} imported, ${result.skipped} skipped, ${result.failed} failed',
                    ),
                  ),
                );
              }
            },
          ),
          // ListTile(
          //   leading: const Icon(t.settingsIcon, color: t.onPrimary),
          //   title: const Text('Settings', style: TextStyle(color: t.onPrimary)),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.of(context).push(
          //       MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
