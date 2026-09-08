class WorkoutScheduleModel {
  const WorkoutScheduleModel({
    required this.id,
    required this.name,
    required this.daysOfWeek,
    required this.muscleGroups,
    required this.exercises,
    this.estimatedDurationMinutes = 60,
    this.isActive = true,
  });

  final String id;
  final String name;

  /// 1 = Monday (Thứ 2), 2 = Tuesday (Thứ 3), ..., 7 = Sunday (Chủ Nhật)
  final List<int> daysOfWeek;
  final List<String> muscleGroups;
  final List<String> exercises;
  final int estimatedDurationMinutes;
  final bool isActive;

  String get daysDisplay {
    const dayNames = {
      1: 'Thứ 2',
      2: 'Thứ 3',
      3: 'Thứ 4',
      4: 'Thứ 5',
      5: 'Thứ 6',
      6: 'Thứ 7',
      7: 'Chủ Nhật',
    };
    if (daysOfWeek.isEmpty) return 'Chưa gán ngày';
    if (daysOfWeek.length == 7) return 'Hàng ngày';
    final sorted = List<int>.from(daysOfWeek)..sort();
    return sorted.map((d) => dayNames[d] ?? 'T$d').join(', ');
  }

  String get muscleSummary => muscleGroups.join(' • ');

  WorkoutScheduleModel copyWith({
    String? id,
    String? name,
    List<int>? daysOfWeek,
    List<String>? muscleGroups,
    List<String>? exercises,
    int? estimatedDurationMinutes,
    bool? isActive,
  }) {
    return WorkoutScheduleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      exercises: exercises ?? this.exercises,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'daysOfWeek': daysOfWeek,
        'muscleGroups': muscleGroups,
        'exercises': exercises,
        'estimatedDurationMinutes': estimatedDurationMinutes,
        'isActive': isActive,
      };

  factory WorkoutScheduleModel.fromJson(Map<String, dynamic> json) =>
      WorkoutScheduleModel(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? 'Lịch tập'}',
        daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            [1],
        muscleGroups: (json['muscleGroups'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        exercises: (json['exercises'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        estimatedDurationMinutes:
            (json['estimatedDurationMinutes'] as num?)?.toInt() ?? 60,
        isActive: json['isActive'] as bool? ?? true,
      );
}
