import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ExerciseCollection {
  const ExerciseCollection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.exerciseCount,
    required this.muscleGroup,
    required this.imageUrl,
    this.gradientColors = const [Color(0xFF2C3E50), Color(0xFF000000)],
  });

  final String id;
  final String title;
  final String subtitle;
  final int exerciseCount;
  final String muscleGroup;
  final String imageUrl;
  final List<Color> gradientColors;

  static const defaultCollections = <ExerciseCollection>[
    ExerciseCollection(
      id: 'col_chest_abs',
      title: 'Chest & Abdominal Exercises',
      subtitle: 'Xây dựng khuôn ngực dày và rãnh bụng sắc nét',
      exerciseCount: 24,
      muscleGroup: 'CHEST & ABS',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=600&auto=format&fit=crop&q=80',
      gradientColors: [AppColors.primaryBlueLight, AppColors.primaryBlue],
    ),
    ExerciseCollection(
      id: 'col_back_shoulder',
      title: 'Back & Shoulder Exercises',
      subtitle: 'Tạo hình chữ V-Taper lưng rộng và bờ vai 3D',
      exerciseCount: 18,
      muscleGroup: 'BACK & SHOULDERS',
      imageUrl:
          'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=600&auto=format&fit=crop&q=80',
      gradientColors: [AppColors.statusRecovery, AppColors.primaryBlue],
    ),
    ExerciseCollection(
      id: 'col_legs_glutes',
      title: 'Legs & Glutes Power',
      subtitle: 'Sức mạnh bùng nổ thân dưới và cơ mông săn chắc',
      exerciseCount: 22,
      muscleGroup: 'LEGS & GLUTES',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=600&auto=format&fit=crop&q=80',
      gradientColors: [AppColors.primaryBlueLight, AppColors.primaryBlueDark],
    ),
    ExerciseCollection(
      id: 'col_arms_hypertrophy',
      title: 'Arms Hypertrophy',
      subtitle: 'Tập trung kéo căng và phì đại tay trước & tay sau',
      exerciseCount: 16,
      muscleGroup: 'BICEPS & TRICEPS',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=600&auto=format&fit=crop&q=80',
      gradientColors: [AppColors.aiPurple, AppColors.aiPurpleDark],
    ),
    ExerciseCollection(
      id: 'col_full_body',
      title: 'Full Body Mastery',
      subtitle: 'Kích hoạt toàn bộ nhóm cơ trong một buổi tập',
      exerciseCount: 30,
      muscleGroup: 'FULL BODY',
      imageUrl:
          'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600&auto=format&fit=crop&q=80',
      gradientColors: [AppColors.primaryBlueLight, AppColors.gray800],
    ),
    ExerciseCollection(
      id: 'col_mobility',
      title: 'Mobility & Stretching',
      subtitle: 'Tăng biên độ chuyển động khớp và giảm chấn thương',
      exerciseCount: 15,
      muscleGroup: 'FLEXIBILITY',
      imageUrl:
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=600&auto=format&fit=crop&q=80',
      gradientColors: [AppColors.statusWarning, AppColors.primaryBlueDark],
    ),
  ];
}
