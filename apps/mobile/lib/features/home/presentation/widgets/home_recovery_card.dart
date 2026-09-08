import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/muscle_recovery_model.dart';

class HomeRecoveryCard extends StatelessWidget {
  const HomeRecoveryCard({
    super.key,
    required this.onTap,
    this.report = OverallRecoveryReport.defaultReport,
  });

  final VoidCallback onTap;
  final OverallRecoveryReport report;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final percentage = report.overallPercentage;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlueLight
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(Icons.accessibility_new_rounded,
                              color: AppColors.primaryBlue, size: 18),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                          child: Text(
                        'PHỤC HỒI CƠ BẮP',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: isLight
                              ? AppColors.lightTextPrimary
                              : AppColors.darkTextPrimary,
                        ),
                      )),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusRecovery.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Trạng thái tốt',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.statusRecovery,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // 2. Circular Gauge & Breakdown Overview
            Row(
              children: [
                // Circular Gauge
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CustomPaint(
                    painter: _RecoveryGaugePainter(
                      percentage: percentage / 100.0,
                      isLight: isLight,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                              color: isLight
                                  ? AppColors.lightTextPrimary
                                  : AppColors.darkTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ready',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isLight
                                  ? AppColors.lightTextMuted
                                  : AppColors.darkTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 18),

                // Text Description & Suggestion
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cơ bắp đã hồi phục 78%',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isLight
                              ? AppColors.lightTextPrimary
                              : AppColors.darkTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ngực (85%) & Vai (90%) đã hồi phục hoàn toàn. Chân (60%) cần thêm thời gian.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: isLight
                              ? AppColors.lightTextSecondary
                              : AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
              height: 1,
            ),
            const SizedBox(height: 14),

            // 3. Bottom CTA Link
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Chi tiết 7 nhóm cơ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isLight
                          ? AppColors.lightTextMuted
                          : AppColors.darkTextMuted,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Xem chi tiết',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: isLight
                            ? AppColors.primaryBlue
                            : AppColors.primaryBlueLight,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: isLight
                          ? AppColors.primaryBlue
                          : AppColors.primaryBlueLight,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryGaugePainter extends CustomPainter {
  _RecoveryGaugePainter({
    required this.percentage,
    required this.isLight,
  });

  final double percentage;
  final bool isLight;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;

    final backgroundPaint = Paint()
      ..color = isLight ? const Color(0xFFE9ECEF) : const Color(0xFF2C2C2E)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = AppColors.statusRecovery
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Background full circle
    canvas.drawCircle(center, radius, backgroundPaint);

    // Active progress arc
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RecoveryGaugePainter oldDelegate) =>
      oldDelegate.percentage != percentage || oldDelegate.isLight != isLight;
}
