import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WorkoutCompletePage extends StatelessWidget {
  const WorkoutCompletePage({
    super.key,
    required this.workoutTitle,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.totalVolumeKg,
    required this.totalSets,
    required this.exerciseCount,
  });

  final String workoutTitle;
  final int durationMinutes;
  final int caloriesBurned;
  final int totalVolumeKg;
  final int totalSets;
  final int exerciseCount;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryAccent =
        isLight ? AppColors.primaryBlue : AppColors.primaryBlueLight;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Celebration Trophy / Badge
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryAccent.withValues(alpha: 0.2),
                      primaryAccent.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryAccent, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: primaryAccent.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 52,
                    color: primaryAccent,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title: WORKOUT COMPLETE!
              Text(
                'HOÀN THÀNH BUỔI TẬP!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isLight
                      ? AppColors.lightTextPrimary
                      : AppColors.darkTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                workoutTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isLight
                      ? AppColors.lightTextSecondary
                      : AppColors.darkTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Summary Stats Card Grid
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:
                      isLight ? AppColors.lightSurface : AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color:
                        isLight ? AppColors.lightBorder : AppColors.darkBorder,
                  ),
                  boxShadow: isLight
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricItem(
                          '$durationMinutes',
                          'Phút',
                          'Thời gian',
                          Icons.timer_outlined,
                          isLight,
                        ),
                        Container(
                          width: 1,
                          height: 44,
                          color: isLight
                              ? AppColors.lightBorder
                              : AppColors.darkBorder,
                        ),
                        _metricItem(
                          '$caloriesBurned',
                          'kcal',
                          'Calo đốt',
                          Icons.local_fire_department_outlined,
                          isLight,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(
                        height: 1,
                        color: isLight
                            ? AppColors.lightBorder
                            : AppColors.darkBorder,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricItem(
                          '$totalVolumeKg',
                          'kg',
                          'Tổng Volume',
                          Icons.fitness_center_outlined,
                          isLight,
                        ),
                        Container(
                          width: 1,
                          height: 44,
                          color: isLight
                              ? AppColors.lightBorder
                              : AppColors.darkBorder,
                        ),
                        _metricItem(
                          '$totalSets',
                          'Hiệp',
                          '$exerciseCount Bài tập',
                          Icons.check_circle_outline_rounded,
                          isLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Action: DONE / Return to Home
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAccent,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'HOÀN TẤT VÀ LƯU VÀO NHẬT KÝ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricItem(
    String value,
    String unit,
    String label,
    IconData icon,
    bool isLight,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isLight
                    ? AppColors.lightTextPrimary
                    : AppColors.darkTextPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              unit,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isLight
                    ? AppColors.lightTextSecondary
                    : AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted,
          ),
        ),
      ],
    );
  }
}
