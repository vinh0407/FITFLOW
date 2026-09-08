import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';

class BodyMuscleRecoverySection extends StatefulWidget {
  const BodyMuscleRecoverySection({super.key});

  @override
  State<BodyMuscleRecoverySection> createState() =>
      _BodyMuscleRecoverySectionState();
}

class _BodyMuscleRecoverySectionState extends State<BodyMuscleRecoverySection> {
  int _viewIndex = 0; // 0 = Mặt trước, 1 = Mặt sau

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final oneRmStats = fitnessRepository.oneRmStats;

    final frontMuscles = [
      {
        'name': 'Vai',
        'percent': '90%',
        'days': '3 ngày trước',
        'color': AppColors.statusRecovery
      },
      {
        'name': 'Ngực',
        'percent': '85%',
        'days': '2 ngày trước',
        'color': AppColors.statusRecovery
      },
      {
        'name': 'Tay trước',
        'percent': '80%',
        'days': '2 ngày trước',
        'color': AppColors.statusRecovery
      },
      {
        'name': 'Cơ bụng',
        'percent': '95%',
        'days': '4 ngày trước',
        'color': AppColors.primaryBlueLight
      },
      {
        'name': 'Đùi trước',
        'percent': '60%',
        'days': '1 ngày trước',
        'color': AppColors.primaryBlueLight
      },
      {
        'name': 'Cẳng tay',
        'percent': '75%',
        'days': '2 ngày trước',
        'color': AppColors.skyBlue
      },
    ];

    final backMuscles = [
      {
        'name': 'Cơ cầu vai',
        'percent': '88%',
        'days': '3 ngày trước',
        'color': AppColors.statusRecovery
      },
      {
        'name': 'Lưng xô',
        'percent': '72%',
        'days': '1 ngày trước',
        'color': AppColors.skyBlue
      },
      {
        'name': 'Tay sau',
        'percent': '76%',
        'days': '1 ngày trước',
        'color': AppColors.skyBlue
      },
      {
        'name': 'Lưng dưới',
        'percent': '82%',
        'days': '3 ngày trước',
        'color': AppColors.statusRecovery
      },
      {
        'name': 'Cơ mông',
        'percent': '65%',
        'days': '1 ngày trước',
        'color': AppColors.primaryBlueLight
      },
      {
        'name': 'Đùi sau & Bắp',
        'percent': '58%',
        'days': '1 ngày trước',
        'color': AppColors.primaryBlueLight
      },
    ];

    final currentMuscles = _viewIndex == 0 ? frontMuscles : backMuscles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Muscle Map Card
        Container(
          decoration: BoxDecoration(
            color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isLight ? 0.03 : 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Phục hồi theo vị trí cơ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isLight
                              ? AppColors.lightTextPrimary
                              : AppColors.darkTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Front / Back Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isLight
                      ? const Color(0xFFF1F3F5)
                      : const Color(0xFF242426),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _viewIndex = 0);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _viewIndex == 0
                                ? (isLight
                                    ? Colors.white
                                    : const Color(0xFF323236))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _viewIndex == 0
                                ? [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Mặt trước',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _viewIndex == 0
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                                color: isLight
                                    ? AppColors.lightTextPrimary
                                    : AppColors.darkTextPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _viewIndex = 1);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _viewIndex == 1
                                ? (isLight
                                    ? Colors.white
                                    : const Color(0xFF323236))
                                : Colors.transparent,
                            boxShadow: _viewIndex == 1
                                ? [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Mặt sau',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _viewIndex == 1
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                                color: isLight
                                    ? AppColors.lightTextPrimary
                                    : AppColors.darkTextPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Muscle list breakdown
              if (currentMuscles.isEmpty)
                _RecoveryEmptyState(isLight: isLight)
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: currentMuscles.length,
                  itemBuilder: (context, index) {
                    final m = currentMuscles[index];
                    final color = m['color'] as Color;
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isLight
                            ? const Color(0xFFF8F9FA)
                            : const Color(0xFF242426),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isLight
                              ? AppColors.lightBorder
                              : AppColors.darkBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                m['name'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isLight
                                      ? AppColors.lightTextPrimary
                                      : AppColors.darkTextPrimary,
                                ),
                              ),
                              Text(
                                m['percent'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            m['days'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: isLight
                                  ? AppColors.lightTextMuted
                                  : AppColors.darkTextMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 2. 1RM Strength Progression Card
        Container(
          decoration: BoxDecoration(
            color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isLight ? 0.03 : 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Mức 1RM & Xếp hạng sức mạnh',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...oneRmStats.take(3).map((stat) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isLight
                        ? const Color(0xFFF8F9FA)
                        : const Color(0xFF242426),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isLight
                          ? AppColors.lightBorder
                          : AppColors.darkBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                stat.exerciseName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isLight
                                      ? AppColors.lightTextPrimary
                                      : AppColors.darkTextPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlueLight
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Top ${stat.topPercentage}%',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryBlueLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.arrow_upward_rounded,
                                size: 13,
                                color: AppColors.statusRecovery,
                              ),
                              Text(
                                '${stat.weightKg.toStringAsFixed(0)} kg (1RM)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.statusRecovery,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '${stat.completedSets} Hiệp',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isLight
                              ? AppColors.lightTextSecondary
                              : AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecoveryEmptyState extends StatelessWidget {
  const _RecoveryEmptyState({required this.isLight});

  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(Icons.monitor_heart_outlined,
              size: 32,
              color:
                  isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted),
          const SizedBox(height: 8),
          Text('Chưa có dữ liệu phục hồi',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isLight
                    ? AppColors.lightTextPrimary
                    : AppColors.darkTextPrimary,
              )),
          const SizedBox(height: 4),
          Text('Hoàn thành một buổi tập để bắt đầu theo dõi cơ bắp.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isLight
                    ? AppColors.lightTextMuted
                    : AppColors.darkTextMuted,
              )),
        ],
      ),
    );
  }
}
