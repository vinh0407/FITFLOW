import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';

class HomeNutritionCard extends StatelessWidget {
  const HomeNutritionCard({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final targetKcal = fitnessRepository.targetDailyCalories;
    final consumedKcal = fitnessRepository.todayConsumedCalories;
    final remainingKcal = (targetKcal - consumedKcal).clamp(0, targetKcal);
    final progress = (consumedKcal / targetKcal).clamp(0.0, 1.0);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header & Icon
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            AppColors.primaryBlueGlow.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(Icons.restaurant_outlined,
                            color: AppColors.primaryBlue, size: 18),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                        child: Text(
                      'DINH DƯỠNG HÔM NAY',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isLight
                            ? AppColors.lightTextPrimary
                            : AppColors.darkTextPrimary,
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusRecovery.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Còn ${remainingKcal.toString()} kcal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isLight
                          ? AppColors.primaryBlue
                          : AppColors.statusRecovery,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 2. Large Target & Consumed Info
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${targetKcal.toString()} kcal',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        height: 1.1,
                        color: isLight
                            ? AppColors.lightTextPrimary
                            : AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mục tiêu calo hàng ngày',
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
                Text(
                  '${consumedKcal.toString()} / ${targetKcal.toString()} kcal',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isLight
                        ? AppColors.lightTextSecondary
                        : AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 3. Smooth Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    color: isLight
                        ? const Color(0xFFE9ECEF)
                        : const Color(0xFF2C2C2E),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 12,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.skyBlue,
                            AppColors.primaryBlueLight
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Tap action row
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Thực đơn đề xuất: 6 bữa chuẩn hóa',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isLight
                        ? AppColors.lightTextMuted
                        : AppColors.darkTextMuted,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                        child: Text(
                      'Xem thực đơn',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: isLight
                            ? AppColors.primaryBlue
                            : AppColors.primaryBlueLight,
                      ),
                    )),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: isLight
                          ? AppColors.primaryBlue
                          : AppColors.primaryBlueLight,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
