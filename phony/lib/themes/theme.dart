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
const menuIcon = Icons.menu_rounded;
const moreIcon = Icons.more_vert_rounded;
const checkIcon = Icons.check_rounded;
const addIcon = Icons.add_rounded;
const editIcon = Icons.edit_rounded;
const trashIcon = Icons.delete_rounded;
const playIcon = Icons.play_arrow_rounded;
const pauseIcon = Icons.pause_rounded;
const downloadIcon = Icons.download_rounded;
const settingsIcon = Icons.settings_rounded;
const scanIcon = Icons.radar_rounded;
const playCircleIcon = Icons.play_circle_fill_rounded;
const pauseCircleIcon = Icons.pause_circle_filled_rounded;
const repeatIcon = Icons.repeat_rounded;
const repeatOneIcon = Icons.repeat_one_rounded;
const shuffleIcon = Icons.shuffle_rounded;
const skipIcon = Icons.skip_next_rounded;
const previousIcon = Icons.skip_previous_rounded;
const arrowDownIcon = Icons.keyboard_arrow_down_rounded;
const volumeUpIcon = Icons.volume_up_rounded;
const volumeDownIcon = Icons.volume_down_rounded;
const volumeOffIcon = Icons.volume_off_rounded;

// Buttons
final ButtonStyle _filledButtonStyle = ButtonStyle(
  backgroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) return primaryPressed;
    if (states.contains(WidgetState.hovered)) return primaryHovered;
    return primary;
  }),
  foregroundColor: const WidgetStatePropertyAll(onPrimary),
  shape: const WidgetStatePropertyAll(ContinuousRectangleBorder()),
  padding: const WidgetStatePropertyAll(
    EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  ),
  shadowColor: const WidgetStatePropertyAll(shadow),
  elevation: const WidgetStatePropertyAll(4),
);

ThemeData buildTheme() {
  return ThemeData(
    colorScheme: const ColorScheme(
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
    tabBarTheme: const TabBarThemeData(
      labelColor: onPrimary,
      unselectedLabelColor: onPrimaryMuted,
      indicatorColor: onPrimary,
      dividerColor: Colors.transparent,
    ),
    menuTheme: const MenuThemeData(
      style: MenuStyle(backgroundColor: WidgetStatePropertyAll(backgroundDark)),
    ),
    menuButtonTheme: MenuButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(onPrimary),
        overlayColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return inkHovered;
          if (states.contains(WidgetState.pressed)) return inkPressed;
          return Colors.transparent;
        }),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      hoverColor: primaryHovered,
      splashColor: primaryPressed,
    ),
  );
}
