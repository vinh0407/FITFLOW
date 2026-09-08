import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class OneRmCalculatorModal extends StatefulWidget {
  const OneRmCalculatorModal({super.key});

  static void show(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isLight ? AppColors.lightSurface : AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const OneRmCalculatorModal(),
    );
  }

  @override
  State<OneRmCalculatorModal> createState() => _OneRmCalculatorModalState();
}

class _OneRmCalculatorModalState extends State<OneRmCalculatorModal> {
  double weight = 80.0;
  int reps = 5;

  double get calculatedOneRm {
    // Epley Formula: 1RM = Weight * (1 + Reps / 30)
    if (reps <= 1) return weight;
    return weight * (1.0 + (reps / 30.0));
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final oneRm = calculatedOneRm;
    final percentages = [
      {'percent': '95%', 'weight': oneRm * 0.95, 'reps': '2 reps'},
      {'percent': '90%', 'weight': oneRm * 0.90, 'reps': '3-4 reps'},
      {'percent': '85%', 'weight': oneRm * 0.85, 'reps': '5-6 reps'},
      {'percent': '80%', 'weight': oneRm * 0.80, 'reps': '7-8 reps'},
      {'percent': '75%', 'weight': oneRm * 0.75, 'reps': '9-10 reps'},
      {'percent': '70%', 'weight': oneRm * 0.70, 'reps': '11-12 reps'},
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MÁY TÍNH 1RM',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Result Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.primaryBlueGlow,
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1RM ƯỚC TÍNH',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Mức tạ tối đa 1 lần lặp',
                        style: TextStyle(
                          color: Color(0xFFF0F0F0),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${oneRm.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Input Sliders
            Text(
              'TRỌNG LƯỢNG: ${weight.toStringAsFixed(1)} KG',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
            Slider(
              value: weight,
              min: 10,
              max: 250,
              divisions: 240,
              activeColor: AppColors.primaryBlue,
              inactiveColor: AppColors.surfaceHighest,
              onChanged: (val) => setState(() => weight = val),
            ),
            const SizedBox(height: 10),

            Text(
              'SỐ LẦN LẶP (REPS): $reps LẦN',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
            Slider(
              value: reps.toDouble(),
              min: 1,
              max: 15,
              divisions: 14,
              activeColor: AppColors.primaryBlue,
              inactiveColor: AppColors.surfaceHighest,
              onChanged: (val) => setState(() => reps = val.round()),
            ),
            const SizedBox(height: 16),

            // Breakdown Percentages Table
            const Text(
              'BẢNG PHÂN PHỐI TỶ LỆ 1RM',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isLight
                    ? AppColors.lightSurfaceMid
                    : AppColors.darkSurfaceMid,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color:
                        isLight ? AppColors.lightBorder : AppColors.darkBorder),
              ),
              child: Column(
                children: percentages.map((p) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          p['percent'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        Text(
                          '${(p['weight'] as double).toStringAsFixed(1)} kg',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          p['reps'] as String,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
