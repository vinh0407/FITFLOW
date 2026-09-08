class DayWorkoutDetail {
  const DayWorkoutDetail({
    required this.date,
    required this.hasWorkout,
    this.title = '',
    this.durationMinutes = 0,
    this.caloriesBurned = 0,
    this.totalVolumeKg = 0,
    this.muscleGroups = const [],
    this.exercises = const [],
    this.restNotes = '',
  });

  final DateTime date;
  final bool hasWorkout;
  final String title;
  final int durationMinutes;
  final int caloriesBurned;
  final int totalVolumeKg;
  final List<String> muscleGroups;
  final List<DayExerciseLog> exercises;
  final String restNotes;
}

class DayExerciseLog {
  const DayExerciseLog({
    required this.name,
    required this.sets,
    required this.reps,
    required this.weightKg,
    this.isPr = false,
  });

  final String name;
  final int sets;
  final int reps;
  final double weightKg;
  final bool isPr;
}
