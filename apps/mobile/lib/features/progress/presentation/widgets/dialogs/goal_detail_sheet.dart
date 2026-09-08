import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/models/workout_goal_model.dart';

class GoalDetailSheet extends StatelessWidget {
  const GoalDetailSheet({
    super.key,
    required this.goal,
  });

  final WorkoutGoal goal;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final pctInt = goal.progressPercentage.round();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isLight ? Colors.black12 : Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header: Icon + Title + Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: goal.cardColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(Icons.flag_rounded,
                          size: 22, color: goal.cardColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isLight
                              ? AppColors.lightTextPrimary
                              : AppColors.darkTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tiến độ mục tiêu: $pctInt%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: goal.cardColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close_rounded,
                  color: isLight
                      ? AppColors.lightTextPrimary
                      : AppColors.darkTextPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Goal Description
          Text(
            goal.description,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isLight
                  ? AppColors.lightTextSecondary
                  : AppColors.darkTextSecondary,
            ),
          ),

          const SizedBox(height: 16),

          // 4-stat metrics grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isLight ? const Color(0xFFF8F9FA) : const Color(0xFF242426),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCol(
                  label: 'Buổi tập',
                  value: '${goal.totalWorkouts}',
                  isLight: isLight,
                ),
                _StatCol(
                  label: 'Tổng Sets',
                  value: '${goal.totalSets}',
                  isLight: isLight,
                ),
                _StatCol(
                  label: 'Tổng Reps',
                  value: '${goal.totalReps}',
                  isLight: isLight,
                ),
                _StatCol(
                  label: 'Tổng Volume',
                  value: '${(goal.totalVolumeKg / 1000).toStringAsFixed(1)}t',
                  isLight: isLight,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Expanded(
            child: ListView(
              children: [
                // 1. Nhóm cơ tác động
                Text(
                  'NHÓM CƠ ĐƯỢC TÁC ĐỘNG',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isLight
                        ? AppColors.lightTextMuted
                        : AppColors.darkTextMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: goal.muscleGroups.map((muscle) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: goal.cardColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        muscle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: goal.cardColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                // 2. Bài tập liên quan
                Text(
                  'CÁC BÀI TẬP TRỌNG TÂM (${goal.relatedExercises.length})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isLight
                        ? AppColors.lightTextMuted
                        : AppColors.darkTextMuted,
                  ),
                ),
                const SizedBox(height: 8),
                ...goal.relatedExercises.map((ex) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isLight
                          ? const Color(0xFFF8F9FA)
                          : const Color(0xFF242426),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isLight
                            ? AppColors.lightBorder
                            : AppColors.darkBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.fitness_center_rounded,
                          size: 16,
                          color: AppColors.statusRecovery,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          ex,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isLight
                                ? AppColors.lightTextPrimary
                                : AppColors.darkTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 18),

                // 3. Lịch sử tập luyện
                Text(
                  'LỊCH SỬ TẬP GẦN ĐÂY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isLight
                        ? AppColors.lightTextMuted
                        : AppColors.darkTextMuted,
                  ),
                ),
                const SizedBox(height: 8),
                ...goal.workoutHistoryNotes.map((note) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: goal.cardColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            note,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: isLight
                                  ? AppColors.lightTextSecondary
                                  : AppColors.darkTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  const _StatCol({
    required this.label,
    required this.value,
    required this.isLight,
  });

  final String label;
  final String value;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: isLight
                ? AppColors.lightTextPrimary
                : AppColors.darkTextPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted,
          ),
        ),
      ],
    );
  }
}
