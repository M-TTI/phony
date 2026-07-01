import 'package:flutter/material.dart';
import 'package:phony/themes/theme.dart' as t;

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key, required this.openCommand});

  final GestureTapCallback openCommand;

  @override
  Widget build(BuildContext context) {
    // TODO: final vm = context.watch<PlayerViewModel>();
    return GestureDetector(
      onTap: openCommand,
      child: Container(
        color: t.backgroundMuted,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: 0.4, // TODO: vm.position,
              minHeight: 3,
              backgroundColor: t.background,
              valueColor: AlwaysStoppedAnimation<Color>(t.primary),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                SizedBox(width: 16),
                Expanded(child: Text('Current song playing')),
                IconButton(
                  // TODO: Implement Play Button
                  onPressed: () => {},
                  icon: Icon(Icons.play_arrow_rounded, color: t.onPrimary),
                ),
                SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
