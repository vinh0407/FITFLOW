import 'package:fitflow_contracts/fitflow_contracts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'fitness_data.dart';

import '../features/home/domain/models/today_exercise_item.dart';
import '../features/home/domain/models/workout_schedule_model.dart';
import '../features/home/domain/models/day_workout_detail.dart';
import '../features/progress/domain/models/workout_goal_model.dart';
import '../features/progress/domain/models/weight_record_model.dart';
import '../features/discover/domain/models/discover_program_model.dart';
import '../features/discover/domain/models/discover_programs_catalog.dart';
import '../features/discover/domain/models/discover_filter_model.dart';

/// Single read/write boundary for the mobile experience.
///
/// The catalog is bundled for offline-first startup. User-owned data can be
/// moved behind these methods when the cloud repository is enabled, without
/// changing any screen widget.
class FitnessRepository extends ChangeNotifier {
  FitnessRepository();

  final Set<String> _storageWarnings = {};
  List<String> get storageWarnings => List.unmodifiable(_storageWarnings);

  FitflowProfile _profile = const FitflowProfile(
    daysPerWeek: '3',
    trainingGoal: 'BUILD CONSISTENCY',
    trainingLevel: 'BEGINNER',
  );
  bool _onboardingComplete = false;
  bool _authComplete = false;
  List<HistoryRecord> _history = const [];
  List<MealRecord> _meals = const [];
  final List<MuscleRecoveryInfo> _recoveryList = defaultMuscleRecoveryList;
  final List<OneRmStat> _oneRmStats = defaultOneRmStats;
  double _currentWeight = 75.3;
  final double _targetWeight = 80.0;
  final double _skeletalMuscleMass = 34.5;
  final double _bodyFatPercentage = 16.2;
  double _minPlateWeight = 2.5;
  bool _useMetric = true;
  ThemeMode _themeMode = ThemeMode.light;

  // Discover & Programs dynamic states
  List<DiscoverProgram> _discoverPrograms = List.from(defaultDiscoverPrograms);
  final Set<String> _savedProgramIds = {'prog_ppl'};

  // Analysis / Goals states
  List<WorkoutGoal> _workoutGoals = List.from(WorkoutGoal.defaultGoals);
  List<WeightRecord> _weightRecords = [
    WeightRecord(
      id: 'w_1',
      date: DateTime.now().subtract(const Duration(days: 30)),
      weightKg: 73.0,
      notes: 'Tháng trước',
    ),
    WeightRecord(
      id: 'w_2',
      date: DateTime.now().subtract(const Duration(days: 14)),
      weightKg: 74.2,
      notes: '2 tuần trước',
    ),
    WeightRecord(
      id: 'w_3',
      date: DateTime.now().subtract(const Duration(days: 7)),
      weightKg: 73.0,
      notes: 'Tuần trước',
    ),
    WeightRecord(
      id: 'w_4',
      date: DateTime.now(),
      weightKg: 75.3,
      notes: 'Hôm nay',
    ),
  ];

  // Home dynamic states
  final int _targetDailyCalories = 2455;
  List<TodayExerciseItem> _todayExercises = [
    const TodayExerciseItem(
      id: 'ex_1',
      name: 'Chest Press',
      muscleGroup: 'Ngực',
      sets: 4,
      reps: 10,
      weightKg: 60.0,
      isCompleted: true,
    ),
    const TodayExerciseItem(
      id: 'ex_2',
      name: 'Incline Dumbbell Press',
      muscleGroup: 'Ngực',
      sets: 3,
      reps: 12,
      weightKg: 24.0,
      isCompleted: true,
    ),
    const TodayExerciseItem(
      id: 'ex_3',
      name: 'Cable Fly',
      muscleGroup: 'Ngực',
      sets: 3,
      reps: 15,
      weightKg: 15.0,
      isCompleted: false,
    ),
    const TodayExerciseItem(
      id: 'ex_4',
      name: 'Overhead Tricep Extension',
      muscleGroup: 'Tay sau',
      sets: 3,
      reps: 12,
      weightKg: 20.0,
      isCompleted: false,
    ),
  ];

