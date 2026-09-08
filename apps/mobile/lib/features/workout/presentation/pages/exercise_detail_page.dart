import 'package:flutter/material.dart';
import '../../../../core/fitness_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/fitness_ui.dart';
import 'active_workout_page.dart';

class ExerciseDetailPage extends StatelessWidget {
  const ExerciseDetailPage({super.key, required this.exercise});

  final ExerciseRecord exercise;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryAccent =
        isLight ? AppColors.primaryBlue : AppColors.primaryBlueLight;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: isLight
                          ? AppColors.lightSurfaceMid
                          : AppColors.darkSurfaceMid,
                    ),
                  ),
                  Text(
                    'Chi tiết bài tập',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã lưu bài tập vào mục yêu thích!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bookmark_border_rounded, size: 22),
                    style: IconButton.styleFrom(
                      backgroundColor: isLight
                          ? AppColors.lightSurfaceMid
                          : AppColors.darkSurfaceMid,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                children: [
                  // 1. Hero Image / Demonstration Container
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: isLight
                          ? AppColors.lightSurfaceMid
                          : AppColors.darkSurfaceMid,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isLight
                            ? AppColors.lightBorder
                            : AppColors.darkBorder,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              exercise.imageUrl.isNotEmpty
                                  ? exercise.imageUrl
                                  : 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.fitness_center_rounded,
                                  size: 64,
                                  color: isLight
                                      ? AppColors.lightTextMuted
                                      : AppColors.darkTextMuted,
                                ),
                              ),
                            ),
                          ),
                          // Subtle gradient shadow at bottom
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 80,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.7),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
                          // Badge: Level & Category
                          Positioned(
                            bottom: 12,
                            left: 14,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: primaryAccent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    exercise.difficulty.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    exercise.category,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Exercise Title & Main Target
                  Text(
                    exercise.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.adjust_rounded,
                          size: 16, color: primaryAccent),
                      const SizedBox(width: 6),
                      Text(
                        'Nhóm cơ chính: ${exercise.muscle}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isLight
                              ? AppColors.lightTextSecondary
                              : AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 3. Metric Strip (Target Sets, Reps, Equipment, Weight)
                  Row(
                    children: [
                      _metricBadge(
                        'Mục tiêu',
                        '${exercise.targetSets} Hiệp',
                        Icons.repeat_rounded,
                        isLight,
                      ),
                      const SizedBox(width: 8),
                      _metricBadge(
                        'Lần tập',
                        exercise.targetReps,
                        Icons.numbers_rounded,
                        isLight,
                      ),
                      const SizedBox(width: 8),
                      _metricBadge(
                        'Dụng cụ',
                        exercise.equipment,
                        Icons.handyman_rounded,
                        isLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. Step-by-Step Instructions
                  Text(
                    'Hướng dẫn kỹ thuật chuẩn',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...exercise.instructions.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FitnessCard(
                        padding: 14,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: primaryAccent.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$index',
                                  style: TextStyle(
                                    color: primaryAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                step,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                  color: isLight
                                      ? AppColors.lightTextPrimary
                                      : AppColors.darkTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 14),

                  // 5. Pro Tips & Safety Notes
                  FitnessCard(
                    padding: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_outline_rounded,
                                color: AppColors.amberYellow, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Lưu ý an toàn & Mẹo tăng hiệu quả',
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
                        const SizedBox(height: 8),
                        Text(
                          '• Giữ vững nhịp thở: Hít vào khi hạ tạ có kiểm soát, thở mạnh ra khi phát lực đẩy lên.\n'
                          '• Tuyệt đối không khóa khớp gối hoặc khớp khuỷu tay ở điểm cuối của biên độ.\n'
                          '• Kích hoạt cơ lõi (Core) trong suốt bài tập để bảo vệ cột sống thắt lưng.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
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
            ),

            // Bottom Floating CTA Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
                border: Border(
                  top: BorderSide(
                    color:
                        isLight ? AppColors.lightBorder : AppColors.darkBorder,
                  ),
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActiveWorkoutPage(
                        title: exercise.name.toUpperCase(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                label: const Text('BẮT ĐẦU BÀI TẬP NÀY'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAccent,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricBadge(String label, String value, IconData icon, bool isLight) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightSurfaceMid : AppColors.darkSurfaceMid,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color:
                  isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isLight
                    ? AppColors.lightTextPrimary
                    : AppColors.darkTextPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isLight
                    ? AppColors.lightTextMuted
                    : AppColors.darkTextMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
