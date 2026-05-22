import 'package:flutter/material.dart';

class IconMapper {
  static const Map<String, IconData> habitIcons = {
    // New Categories
    'nutrition': Icons.restaurant_rounded,
    'water': Icons.water_drop_rounded,
    'exercise': Icons.fitness_center_rounded,
    'technology': Icons.computer_rounded,
    'education': Icons.school_rounded,
    'other': Icons.category_rounded,

    // Old fallbacks for backward compatibility
    'run': Icons.bolt_rounded,
    'book': Icons.auto_stories_rounded,
    'heart': Icons.favorite_rounded,
    'sleep': Icons.nights_stay_rounded,
    'gym': Icons.fitness_center_rounded,
    'food': Icons.restaurant_rounded,
    'mind': Icons.self_improvement_rounded,
    'work': Icons.monetization_on_rounded,
    'music': Icons.music_note_rounded,
    'code': Icons.terminal_rounded,
    'star': Icons.emoji_events_rounded,
    '0xe555': Icons.bolt_rounded,
    '0xe5aa': Icons.science_rounded,
    '0xe0bf': Icons.auto_stories_rounded,
    '0xe25a': Icons.favorite_rounded,
    '0xe418': Icons.nights_stay_rounded,
    '0xe3ae': Icons.fitness_center_rounded,
    '0xe533': Icons.restaurant_rounded,
    '0xe336': Icons.self_improvement_rounded,
    '0xe8f9': Icons.monetization_on_rounded,
    '0xe405': Icons.music_note_rounded,
    '0xe86f': Icons.terminal_rounded,
    '0xe838': Icons.emoji_events_rounded,
  };

  static IconData getIcon(String key) {
    return habitIcons[key] ?? Icons.help_outline_rounded;
  }
}