  List<WorkoutScheduleModel> _schedules = [
    const WorkoutScheduleModel(
      id: 'sch_push',
      name: 'PUSH DAY',
      daysOfWeek: [1], // Thứ 2
      muscleGroups: ['Ngực', 'Vai', 'Tay sau'],
      exercises: [
        'Chest Press',
        'Incline Dumbbell Press',
        'Dumbbell Lateral Raise',
        'Tricep Pushdown',
      ],
      estimatedDurationMinutes: 60,
    ),
    const WorkoutScheduleModel(
      id: 'sch_pull',
      name: 'PULL DAY',
      daysOfWeek: [3], // Thứ 4
      muscleGroups: ['Lưng', 'Tay trước'],
      exercises: [
        'Lat Pulldown',
        'Seated Cable Row',
        'Barbell Curl',
        'Face Pull',
      ],
      estimatedDurationMinutes: 60,
    ),
    const WorkoutScheduleModel(
      id: 'sch_leg',
      name: 'LEG DAY',
      daysOfWeek: [5], // Thứ 6
      muscleGroups: ['Đùi trước', 'Đùi sau', 'Bắp chân'],
      exercises: [
        'Barbell Squat',
        'Romanian Deadlift',
        'Leg Press',
        'Standing Calf Raise',
      ],
      estimatedDurationMinutes: 60,
    ),
    const WorkoutScheduleModel(
      id: 'sch_upper',
      name: 'UPPER BODY',
      daysOfWeek: [6], // Thứ 7
      muscleGroups: ['Ngực', 'Lưng', 'Vai', 'Tay'],
      exercises: [
        'Overhead Press',
        'Dumbbell Bench Press',
        'Pull-ups',
        'Hammer Curl',
      ],
      estimatedDurationMinutes: 50,
    ),
  ];

  FitflowProfile get profile => _profile;
  bool get onboardingComplete => _onboardingComplete;
  bool get authComplete => _authComplete;
  List<FoodRecord> get foods => catalogFoods;
  List<ExerciseRecord> get exercises => catalogExercises;
  List<ProgramRecord> get programs => catalogPrograms;
  List<DailyRoutineRecord> get dailyRoutines => catalogDailyRoutines;
  List<MuscleRecoveryInfo> get recoveryList => _recoveryList;
  List<OneRmStat> get oneRmStats => _oneRmStats;
  List<HistoryRecord> get history => List.unmodifiable(_history);
  List<MealRecord> get meals => List.unmodifiable(_meals);
  List<TodayExerciseItem> get todayExercises =>
      List.unmodifiable(_todayExercises);
  List<WorkoutScheduleModel> get schedules => List.unmodifiable(_schedules);
  List<WorkoutGoal> get workoutGoals => List.unmodifiable(_workoutGoals);
  List<WeightRecord> get weightRecords => List.unmodifiable(_weightRecords);
  List<DiscoverProgram> get discoverPrograms =>
      List.unmodifiable(_discoverPrograms);
  Set<String> get savedProgramIds => Set.unmodifiable(_savedProgramIds);

  List<DiscoverProgram> get trendingPrograms => _discoverPrograms
      .where((p) => p.isTrending || p.popularityScore >= 90)
      .toList();

  List<DiscoverProgram> get recommendedPrograms {
    final goal = _profile.trainingGoal.toUpperCase();
    if (goal.contains('STRENGTH') || goal.contains('POWER')) {
      return _discoverPrograms
          .where((p) =>
              p.category == 'Powerlifting' || p.category == 'Powerbuilding')
          .toList();
    }
    return _discoverPrograms
        .where((p) => p.category == 'Hypertrophy' || p.isFeatured)
        .take(4)
        .toList();
  }

