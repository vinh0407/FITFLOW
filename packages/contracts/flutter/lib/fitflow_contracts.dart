import 'package:meta/meta.dart';

const int bmiMin = 18;
const int bmiMax = 35;

@immutable
class BmiProfile {
  const BmiProfile({required this.bmi, required this.label, required this.tone, required this.focus});
  final int bmi;
  final String label;
  final String tone;
  final String focus;
}

int roundBmi(num value) => value.round();

@immutable
class FitflowProfile {
  const FitflowProfile({
    this.name = '',
    this.gender = '',
    this.age = '',
    this.heightCm = '',
    this.weightKg = '',
    this.targetWeightKg = '',
    this.experience = 'BEGINNER',
    this.equipment = const [],
    this.focusAreas = const [],
    this.sessionMinutes = '30',
    this.restingHeartRate = '',
    this.healthNotes = '',
    this.trainingGoal = 'BUILD CONSISTENCY',
    this.trainingLevel = 'BEGINNER',
    this.daysPerWeek = '3',
  });

  final String name;
  final String gender;
  final String age;
  final String heightCm;
  final String weightKg;
  final String targetWeightKg;
  final String experience;
  final List<String> equipment;
  final List<String> focusAreas;
  final String sessionMinutes;
  final String restingHeartRate;
  final String healthNotes;
  final String trainingGoal;
  final String trainingLevel;
  final String daysPerWeek;

  Map<String, dynamic> toJson() => {
        'name': name,
        'gender': gender,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'targetWeightKg': targetWeightKg,
        'experience': experience,
        'equipment': equipment,
        'focusAreas': focusAreas,
        'sessionMinutes': sessionMinutes,
        'restingHeartRate': restingHeartRate,
        'healthNotes': healthNotes,
        'trainingGoal': trainingGoal,
        'trainingLevel': trainingLevel,
        'daysPerWeek': daysPerWeek,
      };

  factory FitflowProfile.fromJson(Map<String, dynamic> json) => FitflowProfile(
        name: '${json['name'] ?? ''}',
        gender: '${json['gender'] ?? ''}',
        age: '${json['age'] ?? ''}',
        heightCm: '${json['heightCm'] ?? ''}',
        weightKg: '${json['weightKg'] ?? ''}',
        targetWeightKg: '${json['targetWeightKg'] ?? ''}',
        experience: '${json['experience'] ?? 'BEGINNER'}',
        equipment: (json['equipment'] as List<dynamic>? ?? const [])
            .map((item) => '$item')
            .toList(),
        focusAreas: (json['focusAreas'] as List<dynamic>? ?? const [])
            .map((item) => '$item')
            .toList(),
        sessionMinutes: '${json['sessionMinutes'] ?? '30'}',
        restingHeartRate: '${json['restingHeartRate'] ?? ''}',
        healthNotes: '${json['healthNotes'] ?? ''}',
        trainingGoal: '${json['trainingGoal'] ?? 'BUILD CONSISTENCY'}',
        trainingLevel: '${json['trainingLevel'] ?? 'BEGINNER'}',
        daysPerWeek: '${json['daysPerWeek'] ?? '3'}',
      );

  FitflowProfile copyWith({
    String? name,
    String? gender,
    String? age,
    String? heightCm,
    String? weightKg,
    String? targetWeightKg,
    String? experience,
    List<String>? equipment,
    List<String>? focusAreas,
    String? sessionMinutes,
    String? restingHeartRate,
    String? healthNotes,
    String? trainingGoal,
    String? trainingLevel,
    String? daysPerWeek,
  }) =>
      FitflowProfile(
        name: name ?? this.name,
        gender: gender ?? this.gender,
        age: age ?? this.age,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        targetWeightKg: targetWeightKg ?? this.targetWeightKg,
        experience: experience ?? this.experience,
        equipment: equipment ?? this.equipment,
        focusAreas: focusAreas ?? this.focusAreas,
        sessionMinutes: sessionMinutes ?? this.sessionMinutes,
        restingHeartRate: restingHeartRate ?? this.restingHeartRate,
        healthNotes: healthNotes ?? this.healthNotes,
        trainingGoal: trainingGoal ?? this.trainingGoal,
        trainingLevel: trainingLevel ?? this.trainingLevel,
        daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      );
}

@immutable
class TrainingSession {
  const TrainingSession({
    required this.day,
    required this.isRest,
    required this.focus,
    required this.exerciseCount,
    required this.sets,
    required this.reps,
    required this.prescriptionMode,
    required this.targetReps,
    required this.targetSeconds,
    required this.durationMinutes,
  });

