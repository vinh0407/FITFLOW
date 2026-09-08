class TodayExerciseItem {
  const TodayExerciseItem({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.weightKg,
    this.isCompleted = false,
    this.notes = '',
  });

  final String id;
  final String name;
  final String muscleGroup;
  final int sets;
  final int reps;
  final double weightKg;
  final bool isCompleted;
  final String notes;

  TodayExerciseItem copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    int? sets,
    int? reps,
    double? weightKg,
    bool? isCompleted,
    String? notes,
  }) {
    return TodayExerciseItem(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'muscleGroup': muscleGroup,
        'sets': sets,
        'reps': reps,
        'weightKg': weightKg,
        'isCompleted': isCompleted,
        'notes': notes,
      };

  factory TodayExerciseItem.fromJson(Map<String, dynamic> json) =>
      TodayExerciseItem(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        muscleGroup: '${json['muscleGroup'] ?? ''}',
        sets: (json['sets'] as num?)?.toInt() ?? 3,
        reps: (json['reps'] as num?)?.toInt() ?? 10,
        weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
        isCompleted: json['isCompleted'] as bool? ?? false,
        notes: '${json['notes'] ?? ''}',
      );
}
