import 'package:flutter/material.dart';
import 'package:phony/models/playlist.dart';
import 'package:phony/themes/theme.dart' as t;
import 'package:phony/viewmodels/playlist_viewmodel.dart';
import 'package:phony/views/components/playlist_name_dialog.dart';
import 'package:provider/provider.dart';

class PlaylistContextMenu extends StatelessWidget {
  const PlaylistContextMenu({super.key, required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, controller, child) => IconButton(
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        padding: .zero,
        constraints: const BoxConstraints(),
        visualDensity: .compact,
        icon: const Icon(t.moreIcon, color: t.onPrimary, size: 24),
      ),
      menuChildren: [
        MenuItemButton(
          leadingIcon: Icon(t.editIcon, size: 20),
          onPressed: () => _rename(context),
          child: const Text('Rename'),
        ),
        MenuItemButton(
          leadingIcon: Icon(t.trashIcon, size: 20),
          onPressed: () => _confirmDelete(context),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete "${playlist.name}"?'),
        content: const Text('Songs in it stay in your library.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<PlaylistViewmodel>().delete(playlist.id);
    }
  }

  Future<void> _rename(BuildContext context) async {
    final String? name = await showDialog<String>(
      context: context,
      builder: (_) => PlaylistNameDialog(
        title: 'Rename playlist',
        confirmLabel: 'Rename',
        initialName: playlist.name,
      ),
    );

    final String trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty || trimmed == playlist.name || !context.mounted) return;
    await context.read<PlaylistViewmodel>().rename(playlist.id, trimmed);
  }
}
