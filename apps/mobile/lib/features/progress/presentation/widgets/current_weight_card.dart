import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/weight_record_model.dart';

class CurrentWeightCard extends StatefulWidget {
  const CurrentWeightCard({
    super.key,
    required this.onLogWeight,
  });

  final VoidCallback onLogWeight;

  @override
  State<CurrentWeightCard> createState() => _CurrentWeightCardState();
}

class _CurrentWeightCardState extends State<CurrentWeightCard> {
  WeightPeriod _selectedPeriod = WeightPeriod.yearly;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final analysis = fitnessRepository.getWeightAnalysis(_selectedPeriod);
    final weightStr = '${analysis.currentWeight.toStringAsFixed(1)} kg';

    Color trendColor;
    Color trendBg;
    switch (analysis.trend) {
      case WeightTrend.increase:
        trendColor = AppColors.statusRecovery; // Green / Healthy muscle gain
        trendBg = AppColors.statusRecovery.withValues(alpha: 0.12);
        break;
      case WeightTrend.decrease:
        trendColor = AppColors.primaryBlueLight;
        trendBg = AppColors.primaryBlueLight.withValues(alpha: 0.12);
        break;
      case WeightTrend.stable:
        trendColor = AppColors.skyBlue;
        trendBg = AppColors.skyBlue.withValues(alpha: 0.12);
        break;
    }

    return Container(
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
          // 1. Metric Header & Period Dropdown
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Weight',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isLight
                          ? AppColors.lightTextSecondary
                          : AppColors.darkTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        weightStr,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: isLight
                              ? AppColors.lightTextPrimary
                              : AppColors.darkTextPrimary,
                        ),
                      ),
                      // Trend pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: trendBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          analysis.trendText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: trendColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Period Dropdown Menu
              PopupMenuButton<WeightPeriod>(
                tooltip: 'Chọn khoảng thời gian',
                initialValue: _selectedPeriod,
                onSelected: (period) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedPeriod = period);
                },
                color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color:
                        isLight ? AppColors.lightBorder : AppColors.darkBorder,
                  ),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: WeightPeriod.weekly,
                    child: Text('Weekly'),
                  ),
                  const PopupMenuItem(
                    value: WeightPeriod.monthly,
                    child: Text('Monthly'),
                  ),
                  const PopupMenuItem(
                    value: WeightPeriod.threeMonths,
                    child: Text('3 Months'),
                  ),
                  const PopupMenuItem(
                    value: WeightPeriod.sixMonths,
                    child: Text('6 Months'),
                  ),
                  const PopupMenuItem(
                    value: WeightPeriod.yearly,
                    child: Text('Yearly'),
                  ),
                ],
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isLight
                        ? const Color(0xFFF1F3F5)
                        : const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isLight
                          ? AppColors.lightBorder
                          : AppColors.darkBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        analysis.periodLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isLight
                              ? AppColors.lightTextPrimary
                              : AppColors.darkTextPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: isLight
                            ? AppColors.lightTextSecondary
                            : AppColors.darkTextSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2. Dynamic Capsule Bar Chart
          _buildCapsuleBarChart(analysis, isLight),

          const SizedBox(height: 16),
          Divider(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            height: 1,
          ),
          const SizedBox(height: 12),

          // 3. Quick Action: Log weight
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Lần đo gần nhất: Hôm nay',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isLight
                      ? AppColors.lightTextMuted
                      : AppColors.darkTextMuted,
                ),
              ),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onLogWeight();
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_circle_outline_rounded,
                        size: 15,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Thêm cân nặng',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isLight
                              ? AppColors.primaryBlue
                              : AppColors.primaryBlueLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCapsuleBarChart(WeightAnalysis analysis, bool isLight) {
    final points = analysis.points;
    if (points.isEmpty) {
      return const SizedBox(
        height: 140,
        child: Center(child: Text('Chưa có dữ liệu cân nặng.')),
      );
    }

    final maxW = points.map((p) => p.weightKg).reduce((a, b) => a > b ? a : b);
    final minW = points.map((p) => p.weightKg).reduce((a, b) => a < b ? a : b);
    final range = (maxW - minW) == 0 ? 1.0 : (maxW - minW);

    return SizedBox(
      height: 130 + MediaQuery.textScalerOf(context).scale(30),
      child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: points.map((pt) {
                      final normalized =
                          ((pt.weightKg - minW) / range).clamp(0.2, 1.0);
                      final barHeight = 30.0 + (normalized * 65.0);
                      final isActive = pt.isActive;

                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Value badge if active
                              if (isActive)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusRecovery,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${pt.weightKg.toStringAsFixed(1)}kg',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(height: 20),

                              // Capsule bar
                              Container(
                                width: 26,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.statusRecovery
                                      : (isLight
                                          ? const Color(0xFFE9ECEF)
                                          : const Color(0xFF2C2C2E)),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Label
                              Text(
                                pt.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isActive
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                  color: isActive
                                      ? (isLight
                                          ? AppColors.lightTextPrimary
                                          : AppColors.darkTextPrimary)
                                      : (isLight
                                          ? AppColors.lightTextMuted
                                          : AppColors.darkTextMuted),
                                ),
                              ),
                            ],
                          ));
                    }).toList(),
                  )))),
    );
  }
}
