import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vincecore/core/fitness_repository.dart';
import 'package:vincecore/core/theme/app_colors.dart';
import 'package:vincecore/features/workout/presentation/pages/active_workout_page.dart';
import 'package:vincecore/features/discover/domain/models/discover_program_model.dart';

class ProgramDetailSheet extends StatefulWidget {
  const ProgramDetailSheet({
    super.key,
    required this.program,
  });

  final DiscoverProgram program;

  @override
  State<ProgramDetailSheet> createState() => _ProgramDetailSheetState();
}

class _ProgramDetailSheetState extends State<ProgramDetailSheet> {
  int _selectedScheduleDay = 1;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final program = widget.program;
    final isSaved = fitnessRepository.isProgramSaved(program.id);
    final schedule = program.weeklySchedule;

    final selectedDayData = schedule.firstWhere(
      (d) => d.dayOfWeek == _selectedScheduleDay,
      orElse: () => schedule.isNotEmpty
          ? schedule.first
          : const ProgramWeeklyDay(
              dayOfWeek: 1,
              dayName: 'Thứ 2',
              workoutName: 'Full Body',
              isRestDay: false,
            ),
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isLight ? Colors.black12 : Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              children: [
                // 1. Cover Image with Badges
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.network(
                        program.coverImage,
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 190,
                          color: const Color(0xFF2C3E50),
                          child: const Center(
                            child: Icon(Icons.fitness_center_rounded,
                                size: 50, color: Colors.white54),
                          ),
                        ),
                      ),
                    ),

                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.1),
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Top Bar inside cover
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              program.difficulty.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                fitnessRepository.toggleSaveProgram(program.id);
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                              child: Icon(
                                isSaved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_outline_rounded,
                                size: 20,
                                color: isSaved
                                    ? AppColors.primaryBlue
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom info inside cover
                    Positioned(
                      bottom: 12,
                      left: 14,
                      right: 14,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            program.category,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 16, color: AppColors.statusWarning),
                              const SizedBox(width: 3),
                              Text(
                                '${program.rating.toStringAsFixed(1)} (${program.reviewCount} reviews)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 2. Title & Author
                Text(
                  program.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isLight
                        ? AppColors.lightTextPrimary
                        : AppColors.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tác giả: ${program.author}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isLight
                        ? AppColors.primaryBlue
                        : AppColors.primaryBlueLight,
                  ),
                ),

                const SizedBox(height: 12),

                // 3. Description
                Text(
                  program.description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isLight
                        ? AppColors.lightTextSecondary
                        : AppColors.darkTextSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Quick Specs 4-col Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isLight
                        ? const Color(0xFFF8F9FA)
                        : const Color(0xFF242426),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isLight
                          ? AppColors.lightBorder
                          : AppColors.darkBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SpecItem(
                        icon: Icons.calendar_today_rounded,
                        label: 'Thời gian',
                        value: '${program.durationWeeks} Tuần',
                        isLight: isLight,
                      ),
                      _SpecItem(
                        icon: Icons.fitness_center_rounded,
                        label: 'Tần suất',
                        value: '${program.frequencyDays} Buổi/T',
                        isLight: isLight,
                      ),
                      _SpecItem(
                        icon: Icons.format_list_bulleted_rounded,
                        label: 'Bài tập',
                        value: '${program.exerciseCount} Bài',
                        isLight: isLight,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 5. Equipment & Muscle Groups
                Text(
                  'DỤNG CỤ YÊU CẦU',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isLight
                        ? AppColors.lightTextMuted
                        : AppColors.darkTextMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: program.equipment.map((e) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLight
                            ? const Color(0xFFF1F3F5)
                            : const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        e,
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

                const SizedBox(height: 20),

                // 6. Weekly Schedule Breakdown (Week 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LỊCH TẬP CHI TIẾT THEO TUẦN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isLight
                            ? AppColors.lightTextMuted
                            : AppColors.darkTextMuted,
                      ),
                    ),
                    Text(
                      'Tuần 1 ~ 12',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isLight
                            ? AppColors.primaryBlue
                            : AppColors.primaryBlueLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Days tabs
                if (schedule.isNotEmpty) ...[
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: schedule.length,
                      itemBuilder: (context, index) {
                        final day = schedule[index];
                        final isSel = day.dayOfWeek == _selectedScheduleDay;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(
                                  () => _selectedScheduleDay = day.dayOfWeek);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? AppColors.primaryBlue
                                    : (isLight
                                        ? const Color(0xFFF8F9FA)
                                        : const Color(0xFF242426)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSel
                                      ? AppColors.primaryBlue
                                      : (isLight
                                          ? AppColors.lightBorder
                                          : AppColors.darkBorder),
                                ),
                              ),
                              child: Text(
                                day.dayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      isSel ? FontWeight.w900 : FontWeight.w700,
                                  color: isSel
                                      ? Colors.white
                                      : (isLight
                                          ? AppColors.lightTextPrimary
                                          : AppColors.darkTextPrimary),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Selected Day Detail
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isLight
                          ? const Color(0xFFF8F9FA)
                          : const Color(0xFF242426),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isLight
                            ? AppColors.lightBorder
                            : AppColors.darkBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedDayData.workoutName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isLight
                                ? AppColors.lightTextPrimary
                                : AppColors.darkTextPrimary,
                          ),
                        ),
                        if (selectedDayData.isRestDay)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.spa_rounded,
                                    size: 16, color: AppColors.statusRecovery),
                                const SizedBox(width: 8),
                                Text(
                                  'Ngày nghỉ hồi phục cơ bắp',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isLight
                                        ? AppColors.lightTextSecondary
                                        : AppColors.darkTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          const SizedBox(height: 10),
                          ...selectedDayData.exercises.map((ex) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        ex.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isLight
                                              ? AppColors.lightTextPrimary
                                              : AppColors.darkTextPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${ex.sets} hiệp · ${ex.reps}',
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
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // 7. Start Program Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActiveWorkoutPage(
                            title:
                                '${program.name} · ${selectedDayData.dayName}',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: const Text(
                      'BẮT ĐẦU CHƯƠNG TRÌNH',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  const _SpecItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isLight,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon,
            size: 18,
            color:
                isLight ? AppColors.primaryBlue : AppColors.primaryBlueLight),
        const SizedBox(height: 4),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted,
          ),
        ),
      ],
    );
  }
}
