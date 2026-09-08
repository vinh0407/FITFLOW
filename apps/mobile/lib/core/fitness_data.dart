import 'package:flutter/material.dart';
import 'theme/app_colors.dart';

class FoodRecord {
  const FoodRecord({
    required this.name,
    required this.category,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.serving,
    this.imageUrl = '',
    this.subCategory = '',
    this.benefits = '',
  });

  final String name;
  final String category;
  final int kcal;
  final double protein;
  final double carbs;
  final double fat;
  final String serving;
  final String imageUrl;
  final String subCategory;
  final String benefits;
}

/// User-owned food entry. Nutrition values are always recorded with the entry
/// so later catalog edits cannot rewrite a completed day's totals.
class MealRecord {
  const MealRecord({
    required this.id,
    required this.title,
    required this.items,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String items;
  final int kcal;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'items': items,
        'kcal': kcal,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MealRecord.fromJson(Map<String, dynamic> json) => MealRecord(
        id: '${json['id'] ?? ''}',
        title: '${json['title'] ?? 'MEAL'}',
        items: '${json['items'] ?? ''}',
        kcal: (json['kcal'] as num?)?.toInt() ?? 0,
        protein: (json['protein'] as num?)?.toDouble() ?? 0,
        carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
        fat: (json['fat'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.tryParse('${json['createdAt']}') ?? DateTime.now(),
      );
}

class HistoryRecord {
  const HistoryRecord({
    required this.name,
    required this.date,
    required this.duration,
    required this.volume,
    required this.exercises,
    required this.kcal,
    required this.prs,
  });

  final String name;
  final String date;
  final int duration;
  final int volume;
  final int exercises;
  final int kcal;
  final int prs;

  Map<String, dynamic> toJson() => {
        'name': name,
        'date': date,
        'duration': duration,
        'volume': volume,
        'exercises': exercises,
        'kcal': kcal,
        'prs': prs,
      };

  factory HistoryRecord.fromJson(Map<String, dynamic> json) => HistoryRecord(
        name: '${json['name'] ?? 'Workout'}',
        date: '${json['date'] ?? ''}',
        duration: (json['duration'] as num?)?.toInt() ?? 0,
        volume: (json['volume'] as num?)?.toInt() ?? 0,
        exercises: (json['exercises'] as num?)?.toInt() ?? 0,
        kcal: (json['kcal'] as num?)?.toInt() ?? 0,
        prs: (json['prs'] as num?)?.toInt() ?? 0,
      );
}

class ExerciseRecord {
  const ExerciseRecord({
    required this.name,
    required this.muscle,
    required this.equipment,
    required this.difficulty,
    required this.instructions,
    this.targetSets = 3,
    this.targetReps = '8-12',
    this.suggestedWeight = '15kg',
    this.category = 'Cơ bản',
    this.target = '',
    this.secondaryMuscles = const [],
    this.gifUrl = '',
    this.imageUrl = '',
  });

  final String name;
  final String muscle;
  final String equipment;
  final String difficulty;
  final List<String> instructions;
  final int targetSets;
  final String targetReps;
  final String suggestedWeight;
  final String category;
  final String target;
  final List<String> secondaryMuscles;
  final String gifUrl;
  final String imageUrl;
}

class ProgramRecord {
  const ProgramRecord({
    required this.id,
    required this.title,
    required this.author,
    required this.level,
    required this.frequency,
    required this.category,
    required this.imageUrl,
    this.isPro = true,
    this.description = '',
  });

  final String id;
  final String title;
  final String author;
  final String level;
  final String frequency;
  final String category;
  final String imageUrl;
  final bool isPro;
  final String description;
}

class DailyRoutineRecord {
  const DailyRoutineRecord({
    required this.id,
    required this.title,
    required this.author,
    required this.level,
    required this.userCount,
    required this.muscleCategory,
    required this.exerciseCount,
  });

  final String id;
  final String title;
  final String author;
  final String level;
  final int userCount;
  final String muscleCategory;
  final int exerciseCount;
}

class MuscleRecoveryInfo {
  const MuscleRecoveryInfo({
    required this.name,
    required this.percentage,
    required this.lastTrainedDaysAgo,
    required this.targetSets,
    required this.completedSets,
  });

  final String name;
  final int percentage; // 0 to 100
  final int lastTrainedDaysAgo;
  final int targetSets;
  final int completedSets;
}

class OneRmStat {
  const OneRmStat({
    required this.exerciseName,
    required this.weightKg,
    required this.topPercentage,
    required this.completedSets,
    required this.isUp,
  });

  final String exerciseName;
  final double weightKg;
  final int topPercentage;
  final int completedSets;
  final bool isUp;
}

class TrainingPhase365 {
  const TrainingPhase365({
    required this.phaseNumber,
    required this.name,
    required this.subtitle,
    required this.durationWeeks,
    required this.objective,
    required this.focus,
    required this.progressPercent,
    required this.color,
  });

  final int phaseNumber;
  final String name;
  final String subtitle;
  final int durationWeeks;
  final String objective;
  final String focus;
  final double progressPercent;
  final Color color;
}

const default365Phases = <TrainingPhase365>[
  TrainingPhase365(
    phaseNumber: 1,
    name: 'Phase 01 · Foundation',
    subtitle: 'Nền tảng vận động & Kỹ thuật chuyển động',
    durationWeeks: 6,
    objective:
        'Xây dựng sự ổn định của khớp, khắc phục mất cân bằng cơ thể và chuẩn hóa kỹ thuật Big 3.',
    focus: 'Mobility & Form',
    progressPercent: 1.0,
    color: AppColors.gray500,
  ),
  TrainingPhase365(
    phaseNumber: 2,
    name: 'Phase 02 · Adaptation',
    subtitle: 'Thích ứng tải trọng & Thần kinh cơ',
    durationWeeks: 8,
    objective:
        'Tăng dần thể tích luyện tập, chuẩn bị hệ cơ xương khớp cho giai đoạn tải nặng.',
    focus: 'Work Capacity',
    progressPercent: 1.0,
    color: AppColors.gray600,
  ),
  TrainingPhase365(
    phaseNumber: 3,
    name: 'Phase 03 · Strength',
    subtitle: 'Phát triển sức mạnh cực đại',
    durationWeeks: 8,
    objective:
        'Tối ưu hóa khả năng phát lực thần kinh, đẩy mức tạ 1RM của Squat, Bench, Deadlift.',
    focus: 'Max Strength (1-5 Reps)',
    progressPercent: 0.65,
    color: AppColors.primaryBlue,
  ),
  TrainingPhase365(
    phaseNumber: 4,
    name: 'Phase 04 · Hypertrophy',
    subtitle: 'Tăng sinh khối cơ bắp tối đa',
    durationWeeks: 10,
    objective:
        'Tập trung vào áp lực cơ học và căng thẳng trao đổi chất để tối đa hóa kích thước cơ bắp.',
    focus: 'Muscle Growth (8-12 Reps)',
    progressPercent: 0.0,
    color: AppColors.gray700,
  ),
  TrainingPhase365(
    phaseNumber: 5,
    name: 'Phase 05 · Conditioning',
    subtitle: 'Sức bền yếm khí & Hệ năng lượng',
    durationWeeks: 6,
    objective:
        'Cải thiện ngưỡng VO2 max, giảm mỡ thừa và tăng tốc độ phục hồi giữa các hiệp.',
    focus: 'Metabolic Conditioning',
    progressPercent: 0.0,
    color: AppColors.gray500,
  ),
  TrainingPhase365(
    phaseNumber: 6,
    name: 'Phase 06 · Performance',
    subtitle: 'Bùng nổ công suất & Tốc độ phát lực',
    durationWeeks: 8,
    objective:
        'Chuyển hóa sức mạnh thô thành công suất bùng nổ (Rate of Force Development).',
    focus: 'Power & Speed',
    progressPercent: 0.0,
    color: AppColors.gray600,
  ),
  TrainingPhase365(
    phaseNumber: 7,
    name: 'Phase 07 · Transformation',
    subtitle: 'Định hình thể hình & Đỉnh cao phong độ',
    durationWeeks: 6,
    objective:
        'Siết nét cơ bắp tối đa, kiểm tra lại toàn bộ chỉ số 1RM và kỷ niệm 365 ngày.',
    focus: 'Peak Conditioning',
    progressPercent: 0.0,
    color: AppColors.primaryBlue,
  ),
];

const catalogPrograms = <ProgramRecord>[
  ProgramRecord(
    id: 'gzcl',
    title: 'GZCL Method',
    author: 'Cody Lefever',
    level: 'Người mới',
    frequency: '5 ngày/tuần',
    category: 'Powerlifting',
    imageUrl: 'assets/images/coach_gzcl.png',
    isPro: false,
    description:
        'Chương trình phát triển sức mạnh và phì đại toàn diện với 3 tầng volume.',
  ),
  ProgramRecord(
    id: 'hypertrophy_mike',
    title: 'Lịch tập tăng cơ 5 ngày',
    author: 'Dr. Mike Israetel',
    level: 'Trung cấp',
    frequency: '6 ngày/tuần',
    category: 'Hypertrophy',
    imageUrl: 'assets/images/coach_mike.png',
    isPro: true,
    description:
        'Giáo án tối ưu thể tích luyện tập (MEV -> MRV) dựa trên nghiên cứu khoa học.',
  ),
  ProgramRecord(
    id: 'torque_360',
    title: 'Torque 360: Cơ bụng & Cơ liên sườn',
    author: 'HLV Nolan',
    level: 'Người mới',
    frequency: '3 ngày/tuần',
    category: 'Hypertrophy',
    imageUrl: 'assets/images/coach_nolan.png',
    isPro: true,
    description: 'Siết chặt cơ lõi và định hình cơ bụng 6 múi sắc nét.',
  ),
  ProgramRecord(
    id: 'bench_pr',
    title: 'Bench PR của Bradley Barbell',
    author: 'Adam Bradley',
    level: 'Trung cấp',
    frequency: '5 ngày/tuần',
    category: 'Powerlifting',
    imageUrl: 'assets/images/coach_bradley.png',
    isPro: true,
    description:
        'Đột phá kỷ lục cá nhân bài đẩy ngực Bench Press an toàn và hiệu quả.',
  ),
  ProgramRecord(
    id: 'muscle_lab',
    title: 'MuscleLab: Sức mạnh và Phì đại',
    author: 'Coach Zane',
    level: 'Người mới',
    frequency: '4 ngày/tuần',
    category: 'Powerbuilding',
    imageUrl: 'assets/images/coach_zane.png',
    isPro: true,
    description: 'Kết hợp hoàn hảo giữa tăng cơ thẩm mỹ và sức mạnh thuần túy.',
  ),
  ProgramRecord(
    id: 'alpha_perf',
    title: 'Alpha Performance 101',
    author: 'Coach Nolan',
    level: 'Người mới',
    frequency: '4 ngày/tuần',
    category: 'Bodyweight',
    imageUrl: 'assets/images/coach_alpha.png',
    isPro: true,
    description: 'Tối ưu độ linh hoạt, sức bền và độ bùng nổ của cơ bắp.',
  ),
  ProgramRecord(
    id: 'reboot_40',
    title: 'Reboot 40+',
    author: 'Coach Nolan',
    level: 'Người mới',
    frequency: '3 ngày/tuần',
    category: 'Dành cho nam',
    imageUrl: 'assets/images/coach_reboot.png',
    isPro: true,
    description: 'Giáo án bảo vệ khớp và hồi phục sinh lực cơ bắp.',
  ),
];

const catalogDailyRoutines = <DailyRoutineRecord>[
  DailyRoutineRecord(
    id: 'pull_day',
    title: 'PULL DAY (Kéo: Lưng & Tay trước)',
    author: 'VinceCore Coach',
    level: 'Người mới',
    userCount: 1824,
    muscleCategory: 'Lưng',
    exerciseCount: 5,
  ),
  DailyRoutineRecord(
    id: 'push_day',
    title: 'PUSH DAY (Đẩy: Ngực, Vai, Tay sau)',
    author: 'VinceCore Coach',
    level: 'Người mới',
    userCount: 2310,
    muscleCategory: 'Ngực',
    exerciseCount: 5,
  ),
  DailyRoutineRecord(
    id: 'arm_day',
    title: 'Lịch tập tay hàng ngày',
    author: 'VinceCore Coach',
    level: 'Người mới',
    userCount: 1824,
    muscleCategory: 'Tay',
    exerciseCount: 4,
  ),
  DailyRoutineRecord(
    id: 'back_routine',
    title: 'Routine tập lưng hàng ngày (V-Taper)',
    author: 'VinceCore Coach',
    level: 'Người mới',
    userCount: 1271,
    muscleCategory: 'Lưng',
    exerciseCount: 5,
  ),
  DailyRoutineRecord(
    id: 'shoulder_routine',
    title: 'Lịch tập vai hàng ngày (3D Delts)',
    author: 'VinceCore Coach',
    level: 'Người mới',
    userCount: 1314,
    muscleCategory: 'Vai',
    exerciseCount: 4,
  ),
  DailyRoutineRecord(
    id: 'chest_routine',
    title: 'Routine tập ngực dày & rộng',
    author: 'VinceCore Coach',
    level: 'Người mới',
    userCount: 1323,
    muscleCategory: 'Ngực',
    exerciseCount: 5,
  ),
  DailyRoutineRecord(
    id: 'leg_routine',
    title: 'Lịch tập chân đùi & mông săn chắc',
    author: 'VinceCore Coach',
    level: 'Người mới',
    userCount: 940,
    muscleCategory: 'Chân',
    exerciseCount: 4,
  ),
];

const defaultMuscleRecoveryList = <MuscleRecoveryInfo>[
  MuscleRecoveryInfo(
      name: 'Ngực',
      percentage: 95,
      lastTrainedDaysAgo: 3,
      targetSets: 10,
      completedSets: 8),
  MuscleRecoveryInfo(
      name: 'Vai',
      percentage: 40,
      lastTrainedDaysAgo: 1,
      targetSets: 10,
      completedSets: 6),
  MuscleRecoveryInfo(
      name: 'Lưng',
      percentage: 85,
      lastTrainedDaysAgo: 2,
      targetSets: 12,
      completedSets: 10),
  MuscleRecoveryInfo(
      name: 'Tay trước',
      percentage: 90,
      lastTrainedDaysAgo: 3,
      targetSets: 8,
      completedSets: 6),
  MuscleRecoveryInfo(
      name: 'Tay sau',
      percentage: 50,
      lastTrainedDaysAgo: 1,
      targetSets: 8,
      completedSets: 4),
  MuscleRecoveryInfo(
      name: 'Cơ bụng',
      percentage: 100,
      lastTrainedDaysAgo: 4,
      targetSets: 6,
      completedSets: 6),
  MuscleRecoveryInfo(
      name: 'Đùi trước',
      percentage: 70,
      lastTrainedDaysAgo: 2,
      targetSets: 12,
      completedSets: 8),
  MuscleRecoveryInfo(
      name: 'Cơ cầu vai trên',
      percentage: 80,
      lastTrainedDaysAgo: 2,
      targetSets: 6,
      completedSets: 4),
  MuscleRecoveryInfo(
      name: 'Cẳng tay',
      percentage: 90,
      lastTrainedDaysAgo: 3,
      targetSets: 6,
      completedSets: 4),
  MuscleRecoveryInfo(
      name: 'Lưng dưới',
      percentage: 85,
      lastTrainedDaysAgo: 2,
      targetSets: 8,
      completedSets: 6),
];

const defaultOneRmStats = <OneRmStat>[
  OneRmStat(
      exerciseName: 'Squat',
      weightKg: 110.0,
      topPercentage: 18,
      completedSets: 11,
      isUp: true),
  OneRmStat(
      exerciseName: 'Bench Press',
      weightKg: 92.5,
      topPercentage: 14,
      completedSets: 11,
      isUp: true),
  OneRmStat(
      exerciseName: 'Deadlift',
      weightKg: 145.0,
      topPercentage: 12,
      completedSets: 3,
      isUp: true),
];

const catalogFoods = <FoodRecord>[
  // ==================== PROTEIN (ĐẠM XÂY DỰNG CƠ BẮP) ====================
  FoodRecord(
    name: 'Ức gà áp chảo',
    category: 'PROTEIN',
    subCategory: 'Đạm nạc tinh khiết',
    kcal: 165,
    protein: 31.0,
    carbs: 0.0,
    fat: 3.6,
    serving: '100g chín',
    imageUrl:
        'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Nguồn đạm nạc số 1 giúp phục hồi và phát triển cơ bắp tối ưu mà không dư thừa calo.',
  ),
  FoodRecord(
    name: 'Thăn bò Úc áp chảo',
    category: 'PROTEIN',
    subCategory: 'Đạm & Sắt, Creatine',
    kcal: 210,
    protein: 26.0,
    carbs: 0.0,
    fat: 11.0,
    serving: '100g',
    imageUrl:
        'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Giàu Kẽm, Sắt sinh học và Creatine tự nhiên gia tăng sức mạnh bùng nổ khi tập nặng.',
  ),
  FoodRecord(
    name: 'Cá hồi Na Uy nướng',
    category: 'PROTEIN',
    subCategory: 'Đạm & Omega-3',
    kcal: 208,
    protein: 22.0,
    carbs: 0.0,
    fat: 13.0,
    serving: '100g',
    imageUrl:
        'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Chứa axit béo Omega-3 EPA/DHA chống viêm khớp và tối ưu chuyển hóa mỡ thừa.',
  ),
  FoodRecord(
    name: 'Tôm biển hấp sả',
    category: 'PROTEIN',
    subCategory: 'Đạm siêu nạc',
    kcal: 99,
    protein: 24.0,
    carbs: 0.2,
    fat: 0.3,
    serving: '100g',
    imageUrl:
        'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Hàm lượng calo cực thấp, giàu canxi và protein nạc tinh khiết cho giai đoạn Cutting.',
  ),
  FoodRecord(
    name: 'Trứng gà ta luộc',
    category: 'PROTEIN',
    subCategory: 'Đạm hoàn chỉnh & Choline',
    kcal: 155,
    protein: 13.0,
    carbs: 1.1,
    fat: 11.0,
    serving: '2 quả vừa',
    imageUrl:
        'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Hồ sơ axit amin sinh học đạt điểm 100/100, giàu Choline tăng cường dẫn truyền thần kinh cơ.',
  ),
  FoodRecord(
    name: 'Whey Protein Isolate',
    category: 'PROTEIN',
    subCategory: 'Đạm hấp thu siêu nhanh',
    kcal: 120,
    protein: 27.0,
    carbs: 1.0,
    fat: 0.5,
    serving: '1 muỗng (30g)',
    imageUrl:
        'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Hấp thu vào dòng máu trong 20 phút sau buổi tập, kích hoạt tổng hợp cơ bắp mTOR.',
  ),

  // ==================== CARBS (TINH BỘT NĂNG LƯỢNG) ====================
  FoodRecord(
    name: 'Yến mạch nguyên hạt (Oats)',
    category: 'CARBS',
    subCategory: 'Tinh bột chuyển hóa chậm',
    kcal: 389,
    protein: 17.0,
    carbs: 66.0,
    fat: 7.0,
    serving: '100g khô',
    imageUrl:
        'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Giàu chất xơ hòa tan Beta-Glucan, cung cấp năng lượng tập luyện bền bỉ suốt 3-4 giờ.',
  ),
  FoodRecord(
    name: 'Khoai lang vàng luộc',
    category: 'CARBS',
    subCategory: 'Tinh bột chậm & Vitamin A',
    kcal: 86,
    protein: 1.6,
    carbs: 20.0,
    fat: 0.1,
    serving: '100g',
    imageUrl:
        'https://images.unsplash.com/photo-1596097635121-14b63b7a0c19?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Chỉ số đường huyết GI thấp, ngăn tích trữ mỡ thừa và bổ sung nguồn Kali dồi dào chống chuột rút.',
  ),
  FoodRecord(
    name: 'Gạo lứt huyết rồng',
    category: 'CARBS',
    subCategory: 'Tinh bột nguyên cám',
    kcal: 111,
    protein: 2.6,
    carbs: 23.0,
    fat: 0.9,
    serving: '100g chín',
    imageUrl:
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Giàu khoáng chất Magie và Vitamin nhóm B hỗ trợ chuyển hóa năng lượng ATP tối đa.',
  ),
  FoodRecord(
    name: 'Cơm trắng dẻo',
    category: 'CARBS',
    subCategory: 'Nạp Glycogen nhanh',
    kcal: 130,
    protein: 2.7,
    carbs: 28.0,
    fat: 0.3,
    serving: '100g chín',
    imageUrl:
        'https://images.unsplash.com/photo-1516684732162-798a0062be99?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Nạp đầy kho dự trữ Glycogen trong cơ bắp cực nhanh sau các buổi tập cường độ cao.',
  ),
  FoodRecord(
    name: 'Chuối già Nam Mỹ',
    category: 'FRUIT',
    subCategory: 'Pre/Post Workout Snack',
    kcal: 89,
    protein: 1.1,
    carbs: 23.0,
    fat: 0.3,
    serving: '1 quả vừa (100g)',
    imageUrl:
        'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Nguồn Kali và Carb tự nhiên lý tưởng dùng trước khi tập 30 phút để tăng sức bền.',
  ),

  // ==================== FATS & NUTS (CHẤT BÉO TỐT) ====================
  FoodRecord(
    name: 'Bơ sáp tươi',
    category: 'FATS',
    subCategory: 'Chất béo không bão hòa đơn',
    kcal: 160,
    protein: 2.0,
    carbs: 9.0,
    fat: 15.0,
    serving: '100g',
    imageUrl:
        'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Giàu Axit Oleic và Kali, hỗ trợ sản sinh Testosterone tự nhiên và cải thiện sức khỏe tim mạch.',
  ),
  FoodRecord(
    name: 'Hạt hạnh nhân sấy',
    category: 'SNACKS',
    subCategory: 'Hạt dinh dưỡng & Vitamin E',
    kcal: 579,
    protein: 21.0,
    carbs: 22.0,
    fat: 50.0,
    serving: '100g',
    imageUrl:
        'https://images.unsplash.com/photo-1508061253366-f7da158b6d46?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Chứa lượng chất béo tốt và Magie cao giúp cơ bắp thư giãn và cải thiện chất lượng giấc ngủ sâu.',
  ),
  FoodRecord(
    name: 'Bơ đậu phộng nguyên chất',
    category: 'FATS',
    subCategory: 'Chất béo & Năng lượng cao',
    kcal: 588,
    protein: 25.0,
    carbs: 20.0,
    fat: 50.0,
    serving: '2 muỗng (32g)',
    imageUrl:
        'https://images.unsplash.com/photo-1589733955941-5eeaf752f6dd?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Mật độ calo và protein cao, là món ăn lý tưởng cho người cần xả cơ (Bulking) sạch sẽ.',
  ),

  // ==================== VEGETABLES & FRUITS (RAU CỦ QUẢ) ====================
  FoodRecord(
    name: 'Bông cải xanh (Broccoli)',
    category: 'VEGETABLES',
    subCategory: 'Rau kháng viêm & Chống Oxy hóa',
    kcal: 34,
    protein: 2.8,
    carbs: 7.0,
    fat: 0.4,
    serving: '100g',
    imageUrl:
        'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Chứa Sulforaphane và Indole-3-Carbinol giúp cân bằng Hormone Estrogen và thải độc cơ thể.',
  ),
  FoodRecord(
    name: 'Cải bó xôi (Spinach)',
    category: 'VEGETABLES',
    subCategory: 'Rau xanh đậm & Nitrat tự nhiên',
    kcal: 23,
    protein: 2.9,
    carbs: 3.6,
    fat: 0.4,
    serving: '100g',
    imageUrl:
        'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Tăng cường Nitric Oxide giúp giãn nở mạch máu và gia tăng độ bơm máu (Muscle Pump).',
  ),
  FoodRecord(
    name: 'Quả việt quất tươi',
    category: 'FRUIT',
    subCategory: 'Siêu quả chống Oxy hóa',
    kcal: 57,
    protein: 0.7,
    carbs: 14.0,
    fat: 0.3,
    serving: '100g',
    imageUrl:
        'https://images.unsplash.com/photo-1498557850523-fd3d118b962e?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Giàu Anthocyanin giảm đau nhức cơ bắp DOMS và thúc đẩy hồi phục thần kinh sau tập.',
  ),

  // ==================== DAIRY (SỮA & CHẾ PHẨM) ====================
  FoodRecord(
    name: 'Sữa chua Hy Lạp 0% Fat',
    category: 'DAIRY',
    subCategory: 'Đạm Casein & Men vi sinh',
    kcal: 59,
    protein: 10.0,
    carbs: 3.6,
    fat: 0.4,
    serving: '100g',
    imageUrl:
        'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500&auto=format&fit=crop&q=80',
    benefits:
        'Gấp đôi hàm lượng protein so với sữa chua thường, hỗ trợ tiêu hóa hấp thu dinh dưỡng.',
  ),
];

const catalogExercises = <ExerciseRecord>[
  // ==================== CHEST (NGỰC) ====================
  ExerciseRecord(
    name: 'Barbell Bench Press (Đẩy ngực tạ đòn)',
    muscle: 'CHEST',
    category: 'Ngực giữa',
    equipment: 'BARBELL',
    difficulty: 'INTERMEDIATE',
    target: 'Cơ ngực lớn (Pectoralis Major)',
    secondaryMuscles: ['Tay sau (Triceps)', 'Vai trước (Anterior Deltoid)'],
    targetSets: 4,
    targetReps: '8-10',
    suggestedWeight: '60kg',
    imageUrl:
        'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Barbell-Bench-Press.gif',
    instructions: [
      'Nằm ngửa trên ghế phẳng, 2 chân chạm vững trên sàn, mắt nhìn thẳng dưới thanh đòn.',
      'Nắm đòn rộng hơn vai một chút (khoảng 1.5 lần vai), khép nhẹ xương bả vai ra sau.',
      'Hít sâu, gồng cơ core và hạ thanh đòn có kiểm soát chạm nhẹ vào giữa ngực.',
      'Thở ra, dùng lực cơ ngực đẩy mạnh thanh đòn lên vị trí ban đầu, không khóa cứng khớp khuỷu tay.',
    ],
  ),
  ExerciseRecord(
    name: 'Incline Dumbbell Press (Đẩy ngực trên tạ đơn)',
    muscle: 'CHEST',
    category: 'Ngực trên',
    equipment: 'DUMBBELL',
    difficulty: 'BEGINNER',
    target: 'Cơ ngực trên (Clavicular Head)',
    secondaryMuscles: ['Vai trước', 'Tay sau'],
    targetSets: 4,
    targetReps: '10-12',
    suggestedWeight: '20kg',
    imageUrl:
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Incline-Dumbbell-Press.gif',
    instructions: [
      'Điều chỉnh ghế dốc lên một góc 30-45 độ.',
      'Cầm tạ đơn trên đùi, dùng đùi đẩy tạ lên ngang ngực khi ngả lưng.',
      'Mở khuỷu tay khoảng 45-60 độ so với thân người.',
      'Đẩy tạ lên theo đường vòng cung tự nhiên rồi hạ chậm trong 2-3 giây để ngực trên căng tối đa.',
    ],
  ),
  ExerciseRecord(
    name: 'Cable Chest Fly / Crossover (Ép ngực cáp)',
    muscle: 'CHEST',
    category: 'Cô lập ngực',
    equipment: 'CABLE',
    difficulty: 'BEGINNER',
    target: 'Cơ ngực trong & viền ngực',
    secondaryMuscles: ['Vai trước'],
    targetSets: 3,
    targetReps: '12-15',
    suggestedWeight: '15kg',
    imageUrl:
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Cable-Crossover.gif',
    instructions: [
      'Chỉnh ròng rọc ở vị trí ngang ngực hoặc cao hơn vai.',
      'Bước một chân lên trước để giữ thăng bằng, khuỷu tay hơi cong cố định.',
      'Kéo hai tay nắm về phía trước ngực, tưởng tượng như đang ôm một thân cây lớn.',
      'Siết chặt cơ ngực ở điểm chạm 1 giây trước khi nhả chậm về hai bên.',
    ],
  ),
  ExerciseRecord(
    name: 'Chest Dips (Chống xà kép ngực)',
    muscle: 'CHEST',
    category: 'Ngực dưới & Thể lực',
    equipment: 'BODYWEIGHT',
    difficulty: 'INTERMEDIATE',
    target: 'Ngực dưới & Tay sau',
    secondaryMuscles: ['Cơ vai trước'],
    targetSets: 3,
    targetReps: '8-12',
    suggestedWeight: 'Bodyweight',
    imageUrl:
        'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/06/Chest-Dips.gif',
    instructions: [
      'Nắm chắc hai thanh xà song song, duỗi thẳng tay nâng toàn bộ cơ thể lên.',
      'Hơi nghiêng thân trên về phía trước một góc 30 độ để tập trung vào cơ ngực.',
      'Gập khuỷu tay hạ người xuống cho đến khi cánh tay vuông góc với sàn.',
      'Đẩy mạnh tay trở lại vị trí bắt đầu, gồng siết ngực dưới.',
    ],
  ),

  // ==================== BACK (LƯNG & XÔ) ====================
  ExerciseRecord(
    name: 'Conventional Deadlift (Kéo tạ đòn tiếp đất)',
    muscle: 'BACK',
    category: 'Toàn thân & Chuỗi sau',
    equipment: 'BARBELL',
    difficulty: 'ADVANCED',
    target: 'Toàn bộ lưng & Đùi sau (Posterior Chain)',
    secondaryMuscles: ['Cơ xô', 'Cầu vai', 'Cẳng tay', 'Mông'],
    targetSets: 4,
    targetReps: '5-6',
    suggestedWeight: '100kg',
    imageUrl:
        'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Barbell-Deadlift.gif',
    instructions: [
      'Đứng hai chân rộng bằng hông, thanh đòn nằm ngay trên giữa bàn chân.',
      'Gập người nắm lấy thanh đòn, ống đồng chạm nhẹ vào thanh đòn.',
      'Ưỡn ngực, giữ cột sống thẳng, khóa chặt cơ xô để tạo độ cứng vững.',
      'Đạp mạnh chân xuống sàn, kéo tạ thẳng đứng lên và khóa khớp hông ở đỉnh.',
    ],
  ),
  ExerciseRecord(
    name: 'Lat Pulldown (Kéo xô máy tạ)',
    muscle: 'BACK',
    category: 'Độ rộng lưng (V-Taper)',
    equipment: 'MACHINE',
    difficulty: 'BEGINNER',
    target: 'Cơ xô lưng (Latissimus Dorsi)',
    secondaryMuscles: ['Bắp tay trước', 'Cơ lưng giữa'],
    targetSets: 4,
    targetReps: '10-12',
    suggestedWeight: '45kg',
    imageUrl:
        'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Lat-Pulldown.gif',
    instructions: [
      'Ngồi vào máy, cố định chắc chắn đùi dưới đệm giữ.',
      'Nắm thanh đòn rộng hơn vai, hơi ngả người ra sau khoảng 10-15 độ.',
      'Kéo thanh đòn xuống chạm nhẹ ngực trên, hướng khuỷu tay xuống sàn.',
      'Nhả tạ từ từ có kiểm soát để cơ xô được kéo giãn tối đa.',
    ],
  ),
  ExerciseRecord(
    name: 'Barbell Bent-Over Row (Chèo tạ đòn)',
    muscle: 'BACK',
    category: 'Độ dày lưng',
    equipment: 'BARBELL',
    difficulty: 'INTERMEDIATE',
    target: 'Cơ lưng giữa (Rhomboids & Traps)',
    secondaryMuscles: ['Cơ xô', 'Tay trước', 'Lưng dưới'],
    targetSets: 4,
    targetReps: '8-10',
    suggestedWeight: '50kg',
    imageUrl:
        'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Barbell-Bent-Over-Row.gif',
    instructions: [
      'Đứng rộng bằng vai, cúi gập người về phía trước góc 45 độ, giữ lưng thẳng.',
      'Cầm đòn tạ buông thõng tự nhiên trước gối.',
      'Kéo đòn tạ về phía rốn, ép chặt hai bả vai vào nhau ở đỉnh chuyển động.',
      'Hạ tạ xuống từ từ trong khi vẫn giữ vững góc nghiêng của thân người.',
    ],
  ),
  ExerciseRecord(
    name: 'Seated Cable Row (Kéo cáp ngồi thẳng lưng)',
    muscle: 'BACK',
    category: 'Lưng giữa & Cầu vai',
    equipment: 'CABLE',
    difficulty: 'BEGINNER',
    target: 'Cơ lưng giữa & Cơ xô',
    secondaryMuscles: ['Tay trước'],
    targetSets: 3,
    targetReps: '12',
    suggestedWeight: '40kg',
    imageUrl:
        'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Seated-Cable-Row.gif',
    instructions: [
      'Đặt chân lên bàn đạp, giữ đầu gối hơi chùng nhẹ, lưng thẳng tự nhiên.',
      'Nắm tay cầm V-Bar, kéo về phía bụng dưới.',
      'Ưỡn ngực và ép chặt hai bả vai khi tay cầm chạm bụng.',
      'Duỗi tay trở lại từ từ, tránh giật người hoặc lắc lư lưng quá mức.',
    ],
  ),

  // ==================== SHOULDERS (VAI) ====================
  ExerciseRecord(
    name: 'Overhead Barbell Press / OHP (Đẩy vai tạ đòn đứng)',
    muscle: 'SHOULDERS',
    category: 'Sức mạnh vai toàn diện',
    equipment: 'BARBELL',
    difficulty: 'ADVANCED',
    target: 'Cơ đenta vai trước & vai giữa (Deltoids)',
    secondaryMuscles: ['Tay sau', 'Cơ core', 'Cầu vai'],
    targetSets: 4,
    targetReps: '6-8',
    suggestedWeight: '40kg',
    imageUrl:
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Overhead-Press.gif',
    instructions: [
      'Đứng thẳng, chân rộng bằng vai, đặt thanh đòn ngang xương đòn trước cổ.',
      'Gồng chặt cơ mông và cơ bụng để bảo vệ cột sống thắt lưng.',
      'Đẩy thanh đòn thẳng lên trên đỉnh đầu theo phương thẳng đứng.',
      'Khóa cánh tay nhẹ ở đỉnh rồi hạ đòn có kiểm soát về vị trí ban đầu.',
    ],
  ),
  ExerciseRecord(
    name: 'Dumbbell Lateral Raise (Dang tạ đơn sang ngang)',
    muscle: 'SHOULDERS',
    category: 'Vai giữa (Tạo độ rộng vai 3D)',
    equipment: 'DUMBBELL',
    difficulty: 'BEGINNER',
    target: 'Cơ vai giữa (Lateral Deltoid)',
    secondaryMuscles: ['Cầu vai trên'],
    targetSets: 4,
    targetReps: '12-15',
    suggestedWeight: '8kg',
    imageUrl:
        'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Lateral-Raise.gif',
    instructions: [
      'Đứng thẳng hoặc ngồi ghế, hai tay cầm tạ đơn buông dọc bên hông.',
      'Khuỷu tay hơi cong nhẹ khoảng 10-15 độ cố định.',
      'Nâng tạ sang hai bên ngang tầm vai, dẫn hướng bằng khuỷu tay.',
      'Dừng 1 giây ở đỉnh rồi hạ tạ chậm rãi trong 2 giây.',
    ],
  ),
  ExerciseRecord(
    name: 'Rear Delt Fly / Reverse Pec Deck (Ép vai sau)',
    muscle: 'SHOULDERS',
    category: 'Vai sau & Cải thiện tư thế',
    equipment: 'MACHINE',
    difficulty: 'BEGINNER',
    target: 'Cơ vai sau (Posterior Deltoid)',
    secondaryMuscles: ['Lưng giữa', 'Cơ trám'],
    targetSets: 3,
    targetReps: '12-15',
    suggestedWeight: '30kg',
    imageUrl:
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Rear-Delt-Machine-Flys.gif',
    instructions: [
      'Ngồi quay mặt vào đệm máy, ngực áp sát vào tựa.',
      'Cầm hai tay nắm ngang tầm vai, khuỷu tay giữ hơi cong.',
      'Kéo hai tay ra phía sau theo hình vòng cung cho đến khi cơ vai sau co thắt tối đa.',
      'Từ từ đưa tay về vị trí ban đầu không để tạ chạm nhau.',
    ],
  ),

  // ==================== LEGS (CHÂN & MÔNG) ====================
  ExerciseRecord(
    name: 'Barbell Back Squat (Gánh tạ đòn)',
    muscle: 'LEGS',
    category: 'Đùi trước & Mông',
    equipment: 'BARBELL',
    difficulty: 'ADVANCED',
    target: 'Cơ tứ đầu đùi (Quadriceps) & Mông (Glutes)',
    secondaryMuscles: ['Đùi sau', 'Lưng dưới', 'Cơ core'],
    targetSets: 4,
    targetReps: '6-8',
    suggestedWeight: '80kg',
    imageUrl:
        'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/BARBELL-SQUAT.gif',
    instructions: [
      'Đặt thanh đòn trên cơ cầu vai (High bar) hoặc gai xương bả vai (Low bar).',
      'Chân đứng rộng bằng hoặc hơn vai một chút, mũi chân hơi xoay ra ngoài 15-30 độ.',
      'Hít sâu vào bụng, siết chặt cơ core, đẩy hông ra sau và gập gối hạ thấp trọng tâm.',
      'Hạ sâu đến khi đùi song song mặt đất hoặc sâu hơn, sau đó đạp mạnh gót chân để đứng lên.',
    ],
  ),
  ExerciseRecord(
    name: 'Romanian Deadlift / RDL (Kéo đùi sau & Mông)',
    muscle: 'LEGS',
    category: 'Đùi sau & Mông',
    equipment: 'DUMBBELL',
    difficulty: 'INTERMEDIATE',
    target: 'Cơ gân kheo (Hamstrings) & Cơ mông (Glutes)',
    secondaryMuscles: ['Lưng dưới', 'Cẳng tay'],
    targetSets: 4,
    targetReps: '10-12',
    suggestedWeight: '25kg',
    imageUrl:
        'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Romanian-Deadlift.gif',
    instructions: [
      'Đứng thẳng cầm tạ đơn sát đùi trước, đầu gối chùng nhẹ khoảng 10 độ.',
      'Đẩy hông ra sau hết mức có thể, trượt tạ dọc theo đùi xuống qua đầu gối.',
      'Giữ lưng thẳng tuyệt đối cho đến khi cảm nhận độ căng sâu ở đùi sau.',
      'Dùng lực cơ mông và đùi sau đẩy hông về phía trước để đứng thẳng dậy.',
    ],
  ),
  ExerciseRecord(
    name: 'Leg Press 45° (Đạp đùi máy nghiêng)',
    muscle: 'LEGS',
    category: 'Phì đại cơ đùi',
    equipment: 'MACHINE',
    difficulty: 'BEGINNER',
    target: 'Cơ tứ đầu đùi & Cơ mông',
    secondaryMuscles: ['Đùi sau', 'Bắp chân'],
    targetSets: 4,
    targetReps: '10-12',
    suggestedWeight: '120kg',
    imageUrl:
        'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Leg-Press.gif',
    instructions: [
      'Ngồi sát lưng và mông vào ghế đệm, đặt hai bàn chân ở giữa bàn đạp.',
      'Mở khóa an toàn, hạ bàn đạp xuống chậm cho đến khi gối tạo góc 90 độ.',
      'Không để mông bị nhấc bổng khỏi ghế khi hạ sâu.',
      'Đạp mạnh bằng toàn bộ bàn chân để đẩy bàn đạp lên, không khóa gối ở đỉnh.',
    ],
  ),
  ExerciseRecord(
    name: 'Hip Thrust (Đẩy hông tạ đòn tăng cơ mông)',
    muscle: 'LEGS',
    category: 'Cơ mông cô lập',
    equipment: 'BARBELL',
    difficulty: 'INTERMEDIATE',
    target: 'Cơ mông lớn (Gluteus Maximus)',
    secondaryMuscles: ['Đùi sau', 'Cơ core'],
    targetSets: 4,
    targetReps: '10-12',
    suggestedWeight: '70kg',
    imageUrl:
        'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Barbell-Hip-Thrust.gif',
    instructions: [
      'Tựa lưng trên vào cạnh ghế phẳng, đặt đòn tạ có đệm lót trên khớp hông.',
      'Đặt hai bàn chân rộng bằng vai, cẳng chân vuông góc với sàn khi ở vị trí đỉnh.',
      'Đạp gót chân, đẩy hông lên cao cho đến khi đùi và thân người tạo thành đường thẳng.',
      'Gồng siết cơ mông chặt trong 1-2 giây trước khi hạ có kiểm soát.',
    ],
  ),

  // ==================== ARMS (TAY TRƯỚC & TAY SAU) ====================
  ExerciseRecord(
    name: 'Barbell Biceps Curl (Cuộn bắp tay trước tạ đòn)',
    muscle: 'ARMS',
    category: 'Bắp tay trước',
    equipment: 'BARBELL',
    difficulty: 'BEGINNER',
    target: 'Cơ bắp tay trước (Biceps Brachii)',
    secondaryMuscles: ['Cẳng tay (Brachioradialis)'],
    targetSets: 3,
    targetReps: '10-12',
    suggestedWeight: '25kg',
    imageUrl:
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Barbell-Curl.gif',
    instructions: [
      'Đứng thẳng, hai tay nắm thanh đòn rộng bằng vai, lòng bàn tay hướng ra trước.',
      'Giữ cố định khuỷu tay sát hai bên sườn.',
      'Dùng lực bắp tay cuộn đòn tạ lên đến ngang ngực trên.',
      'Siết chặt bắp tay ở đỉnh rồi hạ tạ chậm rãi trong 3 giây.',
    ],
  ),
  ExerciseRecord(
    name: 'Hammer Curl (Cuộn tạ búa - Tăng độ dày tay)',
    muscle: 'ARMS',
    category: 'Tay trước & Cẳng tay',
    equipment: 'DUMBBELL',
    difficulty: 'BEGINNER',
    target: 'Cơ cánh tay (Brachialis) & Cẳng tay',
    secondaryMuscles: ['Bắp tay trước'],
    targetSets: 3,
    targetReps: '12',
    suggestedWeight: '12kg',
    imageUrl:
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Hammer-Curl.gif',
    instructions: [
      'Cầm hai quả tạ đơn với lòng bàn tay hướng vào nhau.',
      'Giữ lưng thẳng, khóa chặt khuỷu tay bên hông.',
      'Nâng tạ lên giữ nguyên tư thế lòng bàn tay đối diện.',
      'Hạ tạ chậm về vị trí ban đầu.',
    ],
  ),
  ExerciseRecord(
    name: 'Triceps Rope Pushdown (Kéo cáp tay sau dây thừng)',
    muscle: 'ARMS',
    category: 'Bắp tay sau',
    equipment: 'CABLE',
    difficulty: 'BEGINNER',
    target: 'Cơ bắp tay sau (Triceps - Lateral & Medial Head)',
    secondaryMuscles: ['Cẳng tay'],
    targetSets: 3,
    targetReps: '12-15',
    suggestedWeight: '25kg',
    imageUrl:
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Tricep-Rope-Pushdown.gif',
    instructions: [
      'Đứng trước máy cáp, gắn dây thừng ở vị trí ròng rọc trên cùng.',
      'Khép khuỷu tay sát sườn, gập cẳng tay tạo góc 90 độ.',
      'Kéo dây xuống thẳng dưới, tách nhẹ hai đầu dây thừng ở cuối động tác.',
      'Siết chặt bắp tay sau trong 1 giây trước khi thả cáp lên ngang ngực.',
    ],
  ),
  ExerciseRecord(
    name: 'Skull Crushers / Lying Triceps Extension (Duỗi tay sau)',
    muscle: 'ARMS',
    category: 'Đầu dài tay sau (Long Head)',
    equipment: 'BARBELL',
    difficulty: 'INTERMEDIATE',
    target: 'Cơ đầu dài bắp tay sau (Long Head Triceps)',
    secondaryMuscles: ['Khuỷu tay & cẳng tay'],
    targetSets: 3,
    targetReps: '10-12',
    suggestedWeight: '20kg',
    imageUrl:
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Lying-Triceps-Extension.gif',
    instructions: [
      'Nằm phẳng trên ghế, cầm đòn tạ EZ nâng thẳng đứng vuông góc với sàn.',
      'Giữ cố định bắp tay trên, chỉ gập khuỷu tay hạ thanh đòn xuống sát trán/đỉnh đầu.',
      'Dùng lực bắp tay sau duỗi thẳng tay trở lại vị trí ban đầu.',
    ],
  ),

  // ==================== CORE (BỤNG & CORE) ====================
  ExerciseRecord(
    name: 'Hanging Leg Raise (Treo người nâng chân)',
    muscle: 'CORE',
    category: 'Bụng dưới',
    equipment: 'BODYWEIGHT',
    difficulty: 'INTERMEDIATE',
    target: 'Cơ bụng dưới & Cơ gập hông',
    secondaryMuscles: ['Cơ liên sườn', 'Cẳng tay giữ xà'],
    targetSets: 3,
    targetReps: '12-15',
    suggestedWeight: 'Bodyweight',
    imageUrl:
        'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Hanging-Leg-Raise.gif',
    instructions: [
      'Treo người trên thanh xà đơn, hai tay nắm rộng hơn vai.',
      'Gồng chặt bụng, nâng thẳng hai chân (hoặc co gối) lên đến khi đùi vuông góc với thân người.',
      'Hơi cuộn xương chậu về phía trước ở điểm cao nhất để kích hoạt tối đa cơ bụng dưới.',
      'Hạ chân xuống chậm rãi, kiểm soát tránh đung đưa người theo quán tính.',
    ],
  ),
  ExerciseRecord(
    name: 'Cable Woodchopper (Kéo cáp chéo siết eo)',
    muscle: 'CORE',
    category: 'Cơ liên sườn (Obliques)',
    equipment: 'CABLE',
    difficulty: 'BEGINNER',
    target: 'Cơ liên sườn trong & ngoài',
    secondaryMuscles: ['Cơ bụng thẳng', 'Vai'],
    targetSets: 3,
    targetReps: '12 mỗi bên',
    suggestedWeight: '15kg',
    imageUrl:
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Cable-Woodchopper.gif',
    instructions: [
      'Chỉnh ròng rọc lên vị trí cao, đứng ngang với máy, hai tay nắm tay cầm.',
      'Xoay thân người kéo cáp chéo từ trên cao xuống phía gối đối diện.',
      'Dùng lực xoay của vùng eo bụng, giữ tay tương đối thẳng.',
      'Từ từ đưa tay về vị trí ban đầu và lặp lại cho bên còn lại.',
    ],
  ),
  ExerciseRecord(
    name: 'Plank (Gồng bụng chống đẩy tĩnh)',
    muscle: 'CORE',
    category: 'Độ bền & Ổn định Core',
    equipment: 'BODYWEIGHT',
    difficulty: 'BEGINNER',
    target: 'Cơ bụng ngang & Toàn bộ cơ Core',
    secondaryMuscles: ['Vai', 'Cơ mông', 'Đùi trước'],
    targetSets: 3,
    targetReps: '60s',
    suggestedWeight: 'Bodyweight',
    imageUrl:
        'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=600&auto=format&fit=crop&q=80',
    gifUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Plank.gif',
    instructions: [
      'Chống khuỷu tay vuông góc dưới vai, hai mũi chân chạm sàn.',
      'Giữ cơ thể từ đầu đến gót chân thành một đường thẳng tắp.',
      'Siết chặt cơ bụng và cơ mông, không để hông bị võng xuống hay nhô cao.',
      'Hít thở đều đặn và duy trì trạng thái gồng trong suốt thời gian quy định.',
    ],
  ),

  // ==================== CARDIO (TIM MẠCH & ĐỐT MỠ) ====================
  ExerciseRecord(
    name: 'Incline Treadmill Walk (Đi bộ dốc đốt mỡ)',
    muscle: 'CARDIO',
    category: 'Cardio nhịp tim vùng 2 (Zone 2)',
    equipment: 'MACHINE',
    difficulty: 'BEGINNER',
    target: 'Hệ tim mạch & Đốt mỡ thừa',
    secondaryMuscles: ['Bắp chân', 'Cơ mông'],
    targetSets: 1,
    targetReps: '20-30 phút',
    suggestedWeight: 'Speed 4.5 / Inc 10',
    imageUrl:
        'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Treadmill.gif',
    instructions: [
      'Điều chỉnh độ dốc máy chạy bộ từ 8% đến 12%, tốc độ từ 4.0 đến 5.5 km/h.',
      'Đi bộ sải bước đều đặn, đánh tay tự nhiên, không bám chặt tay vịn.',
      'Duy trì nhịp tim ở vùng đốt mỡ (khoảng 60-70% nhịp tim tối đa).',
    ],
  ),
  ExerciseRecord(
    name: 'Rowing Machine (Chèo thuyền máy toàn thân)',
    muscle: 'CARDIO',
    category: 'Cardio toàn thân & Sức bền',
    equipment: 'MACHINE',
    difficulty: 'INTERMEDIATE',
    target: 'Hệ tim mạch, Lưng, Chân & Tay',
    secondaryMuscles: ['Cơ xô', 'Cơ đùi', 'Cơ core'],
    targetSets: 3,
    targetReps: '500m mỗi hiệp',
    suggestedWeight: 'Kháng lực 6-8',
    imageUrl:
        'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600&auto=format&fit=crop&q=80',
    gifUrl:
        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Rowing-Machine.gif',
    instructions: [
      'Cố định chân trên bàn đạp, lưng thẳng, nắm thanh kéo.',
      'Đạp mạnh bằng chân trước, sau đó ngả người nhẹ và kéo tay nắm về ngang rốn.',
      'Duỗi tay về trước, gập hông và co gối trượt về vị trí bắt đầu theo đúng trình tự.',
    ],
  ),
];

const workoutHistory = <HistoryRecord>[];
