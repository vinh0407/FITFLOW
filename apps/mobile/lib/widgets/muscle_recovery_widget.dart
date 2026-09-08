import 'package:flutter/material.dart';
import '../core/fitness_data.dart';
import '../core/theme/app_colors.dart';

class MuscleRecoveryWidget extends StatefulWidget {
  final List<MuscleRecoveryInfo> recoveryList;
  final Function(MuscleRecoveryInfo)? onSelectMuscle;

  const MuscleRecoveryWidget({
    super.key,
    required this.recoveryList,
    this.onSelectMuscle,
  });

  @override
  State<MuscleRecoveryWidget> createState() => _MuscleRecoveryWidgetState();
}

class _MuscleRecoveryWidgetState extends State<MuscleRecoveryWidget> {
  bool isFrontView = true;
  String? selectedMuscleName;

  Color _getColorForPercentage(int percent) {
    if (percent >= 85) return AppColors.recoveryHigh;
    if (percent >= 50) return AppColors.recoveryMid;
    return AppColors.recoveryLow;
  }

  @override
  Widget build(BuildContext context) {
    final frontMuscles = [
      {'name': 'Ngực', 'percent': 95, 'days': '3 ngày trước', 'align': 'left'},
      {'name': 'Vai', 'percent': 40, 'days': '1 ngày trước', 'align': 'left'},
      {
        'name': 'Tay trước',
        'percent': 90,
        'days': '3 ngày trước',
        'align': 'left'
      },
      {
        'name': 'Cơ bụng',
        'percent': 100,
        'days': '4 ngày trước',
        'align': 'left'
      },
      {
        'name': 'Đùi trước',
        'percent': 70,
        'days': '2 ngày trước',
        'align': 'left'
      },
      {
        'name': 'Cơ cầu vai trên',
        'percent': 80,
        'days': '2 ngày trước',
        'align': 'right'
      },
      {
        'name': 'Tay sau',
        'percent': 50,
        'days': '1 ngày trước',
        'align': 'right'
      },
      {
        'name': 'Cẳng tay',
        'percent': 90,
        'days': '3 ngày trước',
        'align': 'right'
      },
      {
        'name': 'Lưng dưới',
        'percent': 85,
        'days': '2 ngày trước',
        'align': 'right'
      },
    ];

    return Column(
      children: [
        // Toggle Mặt trước / Mặt sau
        Container(
          height: 38,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.surfaceMid,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildViewTab('Mặt trước', isFrontView, () {
                setState(() => isFrontView = true);
              }),
              _buildViewTab('Mặt sau', !isFrontView, () {
                setState(() => isFrontView = false);
              }),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Interactive Body Anatomy Display
        Stack(
          alignment: Alignment.center,
          children: [
            // Center Anatomical Human Graphic
            CustomPaint(
              size: const Size(200, 310),
              painter: AnatomicalBodyPainter(
                isFront: isFrontView,
                highlightColor: AppColors.recoveryHigh,
                fatigueColor: AppColors.recoveryLow,
              ),
            ),

            // Left & Right Muscle Status Labels
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side muscles
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: frontMuscles
                        .where((m) => m['align'] == 'left')
                        .map((m) => _buildMuscleLabel(
                              m['name'] as String,
                              m['percent'] as int,
                              m['days'] as String,
                              isLeft: true,
                            ))
                        .toList(),
                  ),
                  // Right side muscles
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: frontMuscles
                        .where((m) => m['align'] == 'right')
                        .map((m) => _buildMuscleLabel(
                              m['name'] as String,
                              m['percent'] as int,
                              m['days'] as String,
                              isLeft: false,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewTab(String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.surfaceHighest : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
            color: active ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildMuscleLabel(String name, int percent, String days,
      {required bool isLeft}) {
    final color = _getColorForPercentage(percent);
    final isSelected = selectedMuscleName == name;

    return GestureDetector(
      onTap: () {
        setState(() => selectedMuscleName = name);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlueGlow : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? AppColors.primaryBlue : Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment:
              isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isLeft)
                  Text(
                    '$percent%  ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (isLeft)
                  Text(
                    '  $percent%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
              ],
            ),
            Text(
              days,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnatomicalBodyPainter extends CustomPainter {
  final bool isFront;
  final Color highlightColor;
  final Color fatigueColor;

  AnatomicalBodyPainter({
    required this.isFront,
    required this.highlightColor,
    required this.fatigueColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = const Color(0xFF2C2C2C)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = const Color(0xFF3F3F3F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final recoveredPaint = Paint()
      ..color = highlightColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final fatiguedPaint = Paint()
      ..color = fatigueColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final midPaint = Paint()
      ..color = AppColors.recoveryMid.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;

    // Head
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, 28), width: 34, height: 42),
      basePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, 28), width: 34, height: 42),
      outlinePaint,
    );

    // Neck & Upper Traps
    final neckPath = Path()
      ..moveTo(centerX - 12, 46)
      ..lineTo(centerX + 12, 46)
      ..lineTo(centerX + 26, 68)
      ..lineTo(centerX - 26, 68)
      ..close();
    canvas.drawPath(neckPath, recoveredPaint);
    canvas.drawPath(neckPath, outlinePaint);

    // Chest (Pectorals) - Front view
    if (isFront) {
      // Left Pec
      final leftPec = RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 36, 72, 33, 30),
        const Radius.circular(8),
      );
      canvas.drawRRect(leftPec, recoveredPaint);
      canvas.drawRRect(leftPec, outlinePaint);

      // Right Pec
      final rightPec = RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX + 3, 72, 33, 30),
        const Radius.circular(8),
      );
      canvas.drawRRect(rightPec, recoveredPaint);
      canvas.drawRRect(rightPec, outlinePaint);

      // Abs (6-pack)
      for (int r = 0; r < 3; r++) {
        final leftAb = RRect.fromRectAndRadius(
          Rect.fromLTWH(centerX - 20, 106 + (r * 15.0), 18, 12),
          const Radius.circular(4),
        );
        final rightAb = RRect.fromRectAndRadius(
          Rect.fromLTWH(centerX + 2, 106 + (r * 15.0), 18, 12),
          const Radius.circular(4),
        );
        canvas.drawRRect(leftAb, recoveredPaint);
        canvas.drawRRect(rightAb, recoveredPaint);
        canvas.drawRRect(leftAb, outlinePaint);
        canvas.drawRRect(rightAb, outlinePaint);
      }
    } else {
      // Back - Lats & Traps
      final backPath = Path()
        ..moveTo(centerX - 36, 72)
        ..lineTo(centerX + 36, 72)
        ..lineTo(centerX + 22, 142)
        ..lineTo(centerX - 22, 142)
        ..close();
      canvas.drawPath(backPath, recoveredPaint);
      canvas.drawPath(backPath, outlinePaint);
    }

    // Shoulders (Deltoids) - Fatigued
    final leftShoulder = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - 58, 68, 20, 28),
      const Radius.circular(8),
    );
    final rightShoulder = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX + 38, 68, 20, 28),
      const Radius.circular(8),
    );
    canvas.drawRRect(leftShoulder, fatiguedPaint);
    canvas.drawRRect(rightShoulder, fatiguedPaint);
    canvas.drawRRect(leftShoulder, outlinePaint);
    canvas.drawRRect(rightShoulder, outlinePaint);

    // Biceps / Arms
    final leftArm = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - 66, 98, 18, 38),
      const Radius.circular(8),
    );
    final rightArm = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX + 48, 98, 18, 38),
      const Radius.circular(8),
    );
    canvas.drawRRect(leftArm, recoveredPaint);
    canvas.drawRRect(rightArm, recoveredPaint);
    canvas.drawRRect(leftArm, outlinePaint);
    canvas.drawRRect(rightArm, outlinePaint);

    // Forearms
    final leftForearm = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - 72, 140, 16, 44),
      const Radius.circular(6),
    );
    final rightForearm = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX + 56, 140, 16, 44),
      const Radius.circular(6),
    );
    canvas.drawRRect(leftForearm, recoveredPaint);
    canvas.drawRRect(rightForearm, recoveredPaint);
    canvas.drawRRect(leftForearm, outlinePaint);
    canvas.drawRRect(rightForearm, outlinePaint);

    // Thighs (Quads / Hamstrings)
    final leftThigh = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - 34, 156, 30, 68),
      const Radius.circular(10),
    );
    final rightThigh = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX + 4, 156, 30, 68),
      const Radius.circular(10),
    );
    canvas.drawRRect(leftThigh, midPaint);
    canvas.drawRRect(rightThigh, midPaint);
    canvas.drawRRect(leftThigh, outlinePaint);
    canvas.drawRRect(rightThigh, outlinePaint);

    // Calves
    final leftCalf = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - 30, 230, 24, 60),
      const Radius.circular(8),
    );
    final rightCalf = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX + 6, 230, 24, 60),
      const Radius.circular(8),
    );
    canvas.drawRRect(leftCalf, basePaint);
    canvas.drawRRect(rightCalf, basePaint);
    canvas.drawRRect(leftCalf, outlinePaint);
    canvas.drawRRect(rightCalf, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant AnatomicalBodyPainter oldDelegate) =>
      oldDelegate.isFront != isFront ||
      oldDelegate.highlightColor != highlightColor ||
      oldDelegate.fatigueColor != fatigueColor;
}
