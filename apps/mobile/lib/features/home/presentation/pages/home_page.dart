import 'package:flutter/material.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../workout/presentation/pages/active_workout_page.dart';

import '../widgets/home_header.dart';
import '../widgets/home_compact_week_calendar.dart';
import '../widgets/home_nutrition_card.dart';
import '../widgets/home_recovery_card.dart';
import '../widgets/home_today_exercises.dart';
import '../widgets/home_workout_schedule.dart';

import '../widgets/dialogs/day_workout_sheet.dart';
import '../widgets/dialogs/daily_menu_sheet.dart';
import '../widgets/dialogs/muscle_recovery_sheet.dart';
import '../widgets/dialogs/add_schedule_sheet.dart';
import '../widgets/dialogs/all_schedules_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.onStartWorkout,
    this.onNavigateTab,
  });

  final VoidCallback? onStartWorkout;
  final Function(int)? onNavigateTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    fitnessRepository.addListener(_refresh);
  }

  @override
  void dispose() {
    fitnessRepository.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _openDayWorkoutDetail(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayWorkoutSheet(date: date),
    );
  }

  void _openDailyMenu() {
    // Navigate to Nutrition tab if callback provided, otherwise show bottom sheet
    if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(3); // Nutrition is tab index 3
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const DailyMenuSheet(),
      );
    }
  }

  void _openMuscleRecovery() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MuscleRecoverySheet(),
    );
  }

  void _openAddSchedule() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddScheduleSheet(),
    );
  }

  void _openAllSchedules() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AllSchedulesSheet(),
    );
  }

  void _startWorkout() {
    if (widget.onStartWorkout != null) {
      widget.onStartWorkout!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const ActiveWorkoutPage(title: 'BUỔI TẬP HÔM NAY'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight ? AppColors.lightBg : AppColors.darkBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            // 1. Header / Lời chào
            HomeHeader(
              onAvatarTap: () => widget.onNavigateTab?.call(4), // Profile tab
              onNotificationTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Không có thông báo mới'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 2. Streak tập luyện + Calendar tương tác
            HomeCompactWeekCalendar(
              onDaySelected: _openDayWorkoutDetail,
            ),

            const SizedBox(height: 18),

            // 3. Card Dinh dưỡng hôm nay (Kcal goal & Menu)
            HomeNutritionCard(
              onTap: _openDailyMenu,
            ),

            const SizedBox(height: 18),

            // 4. Card Phục hồi cơ bắp (Muscle Recovery)
            HomeRecoveryCard(
              onTap: _openMuscleRecovery,
            ),

            const SizedBox(height: 24),

            // 5. Các bài tập hôm nay (Today's Exercises)
            HomeTodayExercises(
              onStartWorkout: _startWorkout,
            ),

            const SizedBox(height: 24),

            // 6. Section Lịch tập (Today's line-by-line, Weekdays bar, Add button, View all)
            HomeWorkoutSchedule(
              onAddSchedule: _openAddSchedule,
              onViewAllSchedules: _openAllSchedules,
            ),
          ],
        ),
      ),
    );
  }
}
