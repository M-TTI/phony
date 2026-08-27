import 'package:flutter/material.dart';
import 'package:phony/themes/theme.dart' as t;
import 'package:phony/viewmodels/song_viewmodel.dart';
import 'package:provider/provider.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key, required this.title, required this.tabController});

  static const double _progressHeight = 4;

  final String title;
  final TabController tabController;

  @override
  Size get preferredSize => const Size.fromHeight(
    kToolbarHeight + kTextTabBarHeight + _progressHeight,
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () => Scaffold.of(context).openDrawer(),
        icon: const Icon(t.menuIcon, color: t.onPrimary),
      ),
      title: Text(title),
      backgroundColor: t.primary,
      shadowColor: t.shadow,
      elevation: 8,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(
          kTextTabBarHeight + _progressHeight,
        ),
        child: Column(
          mainAxisSize: .min,
          children: [
            SizedBox(
              height: kTextTabBarHeight,
              child: TabBar(
                controller: tabController,
                tabs: const [
                  Tab(text: 'SONGS'),
                  Tab(text: 'PLAYLISTS'),
                  // Tab(text: 'FILES'),
                ],
              ),
            ),
            const _ImportProgressBar(height: _progressHeight),
          ],
        ),
      ),
    );
  }
}

class _ImportProgressBar extends StatelessWidget {
  const _ImportProgressBar({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final ({bool busy, int done, int total}) progress = context
        .select<SongViewmodel, ({bool busy, int done, int total})>(
          (vm) => (
            busy: vm.isScanning || vm.isImporting,
            done: vm.importDone,
            total: vm.importTotal,
          ),
        );

    return SizedBox(
      height: height,
      child: progress.busy
          ? LinearProgressIndicator(
              value: progress.total > 0 ? progress.done / progress.total : null,
              minHeight: height,
            )
          : null,
    );
  }
}
