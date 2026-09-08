import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/fitness_repository.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/models/daily_menu_item.dart';

IconData _iconForMeal(String mealType) {
  if (mealType.contains('sáng')) return Icons.wb_sunny_outlined;
  if (mealType.contains('trưa')) return Icons.light_mode_outlined;
  if (mealType.contains('chiều')) return Icons.wb_twilight_outlined;
  return Icons.nightlight_outlined;
}

class DailyMenuSheet extends StatelessWidget {
  const DailyMenuSheet({
    super.key,
    this.plan = DailyMenuPlan.default2455KcalPlan,
  });

  final DailyMenuPlan plan;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THỰC ĐƠN CHUẨN HÔM NAY',
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
                    'Mục tiêu calo: ${plan.targetKcal} kcal/ngày',
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

          // Total Macro Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  isLight ? const Color(0xFFF8F9FA) : const Color(0xFF242426),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MacroSummary(
                  label: 'Calories',
                  value: plan.targetKcal.toString(),
                  unit: 'kcal',
                  color: AppColors.primaryBlueLight,
                  isLight: isLight,
                ),
                _MacroSummary(
                  label: 'Protein',
                  value: plan.targetProtein.toStringAsFixed(0),
                  unit: 'g',
                  color: AppColors.statusRecovery,
                  isLight: isLight,
                ),
                _MacroSummary(
                  label: 'Carbs',
                  value: plan.targetCarbs.toStringAsFixed(0),
                  unit: 'g',
                  color: AppColors.skyBlue,
                  isLight: isLight,
                ),
                _MacroSummary(
                  label: 'Fat',
                  value: plan.targetFat.toStringAsFixed(0),
                  unit: 'g',
                  color: AppColors.primaryBlueLight,
                  isLight: isLight,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Meals List
          Expanded(
            child: ListView.separated(
              itemCount: plan.meals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final meal = plan.meals[index];
                return _MealItemCard(
                  meal: meal,
                  isLight: isLight,
                  onQuickLog: () {
                    HapticFeedback.lightImpact();
                    fitnessRepository.recordMeal(
                      title: meal.mealType,
                      items: meal.dishName,
                      kcal: meal.kcal,
                      protein: meal.proteinGrams,
                      carbs: meal.carbsGrams,
                      fat: meal.fatGrams,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Đã ghi nhận ${meal.mealType} (+${meal.kcal} kcal)'),
                        backgroundColor: const Color(0xFF151515),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroSummary extends StatelessWidget {
  const _MacroSummary({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.isLight,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isLight
                    ? AppColors.lightTextMuted
                    : AppColors.darkTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted,
          ),
        ),
      ],
    );
  }
}

class _MealItemCard extends StatelessWidget {
  const _MealItemCard({
    required this.meal,
    required this.isLight,
    required this.onQuickLog,
  });

  final DailyMealItem meal;
  final bool isLight;
  final VoidCallback onQuickLog;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF8F9FA) : const Color(0xFF242426),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal Type & Kcal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_iconForMeal(meal.mealType),
                      size: 20, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    meal.mealType,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${meal.servingWeight})',
                    style: TextStyle(
                      fontSize: 11,
                      color: isLight
                          ? AppColors.lightTextMuted
                          : AppColors.darkTextMuted,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${meal.kcal} kcal',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryBlueLight,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: onQuickLog,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Dish Name
          Text(
            meal.dishName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isLight
                  ? AppColors.lightTextPrimary
                  : AppColors.darkTextPrimary,
            ),
          ),

          const SizedBox(height: 8),

          // Macros row
          Row(
            children: [
              _NutrientPill(
                label: 'P: ${meal.proteinGrams.toStringAsFixed(0)}g',
                color: AppColors.statusRecovery,
              ),
              const SizedBox(width: 6),
              _NutrientPill(
                label: 'C: ${meal.carbsGrams.toStringAsFixed(0)}g',
                color: AppColors.skyBlue,
              ),
              const SizedBox(width: 6),
              _NutrientPill(
                label: 'F: ${meal.fatGrams.toStringAsFixed(0)}g',
                color: AppColors.primaryBlueLight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NutrientPill extends StatelessWidget {
  const _NutrientPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
