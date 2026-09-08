import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/workout_goal_model.dart';

class WorkoutGoalsSection extends StatelessWidget {
  const WorkoutGoalsSection({
    super.key,
    required this.onGoalTap,
    required this.onCreateGoal,
  });

  final Function(WorkoutGoal goal) onGoalTap;
  final VoidCallback onCreateGoal;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final goals = fitnessRepository.workoutGoals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Workout Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isLight
                    ? AppColors.lightTextPrimary
                    : AppColors.darkTextPrimary,
              ),
            ),
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onCreateGoal();
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_circle_outline_rounded,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tạo mục tiêu',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: isLight
                            ? AppColors.primaryBlue
                            : AppColors.primaryBlueLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Goals List or Empty State
        if (goals.isEmpty)
          _buildEmptyState(context, isLight)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: goals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final goal = goals[index];
              return _GoalCard(
                goal: goal,
                isLight: isLight,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onGoalTap(goal);
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isLight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.flag_rounded, size: 32),
          const SizedBox(height: 12),
          Text(
            'Bạn chưa thiết lập mục tiêu tập luyện.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isLight
                  ? AppColors.lightTextPrimary
                  : AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tạo mục tiêu để theo dõi khối lượng tập và tiến độ từng nhóm cơ.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color:
                  isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onCreateGoal,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              '+ Tạo mục tiêu',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.isLight,
    required this.onTap,
  });

  final WorkoutGoal goal;
  final bool isLight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pctInt = goal.progressPercentage.round();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isLight ? 0.02 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: goal.cardColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child:
                    Icon(Icons.flag_rounded, size: 22, color: goal.cardColor),
              ),
            ),
            const SizedBox(width: 14),

            // Middle: Name & Exercise count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Text(
                        '${goal.exerciseCount} Exercise',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isLight
                              ? AppColors.lightTextSecondary
                              : AppColors.darkTextSecondary,
                        ),
                      ),
                      Text(
                        '•',
                        style: TextStyle(
                          fontSize: 12,
                          color: isLight
                              ? AppColors.lightTextMuted
                              : AppColors.darkTextMuted,
                        ),
                      ),
                      Text(
                        '${goal.completedExercises}/${goal.totalExercises} bài xong',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isLight
                              ? AppColors.lightTextMuted
                              : AppColors.darkTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Right: Circular Progress Ring
            SizedBox(
              width: 46,
              height: 46,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: (goal.progressPercentage / 100).clamp(0.0, 1.0),
                    strokeWidth: 4.5,
                    backgroundColor: isLight
                        ? const Color(0xFFE9ECEF)
                        : const Color(0xFF2C2C2E),
                    valueColor: AlwaysStoppedAnimation<Color>(goal.cardColor),
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Text(
                      '$pctInt%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isLight
                            ? AppColors.lightTextPrimary
                            : AppColors.darkTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
