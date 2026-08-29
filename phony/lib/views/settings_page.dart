import 'package:flutter/material.dart';
import 'package:phony/themes/theme.dart' as t;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: t.onPrimary),
        title: const Text('Settings'),
        backgroundColor: t.primary,
        shadowColor: t.shadow,
        elevation: 8,
      ),
      body: const Center(child: Text('No settings for now')),
    );
  }
}
