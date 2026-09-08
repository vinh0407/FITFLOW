import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vincecore/core/fitness_repository.dart';
import 'package:vincecore/core/theme/app_theme.dart';
import 'package:vincecore/main.dart';
import 'package:vincecore/features/home/domain/models/workout_schedule_model.dart';
import 'package:vincecore/features/progress/domain/models/workout_goal_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('invalid body measurements cannot change memory or persisted profile',
      () async {
    SharedPreferences.setMockInitialValues({});
    final repository = FitnessRepository();
    await repository.load();
    final before = repository.currentWeight;
    for (final value in [double.nan, double.infinity, -1.0, 301.0]) {
      await expectLater(
          repository.updateBodyWeight(value), throwsArgumentError);
      await expectLater(repository.logWeight(value), throwsArgumentError);
      expect(repository.currentWeight, before);
    }
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('fitflow.profile'), isFalse);
    expect(prefs.containsKey('fitflow.weight_records'), isFalse);
  });

  test(
      'created goals and edited progress survive reload without losing details',
      () async {
    SharedPreferences.setMockInitialValues({});
    var repository = FitnessRepository();
    await repository.load();
    final goal = WorkoutGoal.defaultGoals.first
        .copyWith(id: 'own-goal', name: 'My goal');
    await repository.addWorkoutGoal(goal);
    repository = FitnessRepository();
    await repository.load();
    expect(repository.workoutGoals.where((item) => item.id == 'own-goal'),
        hasLength(1));
    await repository.updateWorkoutGoal(goal.copyWith(completedExercises: 8));
    repository = FitnessRepository();
    await repository.load();
    final restored =
        repository.workoutGoals.singleWhere((item) => item.id == 'own-goal');
    expect(restored.completedExercises, 8);
    expect(restored.relatedExercises, goal.relatedExercises);
    expect(restored.totalVolumeKg, goal.totalVolumeKg);
    expect(restored.cardColor, goal.cardColor);
  });

  test('weight measurements retain their date precision and notes after reload',
      () async {
    SharedPreferences.setMockInitialValues({});
    final repository = FitnessRepository();
    await repository.load();
    await repository.logWeight(81.25,
        date: DateTime(2026, 8, 31), notes: 'After training');
    final reloaded = FitnessRepository();
    await reloaded.load();
    final recorded =
        reloaded.weightRecords.where((item) => item.notes == 'After training');
    expect(recorded, hasLength(1));
    expect(recorded.single.weightKg, 81.25);
    expect(recorded.single.date, DateTime(2026, 8, 31));
    expect(reloaded.currentWeight, 81.25);
  });

  test('schedule create edit and delete survive repository reload', () async {
    SharedPreferences.setMockInitialValues({});
    var repository = FitnessRepository();
    await repository.load();
    const schedule = WorkoutScheduleModel(
        id: 'own',
        name: 'My routine',
        daysOfWeek: [2],
        muscleGroups: ['Vai'],
        exercises: ['Press']);
    await repository.addSchedule(schedule);
    repository = FitnessRepository();
    await repository.load();
    expect(repository.schedules.any((item) => item.id == 'own'), isTrue);
    await repository
        .updateSchedule(schedule.copyWith(name: 'Updated', daysOfWeek: [4]));
    repository = FitnessRepository();
    await repository.load();
    expect(repository.getSchedulesForDay(4).single.name, 'Updated');
    for (final item in repository.schedules) {
      await repository.deleteSchedule(item.id);
    }
    repository = FitnessRepository();
    await repository.load();
    expect(repository.schedules, isEmpty,
        reason: 'Deleted schedules must not be replaced by demo schedules');
  });

  test('corrupt profile cannot prevent valid history from loading', () async {
    SharedPreferences.setMockInitialValues({
      'fitflow.profile': '{broken',
      'fitflow.workout_history': jsonEncode([
        {'name': 'Valid workout', 'duration': 30}
      ]),
    });
    final repository = FitnessRepository();
    await repository.load();
    expect(repository.history.single.name, 'Valid workout');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('fitflow.profile'), '{broken');
  });

  test(
      'invalid record does not discard its valid siblings or the bundled catalog',
      () async {
    SharedPreferences.setMockInitialValues({
      'fitflow.workout_history': jsonEncode([
        null,
        {'duration': 'bad'},
        {'name': 'Kept', 'duration': 20}
      ]),
      'fitflow.custom_programs': '{}',
      'fitflow.use_metric': 'not a bool',
    });
    final repository = FitnessRepository();
    await repository.load();
    expect(repository.history.single.name, 'Kept');
    expect(repository.discoverPrograms, isNotEmpty);
    expect(repository.useMetric, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('fitflow.workout_history.recovery'), isTrue);
    final backup = prefs.getString('fitflow.workout_history.recovery');
    await repository.recordWorkout(
        name: 'New', duration: 10, exercises: 2, kcal: 50);
    expect(prefs.getString('fitflow.workout_history.recovery'), backup);
  });

  test('today calories exclude other dates and empty history starts at zero',
      () async {
    SharedPreferences.setMockInitialValues({});
    final empty = FitnessRepository();
    await empty.load();
    expect(empty.todayConsumedCalories, 0);
    final now = DateTime.now();
    SharedPreferences.setMockInitialValues({
      'fitflow.meals': jsonEncode([
        {'id': 'today', 'kcal': 400, 'createdAt': now.toIso8601String()},
        {
          'id': 'past',
          'kcal': 900,
          'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()
        },
      ]),
    });
    final repository = FitnessRepository();
    await repository.load();
    expect(repository.todayConsumedCalories, 400);
  });

  testWidgets('recovery warning is visible and dismissible on a small screen',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'fitflow.workout_history': '{broken'});
    await fitnessRepository.load();
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const MainScreen()));
    expect(find.byType(MaterialBanner), findsOneWidget);
    await tester.tap(find.text('Đã hiểu'));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialBanner), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
