import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum RecoveryStatusLevel {
  low,
  medium,
  good,
  fullyRecovered,
}

class MuscleRecoveryGroupItem {
  const MuscleRecoveryGroupItem({
    required this.muscleGroup,
    required this.vietnameseName,
    required this.percentage,
    required this.hoursAgoTrained,
    required this.targetSets,
    required this.completedSets,
    this.tips = '',
  });

  final String muscleGroup;
  final String vietnameseName;
  final int percentage; // 0 - 100
  final int hoursAgoTrained;
  final int targetSets;
  final int completedSets;
  final String tips;

  RecoveryStatusLevel get statusLevel {
    if (percentage < 65) return RecoveryStatusLevel.low;
    if (percentage < 80) return RecoveryStatusLevel.medium;
    if (percentage < 95) return RecoveryStatusLevel.good;
    return RecoveryStatusLevel.fullyRecovered;
  }

  String get statusText {
    switch (statusLevel) {
      case RecoveryStatusLevel.low:
        return 'Cần nghỉ ngơi';
      case RecoveryStatusLevel.medium:
        return 'Đang hồi phục';
      case RecoveryStatusLevel.good:
        return 'Sẵn sàng tập';
      case RecoveryStatusLevel.fullyRecovered:
        return 'Tối ưu 100%';
    }
  }

  Color get statusColor {
    switch (statusLevel) {
      case RecoveryStatusLevel.low:
        return AppColors.primaryBlueLight;
      case RecoveryStatusLevel.medium:
        return AppColors.skyBlue;
      case RecoveryStatusLevel.good:
        return AppColors.statusRecovery; // Green/Mint
      case RecoveryStatusLevel.fullyRecovered:
        return AppColors.primaryBlueLight; // Cyan/Turquoise
    }
  }
}

class OverallRecoveryReport {
  const OverallRecoveryReport({
    required this.overallPercentage,
    required this.advice,
    required this.muscles,
  });

  final int overallPercentage;
  final String advice;
  final List<MuscleRecoveryGroupItem> muscles;

  static const defaultReport = OverallRecoveryReport(
    overallPercentage: 78,
    advice:
        '💡 Bạn nên ưu tiên nghỉ ngơi cho nhóm cơ chân hôm nay. Cơ ngực và vai đã sẵn sàng bùng nổ!',
    muscles: [
      MuscleRecoveryGroupItem(
        muscleGroup: 'Chest',
        vietnameseName: 'Ngực',
        percentage: 85,
        hoursAgoTrained: 48,
        targetSets: 12,
        completedSets: 10,
        tips: 'Đã sẵn sàng cho bài tập tạ nặng',
      ),
      MuscleRecoveryGroupItem(
        muscleGroup: 'Back',
        vietnameseName: 'Lưng',
        percentage: 72,
        hoursAgoTrained: 24,
        targetSets: 14,
        completedSets: 12,
        tips: 'Nên giãn cơ lưng xô sau buổi tập',
      ),
      MuscleRecoveryGroupItem(
        muscleGroup: 'Shoulders',
        vietnameseName: 'Vai',
        percentage: 90,
        hoursAgoTrained: 72,
        targetSets: 10,
        completedSets: 8,
        tips: 'Độ linh hoạt khớp vai hoàn hảo',
      ),
      MuscleRecoveryGroupItem(
        muscleGroup: 'Biceps',
        vietnameseName: 'Tay trước',
        percentage: 80,
        hoursAgoTrained: 48,
        targetSets: 8,
        completedSets: 6,
        tips: 'Phục hồi tốt',
      ),
      MuscleRecoveryGroupItem(
        muscleGroup: 'Triceps',
        vietnameseName: 'Tay sau',
        percentage: 76,
        hoursAgoTrained: 36,
        targetSets: 8,
        completedSets: 6,
        tips: 'Có thể tập phụ trợ',
      ),
      MuscleRecoveryGroupItem(
        muscleGroup: 'Legs',
        vietnameseName: 'Chân & Đùi',
        percentage: 60,
        hoursAgoTrained: 18,
        targetSets: 16,
        completedSets: 14,
        tips: 'Cơ bắp đùi còn đau mỏi, cần bổ sung protein & nước',
      ),
      MuscleRecoveryGroupItem(
        muscleGroup: 'Abs',
        vietnameseName: 'Cơ bụng / Core',
        percentage: 95,
        hoursAgoTrained: 72,
        targetSets: 6,
        completedSets: 6,
        tips: 'Sẵn sàng 100%',
      ),
    ],
  );
}
