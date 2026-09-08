import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/models/muscle_recovery_model.dart';

class MuscleRecoverySheet extends StatelessWidget {
  const MuscleRecoverySheet({
    super.key,
    this.report = OverallRecoveryReport.defaultReport,
  });

  final OverallRecoveryReport report;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isLight ? Colors.black12 : Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.fitness_center_rounded, size: 22),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PHỤC HỒI CƠ BẮP',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isLight
                              ? AppColors.lightTextPrimary
                              : AppColors.darkTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tổng thể đạt ${report.overallPercentage}% trạng thái tối ưu',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isLight
                              ? AppColors.lightTextMuted
                              : AppColors.darkTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close_rounded,
                  color: isLight
                      ? AppColors.lightTextPrimary
                      : AppColors.darkTextPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Coach Recommendation Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.statusRecovery.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.statusRecovery.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.tips_and_updates_rounded,
                  size: 20,
                  color: AppColors.statusRecovery,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lời khuyên huấn luyện viên AI',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.statusRecovery,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.advice,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: isLight
                              ? AppColors.lightTextPrimary
                              : AppColors.darkTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'CHI TIẾT 7 NHÓM CƠ CHÍNH',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color:
                  isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted,
            ),
          ),

          const SizedBox(height: 12),

          // Muscle Group Bars
          Expanded(
            child: ListView.separated(
              itemCount: report.muscles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final muscle = report.muscles[index];
                return _MuscleRecoveryItemRow(
                  item: muscle,
                  isLight: isLight,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleRecoveryItemRow extends StatelessWidget {
  const _MuscleRecoveryItemRow({
    required this.item,
    required this.isLight,
  });

  final MuscleRecoveryGroupItem item;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF8F9FA) : const Color(0xFF242426),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Muscle Name & Status Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    item.vietnameseName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${item.muscleGroup})',
                    style: TextStyle(
                      fontSize: 11,
                      color: isLight
                          ? AppColors.lightTextMuted
                          : AppColors.darkTextMuted,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${item.percentage}%',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: item.statusColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.statusText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: item.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  color: isLight
                      ? const Color(0xFFE9ECEF)
                      : const Color(0xFF2C2C2E),
                ),
                FractionallySizedBox(
                  widthFactor: (item.percentage / 100).clamp(0.0, 1.0),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: item.statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Tips / Meta
          Text(
            item.tips,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isLight
                  ? AppColors.lightTextSecondary
                  : AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
