import 'package:flutter/material.dart';
import 'package:phony/themes/theme.dart' as t;

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key, required this.title, required this.tabController});

  final String title;
  final TabController tabController;

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () => Scaffold.of(context).openDrawer(),
        icon: Icon(t.menuIcon, color: t.onPrimary),
      ),
      title: Text(title),
      backgroundColor: t.primary,
      shadowColor: t.shadow,
      elevation: 8,
      bottom: TabBar(
        controller: tabController,
        tabs: const [
          Tab(text: 'SONGS'),
          Tab(text: 'PLAYLISTS'),
          // Tab(text: 'FILES'),
        ],
      ),
    );
  }
}
