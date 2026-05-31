import 'package:flutter/material.dart';
import 'package:phony/themes/theme.dart' as t;

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: t.backgroundMuted,
      child: Row(
        children: [
          SizedBox(width: 16),
          Expanded(
            child: Text('Current song playing'),
          ),
          IconButton(
            // TODO: Implement Play Button
            onPressed: () => {},
            icon: Icon(
              Icons.play_arrow_rounded,
              color: t.onPrimary,
            ),
            onHover: null,
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }
}