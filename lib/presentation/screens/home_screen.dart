import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/habit_provider.dart';
import '../../core/providers/language_provider.dart';
import '../widgets/week_calendar.dart';
import '../widgets/habit_list.dart';
import '../widgets/progress_header.dart';
import '../widgets/glass.dart';
import 'add_habit_screen.dart';
import 'profile_screen.dart';
import 'history_tab.dart';
import 'side_quest_tab.dart';

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
        bottom: false,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHabitsTab(context),
            const HistoryTab(),
            const SideQuestTab(),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHabitsTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(context),
          const ProgressHeader(),
          const WeekCalendar(),
          _buildHeatmap(context),
          const SizedBox(height: 8),
          _buildSectionHeader(context),
          const HabitList(),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final name = user?.name ?? '';
    final dateLabel = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel.tr(context).toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: context.textTertiaryColor,
                        letterSpacing: 1.0,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  _greeting(name, context),
                  style: Theme.of(context).textTheme.displayMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildAvatarButton(context, user),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 450.ms)
        .slideY(begin: -0.08, end: 0, duration: 450.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildAvatarButton(BuildContext context, dynamic user) {
    final hasImage =
        user?.profileImagePath != null && user!.profileImagePath!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      },
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.glassBorder, width: 1),
        ),
        child: ClipOval(
          child: hasImage
              ? Image.file(
                  File(user.profileImagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildDefaultAvatar(),
                )
              : _buildDefaultAvatar(),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.teal.withValues(alpha: 0.14),
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.teal,
        size: 22,
      ),
    );
  }

  Widget _buildHeatmap(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        if (provider.allHabits.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: context.glassDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last 12 weeks'.tr(context),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: context.textSecondaryColor,
                    ),
              ),
              const SizedBox(height: 14),
              CompletionHeatmap(
                habits: provider.allHabits,
                startingDate: provider.getStartingDate(),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 250.ms, duration: 500.ms)
            .slideY(begin: 0.08, end: 0, delay: 250.ms, duration: 500.ms);
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
      child: Consumer<HabitProvider>(
        builder: (context, provider, _) {
          final count = provider.habits.length;
          return Row(
            children: [
              Text(
                'Today'.tr(context),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(width: 8),
              GlassPillBadge(label: '$count'),
            ],
          );
        },
      ),
    );
  }

  Widget? _buildFAB(BuildContext context) {
    if (_currentIndex == 1 || _currentIndex == 2) return null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showAddHabit(context);
        },
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          'New Habit'.tr(context),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 350.ms).slideY(
        begin: 0.4, end: 0, delay: 300.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: context.glassBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.check_circle_outline_rounded, 'Habits'),
              _buildNavItem(1, Icons.calendar_today_rounded, 'History'),
              _buildNavItem(2, Icons.auto_awesome_outlined, 'Side Quests'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.teal : context.textTertiaryColor;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_currentIndex != index) {
            HapticFeedback.selectionClick();
            setState(() => _currentIndex = index);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 23),
              const SizedBox(height: 5),
              Text(
                label.tr(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ],
          ),
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
    final displayName = name.isNotEmpty ? name : 'there';
    if (hour >= 5 && hour < 12) {
      return 'Good Morning, $displayName'.tr(context);
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon, $displayName'.tr(context);
    } else if (hour >= 17 && hour < 22) {
      return 'Good Evening, $displayName'.tr(context);
    } else {
      return 'Good Night, $displayName'.tr(context);
    }
  }
}
