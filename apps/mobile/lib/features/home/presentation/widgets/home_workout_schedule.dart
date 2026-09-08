import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/workout_schedule_model.dart';

class HomeWorkoutSchedule extends StatelessWidget {
  const HomeWorkoutSchedule({
    super.key,
    required this.onAddSchedule,
    required this.onViewAllSchedules,
  });

  final VoidCallback onAddSchedule;
  final VoidCallback onViewAllSchedules;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final todayWeekday = DateTime.now().weekday; // 1 = Mon, 7 = Sun
    final todaySchedules = fitnessRepository.getSchedulesForDay(todayWeekday);

    const weekDayLabels = [
      {'day': 1, 'label': 'T2'},
      {'day': 2, 'label': 'T3'},
      {'day': 3, 'label': 'T4'},
      {'day': 4, 'label': 'T5'},
      {'day': 5, 'label': 'T6'},
      {'day': 6, 'label': 'T7'},
      {'day': 7, 'label': 'CN'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Section Header: Lịch tập & + Thêm
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  'LỊCH TẬP',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isLight
                        ? AppColors.lightTextPrimary
                        : AppColors.darkTextPrimary,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onAddSchedule();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Thêm',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // 2. Days of week bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDayLabels.map((item) {
              final dayNum = item['day'] as int;
              final label = item['label'] as String;
              final isToday = dayNum == todayWeekday;
              final hasWorkout =
                  fitnessRepository.getSchedulesForDay(dayNum).isNotEmpty;

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primaryBlue
                      : (hasWorkout
                          ? (isLight
                              ? const Color(0xFFF1F3F5)
                              : const Color(0xFF2C2C2E))
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                        color: isToday
                            ? Colors.white
                            : (isLight
                                ? AppColors.lightTextPrimary
                                : AppColors.darkTextPrimary),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday
                            ? Colors.white
                            : (hasWorkout
                                ? AppColors.primaryBlue
                                : Colors.transparent),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // 3. Today's Scheduled Workout - Line by Line
        if (todaySchedules.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.statusRecovery.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                      child: Icon(Icons.self_improvement_rounded, size: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hôm nay là ngày nghỉ (Rest Day)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isLight
                              ? AppColors.lightTextPrimary
                              : AppColors.darkTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Thư giãn cơ bắp, bổ sung đủ nước và ngủ đủ giấc.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isLight
                              ? AppColors.lightTextMuted
                              : AppColors.darkTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ...todaySchedules.map((schedule) {
            return _TodayScheduleCard(
              schedule: schedule,
              isLight: isLight,
            );
          }),

        const SizedBox(height: 12),

        // 4. "Xem thêm lịch tập các ngày sau →" Button
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onViewAllSchedules();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 18,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Xem lịch tập các ngày sau trong tuần',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isLight
                                ? AppColors.lightTextPrimary
                                : AppColors.darkTextPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Chi tiết',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isLight
                              ? AppColors.primaryBlue
                              : AppColors.primaryBlueLight,
                        ),
                      ),
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TodayScheduleCard extends StatelessWidget {
  const _TodayScheduleCard({
    required this.schedule,
    required this.isLight,
  });

  final WorkoutScheduleModel schedule;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Schedule Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'HÔM NAY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    schedule.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '~${schedule.estimatedDurationMinutes} phút',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isLight
                      ? AppColors.lightTextSecondary
                      : AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Muscle groups summary
          Text(
            schedule.muscleSummary,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color:
                  isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted,
            ),
          ),

          const SizedBox(height: 14),
          Divider(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            height: 1,
          ),
          const SizedBox(height: 12),

          // Line by line exercise list
          ...schedule.exercises.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final exName = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isLight
                          ? const Color(0xFFF1F3F5)
                          : const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '$idx',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isLight
                              ? AppColors.lightTextPrimary
                              : AppColors.darkTextPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      exName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isLight
                            ? AppColors.lightTextPrimary
                            : AppColors.darkTextPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: isLight
                        ? AppColors.lightTextMuted
                        : AppColors.darkTextMuted,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
