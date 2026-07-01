import 'package:flutter/material.dart';

// Colors
const background = Color(0xFF433D56);
const backgroundMuted = Color(0xFF675F81);
const backgroundDark = Color(0xFF353045);
const primary = Color(0xFFFF2E7E);
const primaryHovered = Color(0xFF9E3158);
const primaryPressed = Color(0xFFFF6BA3);
const accent = Color(0xFF097EDE);
const error = Color(0xFFE12D39);
const onPrimary = Color(0xFFFFE5EE);
const onPrimaryMuted = Color(0xFFC8A9B4);
const border = Color(0xFFBDBDBD);
const black = Color(0xFF000000);
const shadow = Color(0x40000000);
const inkHovered = Color(0x0DFFFFFF);
const inkPressed = Color(0x19FFFFFF);

// Icons
const menuIcon = Icons.menu;
const moreIcon = Icons.more_vert;

// Buttons

final ButtonStyle _filledButtonStyle = ButtonStyle(
  backgroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) return primaryPressed;
    if (states.contains(WidgetState.hovered)) return primaryHovered;
    return primary;
  }),
  foregroundColor: WidgetStatePropertyAll(onPrimary),
  shape: WidgetStatePropertyAll(const ContinuousRectangleBorder()),
  padding: WidgetStatePropertyAll(
    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  ),
  shadowColor: WidgetStatePropertyAll(shadow),
  elevation: WidgetStatePropertyAll(4),
);

ThemeData buildTheme() {
  return ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: background,
      onPrimaryContainer: onPrimary,
      secondaryContainer: backgroundMuted,
      error: error,
      onError: onPrimary,
      surface: background,
      onSurface: onPrimary,
      onSurfaceVariant: onPrimaryMuted,
      outline: border,
      secondary: accent,
      onSecondary: onPrimary,
    ),
    filledButtonTheme: FilledButtonThemeData(style: _filledButtonStyle),
  );
}
