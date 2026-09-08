import 'package:flutter/material.dart';
import '../../../../../core/fitness_repository.dart';
import '../../../../../core/theme/app_colors.dart';

class AllSchedulesSheet extends StatelessWidget {
  const AllSchedulesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final todayWeekday = DateTime.now().weekday;

    const dayTitles = {
      1: 'Thứ 2 (Monday)',
      2: 'Thứ 3 (Tuesday)',
      3: 'Thứ 4 (Wednesday)',
      4: 'Thứ 5 (Thursday)',
      5: 'Thứ 6 (Friday)',
      6: 'Thứ 7 (Saturday)',
      7: 'Chủ Nhật (Sunday)',
    };

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
                    'LỊCH TẬP TOÀN BỘ TUẦN',
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
                    'Kế hoạch phân bổ nhóm cơ các ngày tiếp theo',
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

          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) {
                final dayNum = index + 1;
                final dayTitle = dayTitles[dayNum] ?? 'Thứ $dayNum';
                final isToday = dayNum == todayWeekday;
                final isTomorrow = dayNum == (todayWeekday % 7) + 1;
                final daySchedules =
                    fitnessRepository.getSchedulesForDay(dayNum);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isToday
                        ? (isLight
                            ? AppColors.primaryBlue.withValues(alpha: 0.08)
                            : AppColors.primaryBlue.withValues(alpha: 0.15))
                        : (isLight
                            ? const Color(0xFFF8F9FA)
                            : const Color(0xFF242426)),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isToday
                          ? AppColors.primaryBlue
                          : (isLight
                              ? AppColors.lightBorder
                              : AppColors.darkBorder),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day title & badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                dayTitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: isToday
                                      ? AppColors.primaryBlue
                                      : (isLight
                                          ? AppColors.lightTextPrimary
                                          : AppColors.darkTextPrimary),
                                ),
                              ),
                              if (isToday) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'HÔM NAY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ] else if (isTomorrow) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusRecovery,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'NGÀY MAI',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (daySchedules.isNotEmpty)
                            Text(
                              '~${daySchedules.first.estimatedDurationMinutes} phút',
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

                      const SizedBox(height: 8),

                      if (daySchedules.isEmpty)
                        Text(
                          'Ngày nghỉ ngơi phục hồi (Rest Day)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isLight
                                ? AppColors.lightTextMuted
                                : AppColors.darkTextMuted,
                          ),
                        )
                      else ...[
                        Text(
                          '${daySchedules.first.name} • ${daySchedules.first.muscleSummary}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isLight
                                ? AppColors.lightTextPrimary
                                : AppColors.darkTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: daySchedules.first.exercises.map((ex) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isLight
                                    ? Colors.white
                                    : const Color(0xFF1E1E20),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isLight
                                      ? AppColors.lightBorder
                                      : AppColors.darkBorder,
                                ),
                              ),
                              child: Text(
                                ex,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isLight
                                      ? AppColors.lightTextSecondary
                                      : AppColors.darkTextSecondary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
