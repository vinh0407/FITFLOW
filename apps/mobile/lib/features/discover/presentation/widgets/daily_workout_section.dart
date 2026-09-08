import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../workout/presentation/pages/active_workout_page.dart';

class DailyWorkoutSection extends StatefulWidget {
  const DailyWorkoutSection({super.key});

  @override
  State<DailyWorkoutSection> createState() => _DailyWorkoutSectionState();
}

class _DailyWorkoutSectionState extends State<DailyWorkoutSection> {
  int _selectedDayIndex = 0; // 0: Thứ 2 ... 6: Chủ Nhật

  static const _days = [
    {
      'day': 'T2',
      'full': 'Thứ 2',
      'name': 'Chest & Triceps Push',
      'muscles': ['Ngực', 'Tay sau', 'Vai trước'],
      'exercises': [
        'Bench Press (4x8)',
        'Incline DB Press (3x10)',
        'Tricep Pushdown (3x15)'
      ],
      'duration': '55 phút',
      'isRest': false,
    },
    {
      'day': 'T3',
      'full': 'Thứ 3',
      'name': 'Back & Biceps Pull',
      'muscles': ['Lưng', 'Tay trước'],
      'exercises': [
        'Deadlift (4x5)',
        'Lat Pulldown (4x10)',
        'Barbell Curl (3x12)'
      ],
      'duration': '50 phút',
      'isRest': false,
    },
    {
      'day': 'T4',
      'full': 'Thứ 4',
      'name': 'Legs & Glutes Power',
      'muscles': ['Đùi trước', 'Đùi sau', 'Mông'],
      'exercises': [
        'Back Squat (4x8)',
        'Leg Press (3x12)',
        'Romanian Deadlift (3x10)'
      ],
      'duration': '60 phút',
      'isRest': false,
    },
    {
      'day': 'T5',
      'full': 'Thứ 5',
      'name': 'Shoulders & Core Sculpt',
      'muscles': ['Vai', 'Cơ bụng'],
      'exercises': [
        'Overhead Press (4x8)',
        'Lateral Raise (4x15)',
        'Hanging Leg Raise (3x15)'
      ],
      'duration': '45 phút',
      'isRest': false,
    },
    {
      'day': 'T6',
      'full': 'Thứ 6',
      'name': 'Full Body Hypertrophy',
      'muscles': ['Ngực', 'Lưng', 'Chân', 'Tay'],
      'exercises': [
        'Incline Press (3x10)',
        'Seated Cable Row (3x12)',
        'Leg Extension (3x15)'
      ],
      'duration': '55 phút',
      'isRest': false,
    },
    {
      'day': 'T7',
      'full': 'Thứ 7',
      'name': 'Cardio & Mobility Flow',
      'muscles': ['Tim mạch', 'Giãn cơ'],
      'exercises': [
        'Incline Treadmill Walk (25p)',
        'Rowing Machine (10p)',
        'Full Body Stretch (15p)'
      ],
      'duration': '50 phút',
      'isRest': false,
    },
    {
      'day': 'CN',
      'full': 'Chủ Nhật',
      'name': 'Active Recovery & Rest',
      'muscles': ['Hồi phục'],
      'exercises': ['Đi bộ nhẹ nhàng', 'Bổ sung dinh dưỡng & Ngủ đủ 8h'],
      'duration': 'Nghỉ ngơi',
      'isRest': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final current = _days[_selectedDayIndex];
    final isRest = current['isRest'] == true;
    final exercises = current['exercises'] as List<String>;
    final muscles = current['muscles'] as List<String>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Workout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isLight
                      ? AppColors.lightTextPrimary
                      : AppColors.darkTextPrimary,
                ),
              ),
              Text(
                'Lịch tập theo ngày',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isLight
                      ? AppColors.lightTextMuted
                      : AppColors.darkTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Day Selector Tabs
          Wrap(
            spacing: 6,
            runSpacing: 8,
            children: List.generate(_days.length, (idx) {
              final isSelected = idx == _selectedDayIndex;
              final dayStr = _days[idx]['day'] as String;

              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedDayIndex = idx);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 48,
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : (isLight
                            ? AppColors.lightSurface
                            : AppColors.darkSurface),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : (isLight
                              ? AppColors.lightBorder
                              : AppColors.darkBorder),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      dayStr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : (isLight
                                ? AppColors.lightTextSecondary
                                : AppColors.darkTextSecondary),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Day Card Preview
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isLight ? 0.03 : 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${current['full']} · ${current['name']}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isLight
                            ? AppColors.lightTextPrimary
                            : AppColors.darkTextPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isRest
                            ? AppColors.statusRecovery.withValues(alpha: 0.12)
                            : AppColors.primaryBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${current['duration']}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isRest
                              ? AppColors.statusRecovery
                              : (isLight
                                  ? AppColors.primaryBlue
                                  : AppColors.primaryBlueLight),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Target Muscles
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: muscles.map((m) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isLight
                            ? const Color(0xFFF1F3F5)
                            : const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        m,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isLight
                              ? AppColors.lightTextSecondary
                              : AppColors.darkTextSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),
                Divider(
                  color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
                  height: 1,
                ),
                const SizedBox(height: 14),

                // Exercises list
                ...exercises.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          isRest
                              ? Icons.spa_rounded
                              : Icons.check_circle_outline_rounded,
                          size: 16,
                          color: isRest
                              ? AppColors.statusRecovery
                              : AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isLight
                                  ? AppColors.lightTextPrimary
                                  : AppColors.darkTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                if (!isRest) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ActiveWorkoutPage(
                              title: '${current['full']} · ${current['name']}',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text(
                        'BẮT ĐẦU BUỔI TẬP NÀY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
