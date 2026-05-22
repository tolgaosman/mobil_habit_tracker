import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/habit_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/language_provider.dart';
import '../widgets/week_calendar.dart';
import '../widgets/habit_list.dart';
import '../widgets/progress_header.dart';
import 'add_habit_screen.dart';
import 'profile_screen.dart';
import 'history_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHabitsTab(context),
            const HistoryTab(),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHabitsTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopBar(context),
        const ProgressHeader(),
        const WeekCalendar(),
        const SizedBox(height: 8),
        _buildSectionHeader(context),
        const Expanded(child: HabitList()),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final name = user?.name ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(name, context),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.textSecondaryColor,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'Your Habits'.tr(context),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
              ),
            ],
          ),
          const Spacer(),
          _buildLanguageSelector(context),
          const SizedBox(width: 8),
          _buildAvatarButton(context, user),
        ],
      ),
    );
  }
  Widget _buildLanguageSelector(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final currentLang = langProvider.currentLanguage;

    final langNames = {
      'en': 'English',
      'tr': 'Turkish',
      'de': 'German',
      'fr': 'French',
      'it': 'Italian',
    };
    final dividerColor = Theme.of(context).dividerTheme.color ?? Colors.black;

    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: Theme.of(context).cardTheme.color,
      ),
      child: PopupMenuButton<String>(
        onSelected: (String langCode) {
          HapticFeedback.mediumImpact();
          langProvider.changeLanguage(langCode);
        },
        offset: const Offset(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: dividerColor, width: 2),
        ),
        itemBuilder: (BuildContext context) {
          return langNames.entries.map((entry) {
            final isSelected = entry.key == currentLang;
            return PopupMenuItem<String>(
              value: entry.key,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.value.tr(context),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.teal : null,
                      fontSize: 14,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_rounded, color: AppColors.teal, size: 16),
                  ],
                ],
              ),
            );
          }).toList();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: dividerColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: dividerColor,
                offset: const Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                langNames[currentLang]!.tr(context),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down_rounded, size: 18, color: dividerColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarButton(BuildContext context, dynamic user) {
    final hasImage = user?.profileImagePath != null && user!.profileImagePath!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.teal, width: 1.5),
        ),
        child: ClipOval(
          child: hasImage
              ? Image.file(
                  File(user.profileImagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                )
              : _buildDefaultAvatar(),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.teal, AppColors.violet],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: Consumer<HabitProvider>(
        builder: (context, provider, _) {
          final count = provider.habits.length;
          return Row(
            children: [
              Text(
                'Today'.tr(context),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: context.textSecondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget? _buildFAB(BuildContext context) {
    if (_currentIndex == 1) return null;
    final dividerColor = Theme.of(context).dividerTheme.color ?? Colors.black;
    const label = 'NEW QUEST';
    const icon = Icons.add_box_rounded;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showAddHabit(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.teal,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: dividerColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: dividerColor,
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.black, size: 22),
            const SizedBox(width: 8),
            Text(
              label.tr(context),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), curve: Curves.easeOutBack);
  }

  Widget _buildBottomNavBar() {
    final dividerColor = Theme.of(context).dividerTheme.color ?? Colors.black;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomSheetTheme.backgroundColor,
        border: Border(
          top: BorderSide(color: dividerColor, width: 3),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.track_changes_rounded, 'TASKS'),
              _buildNavItem(1, Icons.calendar_month_rounded, 'HISTORY'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final dividerColor = Theme.of(context).dividerTheme.color ?? Colors.black;

    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          HapticFeedback.selectionClick();
          setState(() {
            _currentIndex = index;
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: dividerColor, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: dividerColor,
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextTertiary : AppColors.textSecondary),
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              label.tr(context),
              style: TextStyle(
                color: isSelected ? Colors.black : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextTertiary : AppColors.textSecondary),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHabit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddHabitSheet(),
    );
  }


  String _greeting(String name, BuildContext context) {
    final hour = DateTime.now().hour;
    final displayName = name.isNotEmpty ? name : 'Player 1';
    if (hour >= 5 && hour < 12) {
      return 'Good Morning, $displayName 🌅'.tr(context);
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon, $displayName ☀️'.tr(context);
    } else if (hour >= 17 && hour < 22) {
      return 'Good Evening, $displayName 🌆'.tr(context);
    } else {
      return 'Good Night, $displayName 🌌'.tr(context);
    }
  }
}