  bool isProgramSaved(String programId) => _savedProgramIds.contains(programId);

  Future<void> toggleSaveProgram(String programId) async {
    if (_savedProgramIds.contains(programId)) {
      _savedProgramIds.remove(programId);
    } else {
      _savedProgramIds.add(programId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'fitflow.saved_programs', _savedProgramIds.toList());
    notifyListeners();
  }

  Future<void> addCustomAiProgram(DiscoverProgram program) async {
    _discoverPrograms = [
      program,
      ..._discoverPrograms.where((item) => item.id != program.id),
    ];
    _savedProgramIds.add(program.id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'fitflow.saved_programs', _savedProgramIds.toList());
    await prefs.setString(
      'fitflow.custom_programs',
      jsonEncode(_discoverPrograms
          .where((item) => item.id.startsWith('ai_prog_'))
          .map((item) => item.toJson())
          .toList()),
    );
    notifyListeners();
  }

  List<DiscoverProgram> getFilteredPrograms(DiscoverFilter filter) {
    var result = List<DiscoverProgram>.from(_discoverPrograms);

    if (filter.onlySaved) {
      result = result.where((p) => _savedProgramIds.contains(p.id)).toList();
    }

    if (filter.searchQuery.trim().isNotEmpty) {
      final q = filter.searchQuery.toLowerCase().trim();
      result = result.where((p) {
        final matchName = p.name.toLowerCase().contains(q);
        final matchAuthor = p.author.toLowerCase().contains(q);
        final matchDesc = p.description.toLowerCase().contains(q);
        final matchCat = p.category.toLowerCase().contains(q);
        final matchDiff = p.difficulty.toLowerCase().contains(q);
        final matchGoals = p.goals.any((g) => g.toLowerCase().contains(q));
        final matchMuscles =
            p.muscleGroups.any((m) => m.toLowerCase().contains(q));
        final matchEquip = p.equipment.any((e) => e.toLowerCase().contains(q));
        return matchName ||
            matchAuthor ||
            matchDesc ||
            matchCat ||
            matchDiff ||
            matchGoals ||
            matchMuscles ||
            matchEquip;
      }).toList();
    }

    if (filter.selectedDifficulty != null &&
        filter.selectedDifficulty != 'Tất cả' &&
        filter.selectedDifficulty != 'All') {
      result = result
          .where((p) =>
              p.difficulty.toLowerCase() ==
              filter.selectedDifficulty!.toLowerCase())
          .toList();
    }

    if (filter.selectedGoal != null &&
        filter.selectedGoal != 'Tất cả' &&
        filter.selectedGoal != 'All') {
      result = result
          .where((p) => p.goals.any(
              (g) => g.toLowerCase() == filter.selectedGoal!.toLowerCase()))
          .toList();
    }

    if (filter.selectedFrequency != null) {
      result = result
          .where((p) => p.frequencyDays == filter.selectedFrequency)
          .toList();
    }

    if (filter.selectedCategory != null &&
        filter.selectedCategory != 'Tất cả' &&
        filter.selectedCategory != 'All') {
      result = result
          .where((p) =>
              p.category.toLowerCase() ==
              filter.selectedCategory!.toLowerCase())
          .toList();
    }

    if (filter.selectedEquipment != null &&
        filter.selectedEquipment != 'Tất cả' &&
        filter.selectedEquipment != 'All') {
      result = result
          .where((p) => p.equipment.any((e) => e
              .toLowerCase()
              .contains(filter.selectedEquipment!.toLowerCase())))
          .toList();
    }

    switch (filter.sortBy) {
      case DiscoverSortBy.popular:
        result.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
        break;
      case DiscoverSortBy.rating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case DiscoverSortBy.newest:
        result.sort((a, b) => b.durationWeeks.compareTo(a.durationWeeks));
        break;
      case DiscoverSortBy.saved:
        result.sort((a, b) => (_savedProgramIds.contains(b.id) ? 1 : 0)
            .compareTo(_savedProgramIds.contains(a.id) ? 1 : 0));
        break;
      case DiscoverSortBy.difficulty:
        result.sort((a, b) => a.difficulty.compareTo(b.difficulty));
        break;
      case DiscoverSortBy.duration:
        result.sort((a, b) => b.durationWeeks.compareTo(a.durationWeeks));
        break;
    }

    return result;
  }

  int get targetDailyCalories => _targetDailyCalories;
  int get todayConsumedCalories {
    final today = DateTime.now();
    return _meals.where((item) {
      final date = item.createdAt.toLocal();
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).fold<int>(0, (sum, item) => sum + item.kcal);
  }

  double get currentWeight => _currentWeight;
  double get targetWeight => _targetWeight;
  double get skeletalMuscleMass => _skeletalMuscleMass;
  double get bodyFatPercentage => _bodyFatPercentage;
  double get minPlateWeight => _minPlateWeight;
  bool get useMetric => _useMetric;
  ThemeMode get themeMode => _themeMode;
  int get currentStreak {
    if (_history.isEmpty) return 0;
    final uniqueDates = _history.map((h) => h.date).toSet();
    return uniqueDates.length;
  }

  void setMetric(bool value) async {
    _useMetric = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fitflow.use_metric', _useMetric);
    notifyListeners();
  }

  void toggleUnits() async {
    setMetric(!_useMetric);
  }

  Future<void> setThemeMode(ThemeMode value) async {
    _themeMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fitflow.theme_mode', value.name);
    notifyListeners();
  }

  Future<void> updateBodyWeight(double weight) async {
    if (!weight.isFinite || weight < 25 || weight > 300) {
      throw ArgumentError.value(weight, 'weight', 'Expected 25–300 kg');
    }
    _currentWeight = weight;
    _profile = FitflowProfile(
      name: _profile.name,
      gender: _profile.gender,
      age: _profile.age,
      heightCm: _profile.heightCm,
      weightKg: weight.toString(),
      targetWeightKg: _profile.targetWeightKg,
      experience: _profile.experience,
      equipment: _profile.equipment,
      focusAreas: _profile.focusAreas,
      sessionMinutes: _profile.sessionMinutes,
      restingHeartRate: _profile.restingHeartRate,
      healthNotes: _profile.healthNotes,
      trainingGoal: _profile.trainingGoal,
      trainingLevel: _profile.trainingLevel,
      daysPerWeek: _profile.daysPerWeek,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fitflow.profile', jsonEncode(_profile.toJson()));
    notifyListeners();
  }

  void updateMinPlate(double plate) {
    _minPlateWeight = plate;
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _storageWarnings.clear();
    T? read<T>(String key, T Function(dynamic) decode) {
      final value = prefs.get(key);
      return value == null ? null : _decodeStored(key, value, decode);
    }

    List<T> records<T>(String key, T Function(Map<String, dynamic>) decode) =>
        read(key, (value) {
          final items = jsonDecode(value as String) as List;
          return items
              .map((item) => _decodeStored(key, item,
                  (value) => decode(Map<String, dynamic>.from(value as Map))))
              .whereType<T>()
              .toList();
        }) ??
        <T>[];

    final savedProgramIds = read(
        'fitflow.saved_programs', (value) => List<String>.from(value as List));
    _onboardingComplete =
        read('fitflow.onboarding_complete', (value) => value as bool) ?? false;
    _authComplete =
        read('fitflow.auth_complete', (value) => value as bool) ?? false;
    _useMetric = read('fitflow.use_metric', (value) => value as bool) ?? true;
    final themeName = read('fitflow.theme_mode', (value) => value as String);
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == themeName,
      orElse: () => ThemeMode.system,
    );
    _profile = read(
            'fitflow.profile',
            (value) => FitflowProfile.fromJson(Map<String, dynamic>.from(
                jsonDecode(value as String) as Map))) ??
        _profile;
    _currentWeight = double.tryParse(_profile.weightKg) ?? _currentWeight;
    _history = records('fitflow.workout_history', HistoryRecord.fromJson);
    _meals = records('fitflow.meals', MealRecord.fromJson);
    if (prefs.containsKey('fitflow.schedules')) {
      _schedules = records('fitflow.schedules', WorkoutScheduleModel.fromJson);
    }
    if (prefs.containsKey('fitflow.weight_records')) {
      _weightRecords = records('fitflow.weight_records', WeightRecord.fromJson);
    }
    if (prefs.containsKey('fitflow.workout_goals')) {
      _workoutGoals = records('fitflow.workout_goals', WorkoutGoal.fromJson);
    }
    if (savedProgramIds != null) {
      _savedProgramIds
        ..clear()
        ..addAll(savedProgramIds);
    }
    final customPrograms =
        records('fitflow.custom_programs', DiscoverProgram.fromJson)
            .where((item) => item.id.isNotEmpty)
            .toList();
    final customIds = customPrograms.map((item) => item.id).toSet();
    _discoverPrograms = [
      ...customPrograms,
      ...defaultDiscoverPrograms.where((item) => !customIds.contains(item.id)),
    ];
    // Keep the first damaged value, including its original type, before any
    // future save can replace it. Recovery never logs personal record contents.
    for (final key in _storageWarnings) {
      final backupKey = '$key.recovery';
      if (!prefs.containsKey(backupKey)) {
        await prefs.setString(backupKey, jsonEncode(prefs.get(key)));
      }
    }
    notifyListeners();
  }

  T? _decodeStored<T>(String key, dynamic value, T Function(dynamic) decode) {
    try {
      return decode(value);
    } on FormatException {
      _storageWarnings.add(key);
    } on TypeError {
      _storageWarnings.add(key);
    }
    return null;
  }

  Future<void> saveProfile(FitflowProfile value) async {
    _profile = value;
    _currentWeight = double.tryParse(value.weightKg) ?? _currentWeight;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fitflow.profile', jsonEncode(value.toJson()));
    notifyListeners();
  }

  Future<void> completeOnboarding(FitflowProfile value) async {
    _profile = value;
    _currentWeight = double.tryParse(value.weightKg) ?? _currentWeight;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fitflow.profile', jsonEncode(value.toJson()));
    await prefs.setBool('fitflow.onboarding_complete', true);
    _onboardingComplete = true;
    notifyListeners();
  }

  /// Marks the auth screen as passed (no real credentials needed for now).
  Future<void> markAuthComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fitflow.auth_complete', true);
    _authComplete = true;
    notifyListeners();
  }

  /// Local-only sign out: user-owned records stay on device until cloud sync
  /// is configured, while the next launch goes through profile setup again.
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fitflow.onboarding_complete', false);
    await prefs.setBool('fitflow.auth_complete', false);
    _onboardingComplete = false;
    _authComplete = false;
    _profile = const FitflowProfile();
    notifyListeners();
  }