  final int day;
  final bool isRest;
  final String focus;
  final int exerciseCount;
  final int sets;
  final String reps;
  final String prescriptionMode;
  final int? targetReps;
  final int? targetSeconds;
  final int durationMinutes;
}

@immutable
class TrainingPlan {
  const TrainingPlan({
    required this.bmi,
    required this.roundedBmi,
    required this.goal,
    required this.level,
    required this.daysPerWeek,
    required this.focus,
    required this.sessions,
  });

  final double bmi;
  final int roundedBmi;
  final String goal;
  final String level;
  final int daysPerWeek;
  final String focus;
  final List<TrainingSession> sessions;
}

@immutable
class ExercisePrescription {
  const ExercisePrescription({
    required this.mode,
    required this.sets,
    required this.reps,
    required this.seconds,
  });

  final String mode;
  final int sets;
  final int? reps;
  final int? seconds;
}

ExercisePrescription getExercisePrescription(
    String exerciseName, String category, FitflowProfile profile,
    {int? setsOverride}) {
  final height = double.tryParse(profile.heightCm) ?? 0;
  final weight = double.tryParse(profile.weightKg) ?? 0;
  final bmi = height > 0 && weight > 0 ? weight / ((height / 100) * (height / 100)) : 22;
  final roundedBmi = roundBmi(bmi);
  final level = _choice(profile.trainingLevel, 'beginner');
  final goal = _choice(profile.trainingGoal, 'general_fitness');
  final sets = setsOverride ?? (level == 'advanced' ? 4 : level == 'intermediate' ? 3 : 2);
  final timed = category.toLowerCase() == 'cardio' || exerciseName.toLowerCase().contains('plank');
  if (timed) {
    final baseSeconds = level == 'advanced' ? 60 : level == 'intermediate' ? 45 : 30;
    final bmiAdjustment = roundedBmi >= 30 ? -10 : roundedBmi <= 19 ? 10 : 0;
    return ExercisePrescription(mode: 'seconds', sets: sets, reps: null, seconds: (baseSeconds + bmiAdjustment).clamp(20, 120));
  }
  var targetReps = roundedBmi <= 19 ? 10 : roundedBmi <= 24 ? 12 : roundedBmi <= 29 ? 10 : 8;
  if (goal == 'build_strength' || goal == 'muscle_gain') targetReps = targetReps > 6 ? targetReps - 1 : targetReps;
  if (level == 'advanced') targetReps = targetReps > 6 ? targetReps - 1 : targetReps;
  return ExercisePrescription(mode: 'reps', sets: sets, reps: targetReps, seconds: null);
}

@immutable
class WorkoutLog {
  const WorkoutLog({
    required this.workoutId,
    required this.date,
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.duration,
    required this.kcal,
    this.kcalEstimated = true,
    required this.notes,
    required this.completed,
  });

  final String workoutId;
  final DateTime date;
  final String exerciseId;
  final String exerciseName;
  final int sets;
  final int reps;
  final double? weight;
  final int duration;
  final double kcal;
  final bool kcalEstimated;
  final String notes;
  final bool completed;

  Map<String, dynamic> toJson() => {
        'workoutId': workoutId,
        'date': date.toIso8601String(),
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'sets': sets,
        'reps': reps,
        'weight': weight,
        'duration': duration,
        'kcal': kcal,
        'kcalEstimated': kcalEstimated,
        'notes': notes,
        'completed': completed,
      };

  factory WorkoutLog.fromJson(Map<String, dynamic> json) => WorkoutLog(
        workoutId: '${json['workoutId'] ?? ''}',
        date: DateTime.parse('${json['date']}'),
        exerciseId: '${json['exerciseId'] ?? ''}',
        exerciseName: '${json['exerciseName'] ?? ''}',
        sets: (json['sets'] as num?)?.toInt() ?? 0,
        reps: (json['reps'] as num?)?.toInt() ?? 0,
        weight: (json['weight'] as num?)?.toDouble(),
        duration: (json['duration'] as num?)?.toInt() ?? 0,
        kcal: (json['kcal'] as num?)?.toDouble() ?? 0,
        kcalEstimated: json['kcalEstimated'] as bool? ?? true,
        notes: '${json['notes'] ?? ''}',
        completed: json['completed'] as bool? ?? false,
      );
}

String _choice(String? value, String fallback) =>
    (value == null || value.trim().isEmpty ? fallback : value)
        .trim()
        .toLowerCase()
        .replaceAll(' ', '_');

