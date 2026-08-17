import 'package:flutter/material.dart';
import 'package:phony/themes/theme.dart' as t;
import 'package:phony/viewmodels/playlist_viewmodel.dart';
import 'package:phony/views/components/app_drawer.dart';
import 'package:phony/views/components/playlist_name_dialog.dart';
import 'package:phony/views/playlists_view.dart';
import 'package:phony/views/songs_view.dart';
import 'package:provider/provider.dart';

import 'package:phony/views/components/top_bar.dart';

class MainTabsView extends StatefulWidget {
  const MainTabsView({super.key, required this.title});

  final String title;

  @override
  State<MainTabsView> createState() => MainTabsViewState();
}

class MainTabsViewState extends State<MainTabsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void switchToTab(int index) => _tabController.animateTo(index);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: t.background,
        appBar: TopBar(title: widget.title, tabController: _tabController),
        drawer: const AppDrawer(),
        floatingActionButton: AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            if (_tabController.index != 1) {
              return const SizedBox.shrink(); // 1 is Playlist Tab
            }
            return FloatingActionButton(
              onPressed: () => _showCreatePlaylistDialog(context),
              child: const Icon(t.addIcon),
            );
          },
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            SongsView(),
            PlaylistsView(),
            // Center(child: Text('Coming soon!')),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    final String? name = await showDialog<String>(
      context: context,
      builder: (_) =>
          const PlaylistNameDialog(title: 'New playlist', confirmLabel: 'Create'),
    );

    final String trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty || !context.mounted) return;
    await context.read<PlaylistViewmodel>().create(trimmed);
  }
}
