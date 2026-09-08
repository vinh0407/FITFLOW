import 'package:flutter/material.dart';
import '../../../../../core/fitness_repository.dart';
import '../../../../../core/theme/app_colors.dart';

class DayWorkoutSheet extends StatelessWidget {
  const DayWorkoutSheet({
    super.key,
    required this.date,
  });

  final DateTime date;

  String _formatDate(DateTime d) {
    return 'Ngày ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final detail = fitnessRepository.getWorkoutDetailForDate(date);

    return Container(
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

          // Header: Date & Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isLight
                          ? AppColors.lightTextMuted
                          : AppColors.darkTextMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail.hasWorkout ? detail.title : 'Ngày nghỉ (Rest Day)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
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

          const SizedBox(height: 16),
          Divider(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            height: 1,
          ),
          const SizedBox(height: 16),

          if (!detail.hasWorkout) ...[
            // Rest Day View
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    isLight ? const Color(0xFFF8F9FA) : const Color(0xFF242426),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
                ),
              ),
              child: Column(
                children: [
                  const Text('🌿', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 12),
                  Text(
                    'Không có lịch tập trong ngày này',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detail.restNotes,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isLight
                          ? AppColors.lightTextSecondary
                          : AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Workout Summary Stats
            Row(
              children: [
                _StatBadge(
                  label: 'Thời gian',
                  value: '${detail.durationMinutes} phút',
                  icon: Icons.timer_outlined,
                  isLight: isLight,
                ),
                const SizedBox(width: 8),
                _StatBadge(
                  label: 'Calo tiêu hao',
                  value: '${detail.caloriesBurned} kcal',
                  icon: Icons.local_fire_department_outlined,
                  isLight: isLight,
                ),
                const SizedBox(width: 8),
                _StatBadge(
                  label: 'Volume',
                  value:
                      '${(detail.totalVolumeKg / 1000).toStringAsFixed(1)} tấn',
                  icon: Icons.fitness_center_outlined,
                  isLight: isLight,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              'CÁC BÀI TẬP ĐÃ THỰC HIỆN (${detail.exercises.length})',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isLight
                    ? AppColors.lightTextMuted
                    : AppColors.darkTextMuted,
              ),
            ),

            const SizedBox(height: 12),

            // Exercises list
            ...detail.exercises.map((ex) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isLight
                      ? const Color(0xFFF8F9FA)
                      : const Color(0xFF242426),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        isLight ? AppColors.lightBorder : AppColors.darkBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: AppColors.statusRecovery,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ex.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isLight
                                    ? AppColors.lightTextPrimary
                                    : AppColors.darkTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${ex.sets} hiệp × ${ex.reps} lần • ${ex.weightKg.toStringAsFixed(0)} kg',
                              style: TextStyle(
                                fontSize: 12,
                                color: isLight
                                    ? AppColors.lightTextMuted
                                    : AppColors.darkTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (ex.isPr)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.skyBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PR',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.skyBlue,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.value,
    required this.icon,
    required this.isLight,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isLight ? const Color(0xFFF8F9FA) : const Color(0xFF242426),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
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
                fontSize: 10,
                color: isLight
                    ? AppColors.lightTextMuted
                    : AppColors.darkTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