  Future<void> recordWorkout({
    required String name,
    required int duration,
    required int exercises,
    required int kcal,
    int volume = 0,
  }) async {
    final now = DateTime.now();
    final entry = HistoryRecord(
      name: name,
      date:
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}',
      duration: duration,
      volume: volume,
      exercises: exercises,
      kcal: kcal,
      prs: 0,
    );
    _history = [entry, ..._history];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fitflow.workout_history',
        jsonEncode(_history.map((item) => item.toJson()).toList()));
    notifyListeners();
  }

  Future<void> recordMeal({
    required String title,
    required String items,
    required int kcal,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    final entry = MealRecord(
      id: 'meal_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      items: items,
      kcal: kcal,
      protein: protein,
      carbs: carbs,
      fat: fat,
      createdAt: DateTime.now(),
    );
    _meals = [entry, ..._meals];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fitflow.meals',
        jsonEncode(_meals.map((item) => item.toJson()).toList()));
    notifyListeners();
  }

  Future<void> deleteMeal(String id) async {
    _meals = _meals.where((meal) => meal.id != id).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fitflow.meals',
        jsonEncode(_meals.map((item) => item.toJson()).toList()));
    notifyListeners();
  }

  // Today's Exercises actions
  void toggleExerciseCompleted(String id) {
    _todayExercises = _todayExercises.map((ex) {
      if (ex.id == id) {
        return ex.copyWith(isCompleted: !ex.isCompleted);
      }
      return ex;
    }).toList();

    // Dynamically recalculate goal progress based on completed exercises
    final completedTotal = _todayExercises.where((e) => e.isCompleted).length;
    _workoutGoals = _workoutGoals.map((goal) {
      if (goal.id == 'goal_arm_shoulder') {
        final newDone = (6 + completedTotal).clamp(0, goal.totalExercises);
        final newPct = (newDone / goal.totalExercises) * 100;
        return goal.copyWith(
          completedExercises: newDone,
          exerciseCount: goal.totalExercises,
          progressPercentage: newPct,
        );
      }
      return goal;
    }).toList();

    notifyListeners();
  }

  WeightAnalysis getWeightAnalysis(WeightPeriod period) {
    final current = _currentWeight;
    final double previous;
    final List<WeightPoint> points;

    switch (period) {
      case WeightPeriod.weekly:
        previous = 73.0;
        points = [
          const WeightPoint(label: 'T2', weightKg: 73.0),
          const WeightPoint(label: 'T3', weightKg: 73.5),
          const WeightPoint(label: 'T4', weightKg: 74.0),
          const WeightPoint(label: 'T5', weightKg: 74.2),
          const WeightPoint(label: 'T6', weightKg: 74.8),
          const WeightPoint(label: 'T7', weightKg: 75.0),
          WeightPoint(label: 'CN', weightKg: current, isActive: true),
        ];
        break;
      case WeightPeriod.monthly:
        previous = 73.5;
        points = [
          const WeightPoint(label: 'Tuần 1', weightKg: 73.5),
          const WeightPoint(label: 'Tuần 2', weightKg: 74.0),
          const WeightPoint(label: 'Tuần 3', weightKg: 74.6),
          WeightPoint(label: 'Tuần 4', weightKg: current, isActive: true),
        ];
        break;
      case WeightPeriod.threeMonths:
        previous = 71.5;
        points = [
          const WeightPoint(label: 'Tháng 6', weightKg: 71.5),
          const WeightPoint(label: 'Tháng 7', weightKg: 73.2),
          WeightPoint(label: 'Tháng 8', weightKg: current, isActive: true),
        ];
        break;
      case WeightPeriod.sixMonths:
        previous = 68.0;
        points = [
          const WeightPoint(label: 'Tháng 3', weightKg: 68.0),
          const WeightPoint(label: 'Tháng 4', weightKg: 69.5),
          const WeightPoint(label: 'Tháng 5', weightKg: 71.0),
          const WeightPoint(label: 'Tháng 6', weightKg: 72.5),
          const WeightPoint(label: 'Tháng 7', weightKg: 74.0),
          WeightPoint(label: 'Tháng 8', weightKg: current, isActive: true),
        ];
        break;
      case WeightPeriod.yearly:
        previous = 66.0;
        points = [
          const WeightPoint(label: 'Jan', weightKg: 66.0),
          const WeightPoint(label: 'Feb', weightKg: 67.5),
          const WeightPoint(label: 'Mar', weightKg: 69.0),
          const WeightPoint(label: 'Apr', weightKg: 70.5),
          const WeightPoint(label: 'Mei', weightKg: 72.0),
          const WeightPoint(label: 'Jun', weightKg: 73.5),
          WeightPoint(label: 'Jul', weightKg: current, isActive: true),
        ];
        break;
    }

    return WeightAnalysis.calculate(
      currentWeight: current,
      previousWeight: previous,
      period: period,
      points: points,
    );
  }

  Future<void> logWeight(double weight, {DateTime? date, String? notes}) async {
    if (!weight.isFinite || weight < 25 || weight > 300) {
      throw ArgumentError.value(weight, 'weight', 'Expected 25–300 kg');
    }
    final entry = WeightRecord(
      id: 'w_${DateTime.now().millisecondsSinceEpoch}',
      date: date ?? DateTime.now(),
      weightKg: weight,
      notes: notes ?? '',
    );
    final next = [entry, ..._weightRecords];
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString('fitflow.weight_records',
        jsonEncode(next.map((item) => item.toJson()).toList()));
    if (!saved) throw StateError('Could not save weight record');
    _weightRecords = next;
    await updateBodyWeight(weight);
  }

  Future<void> addWorkoutGoal(WorkoutGoal goal) =>
      _saveWorkoutGoals([..._workoutGoals, goal]);

  Future<void> updateWorkoutGoal(WorkoutGoal goal) => _saveWorkoutGoals(
      _workoutGoals.map((g) => g.id == goal.id ? goal : g).toList());

  Future<void> _saveWorkoutGoals(List<WorkoutGoal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString('fitflow.workout_goals',
        jsonEncode(goals.map((item) => item.toJson()).toList()));
    if (!saved) throw StateError('Could not save workout goals');
    _workoutGoals = goals;
    notifyListeners();
  }

  void addTodayExercise(TodayExerciseItem item) {
    _todayExercises = [..._todayExercises, item];
    notifyListeners();
  }

  // Workout Schedules actions
  Future<void> addSchedule(WorkoutScheduleModel schedule) =>
      _saveSchedules([..._schedules, schedule]);

  Future<void> deleteSchedule(String id) =>
      _saveSchedules(_schedules.where((s) => s.id != id).toList());

  Future<void> updateSchedule(WorkoutScheduleModel schedule) => _saveSchedules(
      _schedules.map((s) => s.id == schedule.id ? schedule : s).toList());

  Future<void> _saveSchedules(List<WorkoutScheduleModel> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString('fitflow.schedules',
        jsonEncode(schedules.map((item) => item.toJson()).toList()));
    if (!saved) throw StateError('Could not save schedules');
    _schedules = schedules;
    notifyListeners();
  }

  List<WorkoutScheduleModel> getSchedulesForDay(int dayOfWeek) {
    return _schedules.where((s) => s.daysOfWeek.contains(dayOfWeek)).toList();
  }

  /// Returns workout days for a specific year and month for calendar indicators
  Set<int> getWorkoutDaysInMonth(int year, int month) {
    // In our sample data / active user streak, days around the current month are marked
    final now = DateTime.now();
    final days = <int>{};
    if (year == now.year && month == now.month) {
      // Days where user worked out
      for (int i = 1; i <= now.day; i++) {
        // Mon (1), Wed (3), Fri (5), Sat (6) pattern + recent streak
        final d = DateTime(year, month, i);
        if ([1, 3, 5, 6].contains(d.weekday) || i >= now.day - 3) {
          days.add(i);
        }
      }
    } else {
      // Past months mock workout days
      for (int i = 1; i <= 28; i++) {
        final d = DateTime(year, month, i);
        if ([1, 3, 5, 6].contains(d.weekday)) {
          days.add(i);
        }
      }
    }
    return days;
  }

  DayWorkoutDetail getWorkoutDetailForDate(DateTime date) {
    final isWorkout =
        getWorkoutDaysInMonth(date.year, date.month).contains(date.day);
    if (!isWorkout) {
      return DayWorkoutDetail(
        date: date,
        hasWorkout: false,
        restNotes:
            'Đây là ngày nghỉ ngơi tích cực. Cơ thể đang trong quá trình hồi phục mô cơ, nạp lại glycogen và tăng cường sức bền cho các buổi tập tiếp theo.',
      );
    }

    final weekday = date.weekday;
    if (weekday == 1) {
      return DayWorkoutDetail(
        date: date,
        hasWorkout: true,
        title: 'PUSH DAY (Ngực, Vai, Tay sau)',
        durationMinutes: 58,
        caloriesBurned: 420,
        totalVolumeKg: 4850,
        muscleGroups: ['Ngực', 'Vai', 'Tay sau'],
        exercises: const [
          DayExerciseLog(
              name: 'Chest Press', sets: 4, reps: 10, weightKg: 60, isPr: true),
          DayExerciseLog(
              name: 'Incline Dumbbell Press', sets: 3, reps: 12, weightKg: 24),
          DayExerciseLog(
              name: 'Dumbbell Lateral Raise', sets: 4, reps: 15, weightKg: 10),
          DayExerciseLog(
              name: 'Tricep Pushdown', sets: 3, reps: 15, weightKg: 25),
        ],
      );
    } else if (weekday == 3) {
      return DayWorkoutDetail(
        date: date,
        hasWorkout: true,
        title: 'PULL DAY (Lưng, Tay trước)',
        durationMinutes: 52,
        caloriesBurned: 390,
        totalVolumeKg: 5200,
        muscleGroups: ['Lưng', 'Tay trước'],
        exercises: const [
          DayExerciseLog(name: 'Lat Pulldown', sets: 4, reps: 10, weightKg: 55),
          DayExerciseLog(
              name: 'Seated Cable Row', sets: 4, reps: 12, weightKg: 50),
          DayExerciseLog(
              name: 'Barbell Bicep Curl',
              sets: 3,
              reps: 12,
              weightKg: 25,
              isPr: true),
          DayExerciseLog(name: 'Face Pull', sets: 3, reps: 15, weightKg: 20),
        ],
      );
    } else if (weekday == 5) {
      return DayWorkoutDetail(
        date: date,
        hasWorkout: true,
        title: 'LEG DAY (Chân, Đùi & Bắp)',
        durationMinutes: 65,
        caloriesBurned: 510,
        totalVolumeKg: 7800,
        muscleGroups: ['Đùi trước', 'Đùi sau', 'Bắp chân'],
        exercises: const [
          DayExerciseLog(
              name: 'Barbell Back Squat',
              sets: 4,
              reps: 8,
              weightKg: 90,
              isPr: true),
          DayExerciseLog(
              name: 'Romanian Deadlift', sets: 4, reps: 10, weightKg: 80),
          DayExerciseLog(
              name: 'Leg Press 45°', sets: 3, reps: 12, weightKg: 160),
          DayExerciseLog(
              name: 'Standing Calf Raise', sets: 4, reps: 15, weightKg: 60),
        ],
      );
    } else {
      return DayWorkoutDetail(
        date: date,
        hasWorkout: true,
        title: 'UPPER BODY & CORE',
        durationMinutes: 48,
        caloriesBurned: 360,
        totalVolumeKg: 4200,
        muscleGroups: ['Ngực', 'Lưng', 'Vai', 'Cơ bụng'],
        exercises: const [
          DayExerciseLog(
              name: 'Overhead Press', sets: 4, reps: 8, weightKg: 45),
          DayExerciseLog(
              name: 'Dumbbell Bench Press', sets: 3, reps: 10, weightKg: 26),
          DayExerciseLog(name: 'Pull-ups', sets: 3, reps: 8, weightKg: 0),
          DayExerciseLog(
              name: 'Hanging Leg Raise', sets: 3, reps: 15, weightKg: 0),
        ],
      );
    }
  }
}

final fitnessRepository = FitnessRepository();
