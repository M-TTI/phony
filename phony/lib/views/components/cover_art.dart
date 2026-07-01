import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phony/themes/theme.dart' as t;

class CoverArt extends StatelessWidget {
  const CoverArt({super.key, required this.size, this.imagePath});

  final double size;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(4);
    final Widget placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: t.backgroundMuted, borderRadius: radius),
    );

    if (imagePath == null) return placeholder;

    return ClipRRect(
      borderRadius: radius,
      child: Image.file(
        File(imagePath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}
