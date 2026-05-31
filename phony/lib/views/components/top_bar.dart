import 'package:flutter/material.dart';
import 'package:phony/themes/theme.dart' as t;

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: IconButton(
            // TODO: Implement Menu Button
            onPressed: () => {},
            icon: Icon(
              t.menuIcon,
              color: t.onPrimary,
            ),
          ),
          title: Text(title),
          backgroundColor: t.primary,
          shadowColor: t.shadow,
          elevation: 8,
        ),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                // TODO: Implement Songs Button
                onPressed: () => {},
                child: Text(
                  'SONGS',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            Expanded(
              child: FilledButton(
                // TODO: Implement Songs Button
                onPressed: () => {},
                child: Text(
                  'SONGS',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            Expanded(
              child: FilledButton(
                // TODO: Implement Songs Button
                onPressed: () => {},
                child: Text(
                  'SONGS',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}