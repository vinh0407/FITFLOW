import 'package:flutter/material.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/workout_goal_model.dart';

import '../widgets/overall_stats_header.dart';
import '../widgets/current_weight_card.dart';
import '../widgets/workout_goals_section.dart';
import '../widgets/body_muscle_recovery_section.dart';

import '../widgets/dialogs/goal_detail_sheet.dart';
import '../widgets/dialogs/add_weight_sheet.dart';
import '../widgets/dialogs/create_goal_sheet.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  void initState() {
    super.initState();
    fitnessRepository.addListener(_refresh);
  }

  @override
  void dispose() {
    fitnessRepository.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _openGoalDetail(WorkoutGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalDetailSheet(goal: goal),
    );
  }

  void _openAddWeight() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddWeightSheet(),
    );
  }

  void _openCreateGoal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateGoalSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight ? AppColors.lightBg : AppColors.darkBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            // 1. Overall Stats Header
            OverallStatsHeader(
              onMenuTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tuỳ chọn phân tích & Xuất dữ liệu'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 2. Current Weight Card with Dynamic Percentage & Chart
            CurrentWeightCard(
              onLogWeight: _openAddWeight,
            ),

            const SizedBox(height: 24),

            // 3. Workout Goals Section
            WorkoutGoalsSection(
              onGoalTap: _openGoalDetail,
              onCreateGoal: _openCreateGoal,
            ),

            if (fitnessRepository.history.isEmpty) ...[
              const SizedBox(height: 16),
              _HistoryEmptyState(isLight: isLight),
            ],

            const SizedBox(height: 24),

            // 4. Body Muscle Recovery & 1RM Progression Section
            const BodyMuscleRecoverySection(),
          ],
        ),
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState({required this.isLight});

  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final muted = isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted;
    final primary =
        isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.history_toggle_off,
              color: AppColors.primaryBlue, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chưa có lịch sử tập',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, color: primary)),
                const SizedBox(height: 4),
                Text('Hoàn thành buổi tập đầu tiên để xem tiến độ của bạn.',
                    style: TextStyle(fontSize: 12, color: muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
