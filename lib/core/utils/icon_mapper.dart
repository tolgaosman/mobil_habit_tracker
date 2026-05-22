import 'package:flutter/material.dart';

class IconMapper {
  static const Map<String, IconData> habitIcons = {
    'run': Icons.directions_run_rounded,
    'water': Icons.water_drop_rounded,
    'book': Icons.menu_book_rounded,
    'heart': Icons.favorite_rounded,
    'sleep': Icons.bedtime_rounded,
    'gym': Icons.fitness_center_rounded,
    'food': Icons.restaurant_rounded,
    'mind': Icons.self_improvement_rounded,
    'work': Icons.work_outline_rounded,
    'music': Icons.music_note_rounded,
    'code': Icons.code_rounded,
    'star': Icons.star_rounded,

    // Hex fallbacks for backward compatibility
    '0xe555': Icons.directions_run_rounded,
    '0xe5aa': Icons.water_drop_rounded,
    '0xe0bf': Icons.menu_book_rounded,
    '0xe25a': Icons.favorite_rounded,
    '0xe418': Icons.bedtime_rounded,
    '0xe3ae': Icons.fitness_center_rounded,
    '0xe533': Icons.restaurant_rounded,
    '0xe336': Icons.self_improvement_rounded,
    '0xe8f9': Icons.work_outline_rounded,
    '0xe405': Icons.music_note_rounded,
    '0xe86f': Icons.code_rounded,
    '0xe838': Icons.star_rounded,
  };

  static IconData getIcon(String key) {
    return habitIcons[key] ?? Icons.help_outline_rounded;
  }
}
