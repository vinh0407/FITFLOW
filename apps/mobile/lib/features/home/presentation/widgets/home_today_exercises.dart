import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/today_exercise_item.dart';

class HomeTodayExercises extends StatelessWidget {
  const HomeTodayExercises({
    super.key,
    required this.onStartWorkout,
  });

  final VoidCallback onStartWorkout;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final exercises = fitnessRepository.todayExercises;
    final completedCount = exercises.where((e) => e.isCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  const Icon(Icons.fitness_center_rounded, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                      child: Text(
                    'BÀI TẬP HÔM NAY',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
                  )),
                ],
              ),
            ),
            if (exercises.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: completedCount == exercises.length
                      ? AppColors.statusRecovery.withValues(alpha: 0.15)
                      : (isLight
                          ? const Color(0xFFF1F3F5)
                          : const Color(0xFF2C2C2E)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount / ${exercises.length} xong',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: completedCount == exercises.length
                        ? AppColors.statusRecovery
                        : (isLight
                            ? AppColors.lightTextSecondary
                            : AppColors.darkTextSecondary),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        // 2. Exercise List or Friendly Empty State
        if (exercises.isEmpty)
          _buildEmptyState(context, isLight)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exercises.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = exercises[index];
              return _ExerciseCard(
                item: item,
                isLight: isLight,
                onToggle: () {
                  HapticFeedback.mediumImpact();
                  fitnessRepository.toggleExerciseCompleted(item.id);
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
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.fitness_center_rounded,
                color: AppColors.primaryBlue,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Bạn chưa có bài tập hôm nay.',
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
            'Bắt đầu buổi tập để ghi nhận kỷ lục và duy trì streak của bạn!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color:
                  isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              onStartWorkout();
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text(
              '+ Bắt đầu tập',
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

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.item,
    required this.isLight,
    required this.onToggle,
  });

  final TodayExerciseItem item;
  final bool isLight;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isCompleted
              ? AppColors.statusRecovery.withValues(alpha: 0.3)
              : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Left status pillar / indicator
          Container(
            width: 4,
            height: 38,
            decoration: BoxDecoration(
              color: item.isCompleted
                  ? AppColors.statusRecovery
                  : AppColors.primaryBlueLight,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),

          // Exercise Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    decoration:
                        item.isCompleted ? TextDecoration.lineThrough : null,
                    color: item.isCompleted
                        ? (isLight
                            ? AppColors.lightTextMuted
                            : AppColors.darkTextMuted)
                        : (isLight
                            ? AppColors.lightTextPrimary
                            : AppColors.darkTextPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Text(
                      item.muscleGroup,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isLight
                            ? AppColors.lightTextSecondary
                            : AppColors.darkTextSecondary,
                      ),
                    ),
                    const SizedBox(width: 0),
                    Text(
                      '•',
                      style: TextStyle(
                        fontSize: 11,
                        color: isLight
                            ? AppColors.lightTextMuted
                            : AppColors.darkTextMuted,
                      ),
                    ),
                    const SizedBox(width: 0),
                    Text(
                      '${item.sets} sets × ${item.reps} reps',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isLight
                            ? AppColors.lightTextMuted
                            : AppColors.darkTextMuted,
                      ),
                    ),
                    const SizedBox(width: 0),
                    Text(
                      '•',
                      style: TextStyle(
                        fontSize: 11,
                        color: isLight
                            ? AppColors.lightTextMuted
                            : AppColors.darkTextMuted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item.weightKg.toStringAsFixed(0)} kg',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlueLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Completion Toggle Checkbox
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.isCompleted
                    ? AppColors.statusRecovery
                    : (isLight
                        ? const Color(0xFFF1F3F5)
                        : const Color(0xFF2C2C2E)),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: item.isCompleted
                      ? AppColors.statusRecovery
                      : (isLight
                          ? AppColors.lightBorder
                          : AppColors.darkBorder),
                ),
              ),
              child: Center(
                child: Icon(
                  item.isCompleted
                      ? Icons.check_rounded
                      : Icons.circle_outlined,
                  size: 20,
                  color: item.isCompleted
                      ? Colors.white
                      : (isLight
                          ? AppColors.lightTextMuted
                          : AppColors.darkTextMuted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
