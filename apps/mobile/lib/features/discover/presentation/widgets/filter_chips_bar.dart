import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/discover_filter_model.dart';

class FilterChipsBar extends StatelessWidget {
  const FilterChipsBar({
    super.key,
    required this.filter,
    required this.onFilterChanged,
    required this.onOpenAdvancedFilter,
  });

  final DiscoverFilter filter;
  final ValueChanged<DiscoverFilter> onFilterChanged;
  final VoidCallback onOpenAdvancedFilter;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final quickChips = <Map<String, dynamic>>[
      {'type': 'all', 'label': 'Tất cả', 'isSelected': !filter.hasActiveFilter},
      {
        'type': 'goal',
        'value': 'Hypertrophy',
        'label': 'Tăng cơ (Hypertrophy)',
        'isSelected': filter.selectedGoal == 'Hypertrophy'
      },
      {
        'type': 'goal',
        'value': 'Strength',
        'label': 'Sức mạnh (Strength)',
        'isSelected': filter.selectedGoal == 'Strength'
      },
      {
        'type': 'goal',
        'value': 'Powerbuilding',
        'label': 'Powerbuilding',
        'isSelected': filter.selectedGoal == 'Powerbuilding'
      },
      {
        'type': 'goal',
        'value': 'Fat Loss',
        'label': 'Đốt mỡ (Fat Loss)',
        'isSelected': filter.selectedGoal == 'Fat Loss'
      },
      {
        'type': 'diff',
        'value': 'Beginner',
        'label': 'Người mới',
        'isSelected': filter.selectedDifficulty == 'Beginner'
      },
      {
        'type': 'diff',
        'value': 'Intermediate',
        'label': 'Trung cấp',
        'isSelected': filter.selectedDifficulty == 'Intermediate'
      },
      {
        'type': 'diff',
        'value': 'Advanced',
        'label': 'Nâng cao',
        'isSelected': filter.selectedDifficulty == 'Advanced'
      },
      {
        'type': 'freq',
        'value': 5,
        'label': '5 ngày/tuần',
        'isSelected': filter.selectedFrequency == 5
      },
      {
        'type': 'freq',
        'value': 4,
        'label': '4 ngày/tuần',
        'isSelected': filter.selectedFrequency == 4
      },
      {
        'type': 'freq',
        'value': 3,
        'label': '3 ngày/tuần',
        'isSelected': filter.selectedFrequency == 3
      },
    ];

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // 1. Advanced Filters Button
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onOpenAdvancedFilter();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: filter.hasActiveFilter
                    ? AppColors.primaryBlue
                    : (isLight
                        ? AppColors.lightSurface
                        : AppColors.darkSurface),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: filter.hasActiveFilter
                      ? AppColors.primaryBlue
                      : (isLight
                          ? AppColors.lightBorder
                          : AppColors.darkBorder),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 15,
                    color: filter.hasActiveFilter
                        ? Colors.white
                        : (isLight
                            ? AppColors.lightTextPrimary
                            : AppColors.darkTextPrimary),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: filter.hasActiveFilter
                          ? Colors.white
                          : (isLight
                              ? AppColors.lightTextPrimary
                              : AppColors.darkTextPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Quick Filter Chips
          ...quickChips.map((chip) {
            final isSelected = chip['isSelected'] == true;
            final label = chip['label'] as String;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  final type = chip['type'] as String;
                  if (type == 'all') {
                    onFilterChanged(const DiscoverFilter());
                  } else if (type == 'goal') {
                    final val = chip['value'] as String;
                    onFilterChanged(
                      filter.copyWith(
                        selectedGoal: () => isSelected ? null : val,
                      ),
                    );
                  } else if (type == 'diff') {
                    final val = chip['value'] as String;
                    onFilterChanged(
                      filter.copyWith(
                        selectedDifficulty: () => isSelected ? null : val,
                      ),
                    );
                  } else if (type == 'freq') {
                    final val = chip['value'] as int;
                    onFilterChanged(
                      filter.copyWith(
                        selectedFrequency: () => isSelected ? null : val,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isLight ? const Color(0xFF151515) : Colors.white)
                        : (isLight
                            ? AppColors.lightSurface
                            : AppColors.darkSurface),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : (isLight
                              ? AppColors.lightBorder
                              : AppColors.darkBorder),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w600,
                        color: isSelected
                            ? (isLight ? Colors.white : Colors.black)
                            : (isLight
                                ? AppColors.lightTextSecondary
                                : AppColors.darkTextSecondary),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
