import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:phony/models/playlist.dart';
import 'package:phony/models/queue_source.dart';
import 'package:phony/themes/theme.dart' as t;
import 'package:phony/viewmodels/playlist_viewmodel.dart';
import 'package:phony/views/components/mini_player.dart';
import 'package:phony/views/main_tabs_view.dart';
import 'package:phony/views/player_view.dart';
import 'package:phony/views/playlist_detail_view.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<MainTabsViewState> _tabsKey = GlobalKey<MainTabsViewState>();

  final DraggableScrollableController _playerSheetController =
      DraggableScrollableController();

  @override
  void dispose() {
    _playerSheetController.dispose();
    super.dispose();
  }

  Future<void> openPlayerView() => _playerSheetController.animateTo(
    1.0,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );

  Future<void> closePlayerView() => _playerSheetController.animateTo(
    0.0,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );

  void navigateToSource(QueueSource source) {
    closePlayerView();
    final NavigatorState navigator = _navigatorKey.currentState!;
    navigator.popUntil((Route route) => route.isFirst);

    switch (source) {
      case LibraryQueueSource():
        _tabsKey.currentState?.switchToTab(0);
      case PlaylistQueueSource(:final playlist):
        final Playlist? live = context
            .read<PlaylistViewmodel>()
            .playlists
            .where((Playlist p) => p.id == playlist.id)
            .firstOrNull;
        if (live == null) return;
        _tabsKey.currentState?.switchToTab(1);
        navigator.push(PlaylistDetailView.route(live));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Scaffold(
          backgroundColor: t.background,
          body: NavigatorPopHandler(
            onPopWithResult: (result) => _navigatorKey.currentState?.maybePop(),
            child: Navigator(
              key: _navigatorKey,
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (_) => MainTabsView(title: widget.title),
              ),
            ),
          ),
          bottomNavigationBar: ColoredBox(
            color: t.primary,
            child: SafeArea(
              top: false,
              child: MiniPlayer(openCommand: openPlayerView),
            ),
          ),
        ),
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
          ),
          child: DraggableScrollableSheet(
            controller: _playerSheetController,
            initialChildSize: 0.0,
            minChildSize: 0.0,
            maxChildSize: 1.0,
            snap: true,
            snapSizes: [0.0, 1.0],
            builder: (context, scrollController) => PlayerView(
              scrollController: scrollController,
              closeCommand: closePlayerView,
              onSourceTap: navigateToSource,
            ),
          ),
        ),
      ],
    );
  }
}
