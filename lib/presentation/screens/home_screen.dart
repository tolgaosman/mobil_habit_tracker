import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/habit_provider.dart';
import '../widgets/week_calendar.dart';
import '../widgets/habit_list.dart';
import '../widgets/progress_header.dart';
import 'add_habit_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            const ProgressHeader(),
            const WeekCalendar(),
            const SizedBox(height: 8),
            _buildSectionHeader(context),
            const Expanded(child: HabitList()),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
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
                _greeting(name),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'Your Habits',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
              ),
            ],
          ),
          const Spacer(),
          _buildAvatarButton(context, user),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, curve: Curves.easeOut)
        .slideY(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOut);
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
                'Today',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
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
                  color: AppColors.teal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.teal,
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

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddHabit(context),
      icon: const Icon(Icons.add_rounded, size: 22),
      label: const Text(
        'New Habit',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      ),
      backgroundColor: AppColors.teal,
      foregroundColor: AppColors.background,
      elevation: 0,
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 400.ms)
        .slideY(begin: 0.5, end: 0, delay: 600.ms, duration: 400.ms);
  }

  void _showAddHabit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddHabitSheet(),
    );
  }

  String _greeting(String name) {
    final hour = DateTime.now().hour;
    final displayName = name.isNotEmpty ? ', $name' : '';
    if (hour < 12) return 'Good morning$displayName 🌤';
    if (hour < 17) return 'Good afternoon$displayName ☀️';
    return 'Good evening$displayName 🌙';
  }
}
