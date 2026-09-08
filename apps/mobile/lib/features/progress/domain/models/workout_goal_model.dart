import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WorkoutGoal {
  const WorkoutGoal({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroups,
    required this.exerciseCount,
    required this.completedExercises,
    required this.totalExercises,
    required this.progressPercentage,
    this.totalWorkouts = 12,
    this.totalSets = 48,
    this.totalReps = 480,
    this.totalVolumeKg = 8450,
    this.relatedExercises = const [],
    this.workoutHistoryNotes = const [],
    this.iconEmoji = 'goal',
    this.cardColor = AppColors.primaryBlueLight,
  });

  final String id;
  final String name;
  final String description;
  final List<String> muscleGroups;
  final int exerciseCount;
  final int completedExercises;
  final int totalExercises;
  final double progressPercentage; // 0 to 100
  final int totalWorkouts;
  final int totalSets;
  final int totalReps;
  final double totalVolumeKg;
  final List<String> relatedExercises;
  final List<String> workoutHistoryNotes;
  final String iconEmoji;
  final Color cardColor;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'muscleGroups': muscleGroups,
        'exerciseCount': exerciseCount,
        'completedExercises': completedExercises,
        'totalExercises': totalExercises,
        'progressPercentage': progressPercentage,
        'totalWorkouts': totalWorkouts,
        'totalSets': totalSets,
        'totalReps': totalReps,
        'totalVolumeKg': totalVolumeKg,
        'relatedExercises': relatedExercises,
        'workoutHistoryNotes': workoutHistoryNotes,
        'iconEmoji': iconEmoji,
        'cardColor': cardColor.toARGB32(),
      };

  factory WorkoutGoal.fromJson(Map<String, dynamic> json) => WorkoutGoal(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        muscleGroups: List<String>.from(json['muscleGroups'] as List),
        exerciseCount: json['exerciseCount'] as int,
        completedExercises: json['completedExercises'] as int,
        totalExercises: json['totalExercises'] as int,
        progressPercentage: (json['progressPercentage'] as num).toDouble(),
        totalWorkouts: json['totalWorkouts'] as int,
        totalSets: json['totalSets'] as int,
        totalReps: json['totalReps'] as int,
        totalVolumeKg: (json['totalVolumeKg'] as num).toDouble(),
        relatedExercises: List<String>.from(json['relatedExercises'] as List),
        workoutHistoryNotes:
            List<String>.from(json['workoutHistoryNotes'] as List),
        iconEmoji: json['iconEmoji'] as String,
        cardColor: Color(json['cardColor'] as int),
      );

  WorkoutGoal copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? muscleGroups,
    int? exerciseCount,
    int? completedExercises,
    int? totalExercises,
    double? progressPercentage,
    int? totalWorkouts,
    int? totalSets,
    int? totalReps,
    double? totalVolumeKg,
    List<String>? relatedExercises,
    List<String>? workoutHistoryNotes,
    String? iconEmoji,
    Color? cardColor,
  }) {
    return WorkoutGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      exerciseCount: exerciseCount ?? this.exerciseCount,
      completedExercises: completedExercises ?? this.completedExercises,
      totalExercises: totalExercises ?? this.totalExercises,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalSets: totalSets ?? this.totalSets,
      totalReps: totalReps ?? this.totalReps,
      totalVolumeKg: totalVolumeKg ?? this.totalVolumeKg,
      relatedExercises: relatedExercises ?? this.relatedExercises,
      workoutHistoryNotes: workoutHistoryNotes ?? this.workoutHistoryNotes,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      cardColor: cardColor ?? this.cardColor,
    );
  }

  static const defaultGoals = <WorkoutGoal>[
    WorkoutGoal(
      id: 'goal_arm_shoulder',
      name: 'Arm & shoulder muscle',
      description: 'Phát triển cơ bắp tay và vai 3D cân đối, săn chắc',
      muscleGroups: ['Tay trước', 'Tay sau', 'Vai'],
      exerciseCount: 15,
      completedExercises: 6,
      totalExercises: 15,
      progressPercentage: 37.0,
      totalWorkouts: 14,
      totalSets: 56,
      totalReps: 560,
      totalVolumeKg: 6200,
      relatedExercises: [
        'Overhead Dumbbell Press',
        'Dumbbell Lateral Raise',
        'Barbell Bicep Curl',
        'Tricep Rope Pushdown',
        'Hammer Curl',
        'Face Pull',
      ],
      workoutHistoryNotes: [
        'Hôm nay: Hoàn thành 4 hiệp Chest Press & Tricep Pushdown',
        '2 ngày trước: Dumbbell Lateral Raise 10kg × 15 reps (PR)',
        '4 ngày trước: Barbell Curl 25kg × 12 reps',
      ],
      iconEmoji: 'strength',
      cardColor: AppColors.primaryBlueLight,
    ),
    WorkoutGoal(
      id: 'goal_core_abs',
      name: 'Core & abdominal',
      description: 'Tăng cường sức mạnh cơ lõi và cắt nét cơ bụng 6 múi',
      muscleGroups: ['Cơ bụng', 'Cơ liên sườn', 'Lưng dưới'],
      exerciseCount: 12,
      completedExercises: 8,
      totalExercises: 12,
      progressPercentage: 65.0,
      totalWorkouts: 18,
      totalSets: 72,
      totalReps: 1080,
      totalVolumeKg: 3400,
      relatedExercises: [
        'Hanging Leg Raise',
        'Cable Woodchopper',
        'Ab Wheel Rollout',
        'Plank with Weight Plate',
        'Russian Twist',
      ],
      workoutHistoryNotes: [
        'Hôm qua: Hoàn thành 3 hiệp Hanging Leg Raise 15 reps',
        '3 ngày trước: Ab Wheel Rollout 4 hiệp × 12 reps',
        '5 ngày trước: Plank giữ 90 giây liên tục',
      ],
      iconEmoji: 'power',
      cardColor: AppColors.statusRecovery, // Mint/Turquoise
    ),
    WorkoutGoal(
      id: 'goal_leg_power',
      name: 'Leg & glute power',
      description: 'Gia tăng sức mạnh bùng nổ chân đùi và cơ mông săn chắc',
      muscleGroups: ['Đùi trước', 'Đùi sau', 'Cơ mông', 'Bắp chân'],
      exerciseCount: 18,
      completedExercises: 9,
      totalExercises: 18,
      progressPercentage: 52.0,
      totalWorkouts: 16,
      totalSets: 64,
      totalReps: 520,
      totalVolumeKg: 14800,
      relatedExercises: [
        'Barbell Back Squat',
        'Romanian Deadlift',
        'Leg Press 45°',
        'Bulgarian Split Squat',
        'Standing Calf Raise',
      ],
      workoutHistoryNotes: [
        '3 ngày trước: Squat 90kg × 8 reps (PR mới)',
        '5 ngày trước: Romanian Deadlift 80kg × 10 reps',
        '7 ngày trước: Leg Press 160kg × 12 reps',
      ],
      iconEmoji: 'legs',
      cardColor: AppColors.skyBlue,
    ),
  ];
}
