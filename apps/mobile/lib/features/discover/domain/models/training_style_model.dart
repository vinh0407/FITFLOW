import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TrainingStyle {
  const TrainingStyle({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.keyExercises,
    required this.goal,
    required this.iconEmoji,
    required this.badgeColor,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String tagline;
  final String description;
  final List<String> keyExercises;
  final String goal;
  final String iconEmoji;
  final Color badgeColor;
  final String imageUrl;

  static const defaultStyles = <TrainingStyle>[
    TrainingStyle(
      id: 'powerlifting',
      name: 'Powerlifting',
      tagline: 'Sức mạnh cực đại Big 3',
      description:
          'Tập trung tối đa hóa mức tạ 1RM của 3 bài tập nền tảng: Squat, Bench Press, và Deadlift.',
      keyExercises: ['Barbell Back Squat', 'Barbell Bench Press', 'Deadlift'],
      goal: 'Maximum Strength',
      iconEmoji: 'strength',
      badgeColor: Color(0xFF183B63),
      imageUrl:
          'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600&auto=format&fit=crop&q=80',
    ),
    TrainingStyle(
      id: 'hypertrophy',
      name: 'Hypertrophy',
      tagline: 'Tăng sinh khối cơ bắp',
      description:
          'Tối ưu hóa thể tích luyện tập (Volume), áp lực cơ học và Progressive Overload để phát triển kích thước cơ bắp toàn diện.',
      keyExercises: [
        'Incline Press',
        'Lat Pulldown',
        'Leg Press',
        'Dumbbell Curl'
      ],
      goal: 'Muscle Growth & Shape',
      iconEmoji: 'hypertrophy',
      badgeColor: AppColors.statusRecovery,
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=600&auto=format&fit=crop&q=80',
    ),
    TrainingStyle(
      id: 'powerbuilding',
      name: 'Powerbuilding',
      tagline: 'Kết hợp Sức mạnh & Tăng cơ',
      description:
          'Giao thoa hoàn hảo giữa mức tạ nặng của Powerlifting và thể tích bơm máu thẩm mỹ của Bodybuilding.',
      keyExercises: [
        'Overhead Press',
        'Bent-Over Row',
        'Barbell Squat',
        'Dumbbell Fly'
      ],
      goal: 'Strength + Aesthetics',
      iconEmoji: 'power',
      badgeColor: Color(0xFF557FA8),
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600&auto=format&fit=crop&q=80',
    ),
    TrainingStyle(
      id: 'bodyweight',
      name: 'Bodyweight & Calisthenics',
      tagline: 'Làm chủ trọng lượng cơ thể',
      description:
          'Rèn luyện sức mạnh bùng nổ, độ dẻo dai và kiểm soát cơ thể với tối thiểu dụng cụ.',
      keyExercises: [
        'Pull-ups',
        'Dips',
        'Push-ups',
        'Hanging Leg Raise',
        'Handstand'
      ],
      goal: 'Relative Strength & Agility',
      iconEmoji: 'mobility',
      badgeColor: AppColors.primaryBlueLight,
      imageUrl:
          'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=600&auto=format&fit=crop&q=80',
    ),
    TrainingStyle(
      id: 'womens_programs',
      name: "Women's Fitness",
      tagline: 'Tôn dáng, săn chắc & Cơ mông đùi',
      description:
          'Thiết kế chuyên sâu cho vóc dáng nữ giới, nhấn mạnh phát triển vòng 3 săn chắc, thon gọn eo và độ bền cơ thể.',
      keyExercises: [
        'Hip Thrust',
        'Romanian Deadlift',
        'Bulgarian Split Squat',
        'Cable Kickback'
      ],
      goal: 'Glute & Full Body Sculpt',
      iconEmoji: 'recovery',
      badgeColor: Color(0xFF4E78A5),
      imageUrl:
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=600&auto=format&fit=crop&q=80',
    ),
  ];
}