TrainingPlan generateTrainingPlan(FitflowProfile profile) {
  final height = double.tryParse(profile.heightCm) ?? 0;
  final weight = double.tryParse(profile.weightKg) ?? 0;
  final double bmi = height > 0 && weight > 0 ? weight / ((height / 100) * (height / 100)) : 0.0;
  final rawGoal = _choice(profile.trainingGoal, 'general_fitness') == 'build_consistency'
      ? 'general_fitness'
      : _choice(profile.trainingGoal, 'general_fitness');
  final goal = <String, String>{
    'build_strength': 'muscle_gain',
    'improve_conditioning': 'weight_loss',
    'move_more': 'general_fitness',
    'improve_mobility': 'maintenance',
  }[rawGoal] ?? rawGoal;
  final level = _choice(profile.trainingLevel, 'beginner');
  final days = (int.tryParse(profile.daysPerWeek) ?? 3).clamp(2, 6);
  final sets = level == 'advanced' ? 4 : level == 'intermediate' ? 3 : 2;
  final roundedBmi = roundBmi(bmi);
  var targetReps = roundedBmi <= 19 ? 10 : roundedBmi <= 24 ? 12 : roundedBmi <= 29 ? 10 : 8;
  if (goal == 'muscle_gain') targetReps = targetReps > 6 ? targetReps - 1 : targetReps;
  if (level == 'advanced') targetReps = targetReps > 6 ? targetReps - 1 : targetReps;
  final reps = '$targetReps–${targetReps + 2}';
  final minutes = level == 'advanced' ? 40 : level == 'intermediate' ? 32 : 24;
  final focus = goal == 'muscle_gain' ? 'STRENGTH' : goal == 'weight_loss' ? 'CONDITIONING' : 'BALANCE';
  const restOrder = [6, 2, 4, 0, 5, 1, 3];
  final restDays = restOrder.take(7 - days).toSet();
  final sessions = List<TrainingSession>.generate(7, (index) {
    final isRest = restDays.contains(index);
    return TrainingSession(
      day: index + 1,
      isRest: isRest,
      focus: isRest ? 'RECOVERY' : focus,
      exerciseCount: isRest ? 0 : (goal == 'weight_loss' && index == 5 ? 4 : goal == 'muscle_gain' ? 4 : 3),
      sets: isRest ? 0 : sets,
      reps: isRest ? '—' : reps,
      prescriptionMode: isRest ? 'rest' : 'reps',
      targetReps: isRest ? null : targetReps,
      targetSeconds: null,
      durationMinutes: isRest ? 15 : minutes,
    );
  });
  return TrainingPlan(bmi: bmi, roundedBmi: roundBmi(bmi).toInt(), goal: goal, level: level, daysPerWeek: days, focus: focus, sessions: sessions);
}

const bmiProfiles = <BmiProfile>[
  BmiProfile(bmi: 18, label: 'LOWER WEIGHT', tone: 'BUILD', focus: 'Foundational strength'),
  BmiProfile(bmi: 19, label: 'LOWER HEALTHY', tone: 'BUILD', focus: 'Strength + mobility'),
  BmiProfile(bmi: 20, label: 'HEALTHY RANGE', tone: 'BALANCE', focus: 'Full-body strength'),
  BmiProfile(bmi: 21, label: 'HEALTHY RANGE', tone: 'BALANCE', focus: 'Strength + conditioning'),
  BmiProfile(bmi: 22, label: 'HEALTHY RANGE', tone: 'PERFORM', focus: 'Strength + cardio'),
  BmiProfile(bmi: 23, label: 'HEALTHY RANGE', tone: 'PERFORM', focus: 'Progressive strength'),
  BmiProfile(bmi: 24, label: 'HEALTHY RANGE', tone: 'BALANCE', focus: 'Strength + conditioning'),
  BmiProfile(bmi: 25, label: 'UPPER HEALTHY', tone: 'PROGRESS', focus: 'Joint-friendly strength'),
  BmiProfile(bmi: 26, label: 'OVERWEIGHT RANGE', tone: 'PROGRESS', focus: 'Low-impact strength'),
  BmiProfile(bmi: 27, label: 'OVERWEIGHT RANGE', tone: 'PROGRESS', focus: 'Strength + walking'),
  BmiProfile(bmi: 28, label: 'OVERWEIGHT RANGE', tone: 'FOUNDATION', focus: 'Low-impact conditioning'),
  BmiProfile(bmi: 29, label: 'OVERWEIGHT RANGE', tone: 'FOUNDATION', focus: 'Mobility + strength'),
  BmiProfile(bmi: 30, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Supported movement'),
  BmiProfile(bmi: 31, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Seated + supported strength'),
  BmiProfile(bmi: 32, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Low-impact movement'),
  BmiProfile(bmi: 33, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Mobility + daily movement'),
  BmiProfile(bmi: 34, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Gentle full-body work'),
  BmiProfile(bmi: 35, label: 'HIGHER BMI RANGE', tone: 'FOUNDATION', focus: 'Supported full-body work'),
];
