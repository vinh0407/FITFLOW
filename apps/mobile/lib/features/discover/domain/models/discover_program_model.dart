import 'package:flutter/material.dart';

class ProgramWeeklyExercise {
  const ProgramWeeklyExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.targetWeight = '',
    this.muscle = '',
    this.notes = '',
  });

  final String name;
  final int sets;
  final String reps;
  final int restSeconds;
  final String targetWeight;
  final String muscle;
  final String notes;

  Map<String, dynamic> toJson() => {
        'name': name,
        'sets': sets,
        'reps': reps,
        'restSeconds': restSeconds,
        'targetWeight': targetWeight,
        'muscle': muscle,
        'notes': notes,
      };

  factory ProgramWeeklyExercise.fromJson(Map<String, dynamic> json) =>
      ProgramWeeklyExercise(
        name: '${json['name'] ?? ''}',
        sets: (json['sets'] as num?)?.toInt() ?? 3,
        reps: '${json['reps'] ?? '10-12'}',
        restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 90,
        targetWeight: '${json['targetWeight'] ?? ''}',
        muscle: '${json['muscle'] ?? ''}',
        notes: '${json['notes'] ?? ''}',
      );
}

class ProgramWeeklyDay {
  const ProgramWeeklyDay({
    required this.dayOfWeek,
    required this.dayName,
    required this.workoutName,
    required this.isRestDay,
    this.muscleGroups = const [],
    this.exercises = const [],
    this.estimatedMinutes = 60,
  });

  final int dayOfWeek; // 1 = Monday .. 7 = Sunday
  final String dayName;
  final String workoutName;
  final bool isRestDay;
  final List<String> muscleGroups;
  final List<ProgramWeeklyExercise> exercises;
  final int estimatedMinutes;

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'dayName': dayName,
        'workoutName': workoutName,
        'isRestDay': isRestDay,
        'muscleGroups': muscleGroups,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'estimatedMinutes': estimatedMinutes,
      };

  factory ProgramWeeklyDay.fromJson(Map<String, dynamic> json) =>
      ProgramWeeklyDay(
        dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 1,
        dayName: '${json['dayName'] ?? 'Monday'}',
        workoutName: '${json['workoutName'] ?? ''}',
        isRestDay: json['isRestDay'] == true,
        muscleGroups:
            (json['muscleGroups'] as List?)?.map((e) => '$e').toList() ??
                const [],
        exercises: (json['exercises'] as List?)
                ?.map((e) => ProgramWeeklyExercise.fromJson(e))
                .toList() ??
            const [],
        estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 60,
      );
}

class DiscoverProgram {
  const DiscoverProgram({
    required this.id,
    required this.name,
    required this.author,
    required this.description,
    required this.coverImage,
    required this.difficulty,
    required this.goals,
    required this.frequencyDays,
    required this.durationWeeks,
    required this.exerciseCount,
    required this.rating,
    required this.reviewCount,
    required this.popularityScore,
    required this.trendingScore,
    required this.equipment,
    required this.muscleGroups,
    required this.category,
    this.isFeatured = false,
    this.isTrending = false,
    this.weeklySchedule = const [],
    this.accentColor = const Color(0xFF4E78A5),
  });

  final String id;
  final String name;
  final String author;
  final String description;
  final String coverImage;
  final String difficulty; // Beginner, Intermediate, Advanced, Professional
  final List<String> goals; // Hypertrophy, Strength, Powerbuilding, Fat Loss...
  final int frequencyDays; // 2..7 days/week
  final int durationWeeks; // e.g. 8, 10, 12 weeks
  final int exerciseCount;
  final double rating; // e.g. 4.9
  final int reviewCount;
  final int popularityScore;
  final int trendingScore;
  final List<String> equipment; // Barbell, Dumbbells, Cable, Rack, Bodyweight
  final List<String> muscleGroups;
  final String
      category; // Hypertrophy, Powerlifting, Powerbuilding, Bodyweight, Women, Cardio
  final bool isFeatured;
  final bool isTrending;
  final List<ProgramWeeklyDay> weeklySchedule;
  final Color accentColor;

  DiscoverProgram copyWith({
    String? id,
    String? name,
    String? author,
    String? description,
    String? coverImage,
    String? difficulty,
    List<String>? goals,
    int? frequencyDays,
    int? durationWeeks,
    int? exerciseCount,
    double? rating,
    int? reviewCount,
    int? popularityScore,
    int? trendingScore,
    List<String>? equipment,
    List<String>? muscleGroups,
    String? category,
    bool? isFeatured,
    bool? isTrending,
    List<ProgramWeeklyDay>? weeklySchedule,
    Color? accentColor,
  }) {
    return DiscoverProgram(
      id: id ?? this.id,
      name: name ?? this.name,
      author: author ?? this.author,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      difficulty: difficulty ?? this.difficulty,
      goals: goals ?? this.goals,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      exerciseCount: exerciseCount ?? this.exerciseCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      popularityScore: popularityScore ?? this.popularityScore,
      trendingScore: trendingScore ?? this.trendingScore,
      equipment: equipment ?? this.equipment,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      category: category ?? this.category,
      isFeatured: isFeatured ?? this.isFeatured,
      isTrending: isTrending ?? this.isTrending,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'author': author,
        'description': description,
        'coverImage': coverImage,
        'difficulty': difficulty,
        'goals': goals,
        'frequencyDays': frequencyDays,
        'durationWeeks': durationWeeks,
        'exerciseCount': exerciseCount,
        'rating': rating,
        'reviewCount': reviewCount,
        'popularityScore': popularityScore,
        'trendingScore': trendingScore,
        'equipment': equipment,
        'muscleGroups': muscleGroups,
        'category': category,
        'isFeatured': isFeatured,
        'isTrending': isTrending,
        'weeklySchedule': weeklySchedule.map((d) => d.toJson()).toList(),
      };

  factory DiscoverProgram.fromJson(Map<String, dynamic> json) =>
      DiscoverProgram(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        author: '${json['author'] ?? 'Coach Vince'}',
        description: '${json['description'] ?? ''}',
        coverImage: '${json['coverImage'] ?? ''}',
        difficulty: '${json['difficulty'] ?? 'Intermediate'}',
        goals: (json['goals'] as List?)?.map((e) => '$e').toList() ??
            ['Hypertrophy'],
        frequencyDays: (json['frequencyDays'] as num?)?.toInt() ?? 4,
        durationWeeks: (json['durationWeeks'] as num?)?.toInt() ?? 12,
        exerciseCount: (json['exerciseCount'] as num?)?.toInt() ?? 16,
        rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 120,
        popularityScore: (json['popularityScore'] as num?)?.toInt() ?? 95,
        trendingScore: (json['trendingScore'] as num?)?.toInt() ?? 90,
        equipment:
            (json['equipment'] as List?)?.map((e) => '$e').toList() ?? ['Gym'],
        muscleGroups:
            (json['muscleGroups'] as List?)?.map((e) => '$e').toList() ??
                ['Full Body'],
        category: '${json['category'] ?? 'Hypertrophy'}',
        isFeatured: json['isFeatured'] == true,
        isTrending: json['isTrending'] == true,
        weeklySchedule: (json['weeklySchedule'] as List?)
                ?.map((d) => ProgramWeeklyDay.fromJson(d))
                .toList() ??
            const [],
      );
}
