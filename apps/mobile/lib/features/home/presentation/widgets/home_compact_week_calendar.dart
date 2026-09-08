import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';

class HomeCompactWeekCalendar extends StatelessWidget {
  const HomeCompactWeekCalendar({super.key, required this.onDaySelected});

  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final surface = isLight ? AppColors.lightSurface : AppColors.darkSurface;
    final primary =
        isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary;
    final muted = isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final minDayWidth = (MediaQuery.textScalerOf(context).scale(24) + 12)
            .clamp(54.0, double.infinity);
        final dayWidth =
            (constraints.maxWidth / 7).clamp(minDayWidth, double.infinity);
        return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (index) {
                final date = monday.add(Duration(days: index));
                final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;
                final hasWorkout =
                    fitnessRepository.getSchedulesForDay(index + 1).isNotEmpty;
                return SizedBox(
                  width: dayWidth,
                  child: Padding(
                    padding: EdgeInsets.only(right: index == 6 ? 0 : 6),
                    child: Semantics(
                      button: true,
                      selected: isToday,
                      label:
                          '${labels[index]} ngày ${date.day}${hasWorkout ? ', có lịch tập' : ''}',
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onDaySelected(date);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          constraints: const BoxConstraints(minHeight: 72),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppColors.primaryBlue
                                : (hasWorkout
                                    ? (isLight
                                        ? const Color(0xFFF1F3F5)
                                        : const Color(0xFF2C2C2E))
                                    : Colors.transparent),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isToday
                                    ? AppColors.primaryBlue
                                    : Colors.transparent),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(labels[index],
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isToday ? Colors.white : muted)),
                              const SizedBox(height: 5),
                              Text('${date.day}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: isToday ? Colors.white : primary)),
                              const SizedBox(height: 4),
                              Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isToday
                                          ? Colors.white
                                          : (hasWorkout
                                              ? AppColors.primaryBlue
                                              : Colors.transparent))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ));
      }),
    );
  }
}
