import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/side_quest_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/utils/icon_mapper.dart';
import '../../data/models/side_quest_model.dart';
import '../widgets/glass.dart';

class SideQuestTab extends StatelessWidget {
  const SideQuestTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SideQuestProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final quests = provider.todayQuests;
        final completed = quests.where((q) => q.isCompleted).length;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              _buildSummaryCard(context, completed, quests.length),
              _buildSectionHeader(context, quests.length),
              _buildQuestList(context, provider, quests),
              const SizedBox(height: 16),
              _buildHistoryButton(context, provider),
              const SizedBox(height: 120),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Side Quests'.tr(context),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            'Your daily challenges'.tr(context),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: -0.05, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildSummaryCard(BuildContext context, int completed, int total) {
    final rate = total == 0 ? 0.0 : completed / total;
    final percentage = (rate * 100).toStringAsFixed(0);

    final allDone = total > 0 && rate >= 1.0;
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(24, 6, 24, 6),
      padding: const EdgeInsets.all(16),
      glow: allDone,
      glowColor: AppColors.tealGlow,
      child: Row(
        children: [
          const IconBadge(
            icon: Icons.bolt_rounded,
            color: AppColors.teal,
            size: 50,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${"Today's Quests".tr(context)} · $completed/$total',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                GlowProgressBar(rate: rate, height: 7),
              ],
            ),
          ),
          const SizedBox(width: 14),
          GradientText(
            '$percentage%',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: Row(
        children: [
          Text(
            'Today'.tr(context),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 8),
          GlassPillBadge(label: '$count'),
          const Spacer(),
          const _CountdownTimer(),
        ],
      ),
    );
  }

  Widget _buildQuestList(
    BuildContext context,
    SideQuestProvider provider,
    List<SideQuest> quests,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Column(
        children: [
          for (int i = 0; i < quests.length; i++)
            _SideQuestCard(
              quest: quests[i],
              animationDelay: i * 80,
              onTap: () {
                HapticFeedback.lightImpact();
                provider.toggleCompletion(quests[i]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryButton(BuildContext context, SideQuestProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => _HistorySheet(provider: provider),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.glassBorder, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_rounded,
                  color: context.textSecondaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Past Side Quests'.tr(context),
                style: TextStyle(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideQuestCard extends StatelessWidget {
  final SideQuest quest;
  final int animationDelay;
  final VoidCallback onTap;

  const _SideQuestCard({
    required this.quest,
    required this.animationDelay,
    required this.onTap,
  });

  static const Map<String, Color> _difficultyTones = {
    'easy': AppColors.pastelSage,
    'medium': AppColors.pastelAmber,
    'hard': AppColors.pastelTerracotta,
  };

  @override
  Widget build(BuildContext context) {
    final isCompleted = quest.isCompleted;
    final accentColor = AppColors.teal;
    final iconTone = _difficultyTones[quest.difficulty] ?? AppColors.teal;
    final iconData = IconMapper.getIcon(quest.icon);
    final dividerColor =
        Theme.of(context).dividerTheme.color ?? Colors.transparent;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      radius: 18,
      tint: isCompleted ? accentColor : null,
      glow: isCompleted,
      glowColor: accentColor,
      onTap: onTap,
      child: Row(
        children: [
          IconBadge(
            icon: iconData,
            color: iconTone,
            size: 50,
            glow: isCompleted,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title.tr(context),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isCompleted ? context.textSecondaryColor : null,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: context.textTertiaryColor,
                      ),
                ),
                const SizedBox(height: 8),
                _DifficultyBadge(difficulty: quest.difficulty),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? accentColor : Colors.transparent,
              border: Border.all(
                color: isCompleted ? accentColor : dividerColor,
                width: 1.5,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : null,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: animationDelay),
          duration: 400.ms,
          curve: Curves.easeOut,
        )
        .slideX(
          begin: 0.05,
          end: 0,
          delay: Duration(milliseconds: animationDelay),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }
}

/// Small colored pill indicating a quest's difficulty (easy/medium/hard).
class _DifficultyBadge extends StatelessWidget {
  final String difficulty;
  const _DifficultyBadge({required this.difficulty});

  static const Map<String, Color> _colors = {
    'easy': AppColors.pastelSage,
    'medium': AppColors.pastelAmber,
    'hard': AppColors.pastelTerracotta,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[difficulty] ?? AppColors.teal;
    return GlassPillBadge(
      label: difficulty.tr(context).toUpperCase(),
      color: color,
    );
  }
}

class _HistorySheet extends StatelessWidget {
  final SideQuestProvider provider;
  const _HistorySheet({required this.provider});

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _formatDate(String dateKey, BuildContext context) {
    final parts = dateKey.split('-');
    if (parts.length != 3) return dateKey;
    final month = int.tryParse(parts[1]) ?? 1;
    final day = int.tryParse(parts[2]) ?? 1;
    final monthName = _monthNames[(month - 1).clamp(0, 11)].tr(context);
    return '$monthName $day, ${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    final history = provider.history;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Past Side Quests'.tr(context),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          if (history.isEmpty)
            _buildEmptyState(context)
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history[index];
                  return _buildDayGroup(context, entry.key, entry.value);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_rounded,
                  color: AppColors.teal, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'No past quests yet'.tr(context),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Your quests from previous days\nwill appear here.'.tr(context),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.textSecondaryColor,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayGroup(
    BuildContext context,
    String dateKey,
    List<SideQuest> quests,
  ) {
    final completed = quests.where((q) => q.isCompleted).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(dateKey, context),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: context.textSecondaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                '$completed/${quests.length}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final q in quests) _buildHistoryRow(context, q),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(BuildContext context, SideQuest quest) {
    final isCompleted = quest.isCompleted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            isCompleted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: isCompleted ? AppColors.teal : context.textTertiaryColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              quest.title.tr(context),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isCompleted ? context.textSecondaryColor : null,
                    decoration:
                        isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: context.textTertiaryColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownTimer extends StatefulWidget {
  const _CountdownTimer();

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final difference = tomorrow.difference(now);
    if (mounted) {
      setState(() {
        _timeLeft = difference;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _timeLeft.inHours.toString().padLeft(2, '0');
    final minutes = (_timeLeft.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_timeLeft.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.teal.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 14, color: AppColors.teal),
          const SizedBox(width: 6),
          Text(
            '$hours:$minutes:$seconds',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ],
      ),
    );
  }
}
