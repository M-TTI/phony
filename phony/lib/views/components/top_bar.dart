import 'package:flutter/material.dart';
import 'package:phony/themes/theme.dart' as t;
import 'package:phony/viewmodels/song_viewmodel.dart';
import 'package:provider/provider.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  const TopBar({super.key, required this.title, required this.tabController});

  static const double _progressHeight = 4;

  final String title;
  final TabController tabController;

  @override
  State<TopBar> createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(
    kToolbarHeight + kTextTabBarHeight + TopBar._progressHeight,
  );
}

class _TopBarState extends State<TopBar> {
  static const int _songsTabIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (widget.tabController.index != _songsTabIndex && _searching) {
      _closeSearch();
      return;
    }

    setState(() {});
  }

  void _openSearch() => setState(() {
    _searching = true;
  });

  void _closeSearch() {
    _searchController.clear();
    context.read<SongViewmodel>().setQuery('');
    setState(() {
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool onSongsTab = widget.tabController.index == _songsTabIndex;
    final bool showSearchField = _searching && onSongsTab;

    return AppBar(
      leading: IconButton(
        onPressed: () => Scaffold.of(context).openDrawer(),
        icon: const Icon(t.menuIcon, color: t.onPrimary),
      ),
      title: showSearchField
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: t.onPrimary),
              cursorColor: t.onPrimary,
              decoration: const InputDecoration(
                hintText: 'Search songs',
                hintStyle: TextStyle(color: t.onPrimaryMuted),
                border: .none,
              ),
              onChanged: (String value) =>
                  context.read<SongViewmodel>().setQuery(value),
            )
          : Text(widget.title),
      actions: [
        if (onSongsTab)
          IconButton(
            onPressed: showSearchField ? _closeSearch : _openSearch,
            icon: Icon(showSearchField ? t.closeIcon : t.searchIcon),
            color: t.onPrimary,
          ),
      ],
      backgroundColor: t.primary,
      shadowColor: t.shadow,
      elevation: 8,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(
          kTextTabBarHeight + TopBar._progressHeight,
        ),
        child: Column(
          mainAxisSize: .min,
          children: [
            SizedBox(
              height: kTextTabBarHeight,
              child: TabBar(
                controller: widget.tabController,
                tabs: const [
                  Tab(text: 'SONGS'),
                  Tab(text: 'PLAYLISTS'),
                  // Tab(text: 'FILES'),
                ],
              ),
            ),
            const _ImportProgressBar(height: TopBar._progressHeight),
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
