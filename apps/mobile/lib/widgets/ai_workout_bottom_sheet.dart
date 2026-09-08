import 'package:flutter/material.dart';
import '../core/fitness_data.dart';
import '../core/fitness_repository.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/design_tokens.dart';
import '../features/workout/presentation/pages/active_workout_page.dart';
import '../features/workout/presentation/pages/programs_page.dart';

class AiWorkoutBottomSheet extends StatefulWidget {
  const AiWorkoutBottomSheet({super.key});

  static void show(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isLight ? AppColors.lightSurface : AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AiWorkoutBottomSheet(),
    );
  }

  @override
  State<AiWorkoutBottomSheet> createState() => _AiWorkoutBottomSheetState();
}

class _AiWorkoutBottomSheetState extends State<AiWorkoutBottomSheet> {
  String duration = '30 phút';
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final profile = fitnessRepository.profile;
    final targetMuscles = profile.focusAreas.isEmpty
        ? const ['CHEST', 'BACK', 'LEGS']
        : profile.focusAreas.take(3).toList();
    final sessionCount = fitnessRepository.history.length;
    duration = '${profile.sessionMinutes} phút';
    final height = double.tryParse(profile.heightCm) ?? 0;
    final weight = double.tryParse(profile.weightKg) ?? 0;
    final bmi = height > 0 && weight > 0
        ? weight / ((height / 100) * (height / 100))
        : 0.0;
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Top Bar with Close & Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'Đóng',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                ),
                const Expanded(
                  child: Text(
                    'AI COACH',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  tooltip: 'Đề xuất lại',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Đã cập nhật đề xuất bài tập mới!')),
                    );
                  },
                  icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: _step == 0
                  ? _buildInputStep(profile, bmi)
                  : ListView(
                      children: [
                        // AI Learning Progress Banner
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppColors.aiGradient,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.aiPurpleLight),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.aiPurpleLight, width: 3),
                                ),
                                child: Center(
                                  child: Text(
                                    '$sessionCount',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'AI PHÂN TÍCH CHƯƠNG TRÌNH',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Dựa trên BMI ${bmi.toStringAsFixed(1)}, mục tiêu ${profile.trainingGoal}, ${profile.gender}, ${profile.age} tuổi và lịch ${profile.daysPerWeek} buổi/tuần.',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.insights_rounded,
                                  color: AppColors.primaryBlue),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Text(
                                'Khuyến nghị: ${profile.daysPerWeek} buổi × ${profile.sessionMinutes} phút · ưu tiên ${profile.trainingGoal}. Hoàn thành đủ số hiệp để tăng cơ đều và an toàn.',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    height: 1.35),
                              )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quick Filter Dropdowns
                        Row(
                          children: [
                            _buildPillSelector(duration, Icons.access_time),
                            const SizedBox(width: 8),
                            _buildPillSelector(
                                'Dụng cụ (2)', Icons.fitness_center),
                            const SizedBox(width: 8),
                            _buildPillSelector('Mục tiêu', Icons.flag),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Target Muscles Header
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nhóm cơ mục tiêu',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                color: AppColors.textMuted),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Muscle Badges Row
                        Row(
                          children: targetMuscles.map((muscle) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceHighest,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColors.primaryBlue,
                                            width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.accessibility_new,
                                        color: AppColors.primaryBlue,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      muscle,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      '${profile.trainingLevel} · ${profile.daysPerWeek}D/W',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Summary stats row
                        Text(
                          '${catalogExercises.take(4).length} BÀI · $duration',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Warmup mobility
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.self_improvement,
                                      color: AppColors.primaryBlue),
                                  SizedBox(width: 10),
                                  Text(
                                    'Giãn cơ khởi động',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '3m',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Recommended Exercise Cards
                        ...catalogExercises.take(4).map((ex) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceHighest,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.fitness_center,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ex.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${ex.targetSets} Hiệp · ${ex.suggestedWeight} · ${ex.targetReps} lần',
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.more_vert,
                                    color: AppColors.textMuted),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 6),
                        const Text(
                          'LỊCH TẬP PHỔ BIẾN ĐỂ BẮT ĐẦU',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 10),
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _PopularPlanChip(
                                title: 'PPL · 3 BUỔI',
                                subtitle: 'Push / Pull / Legs'),
                            _PopularPlanChip(
                                title: 'UPPER LOWER · 4',
                                subtitle: 'Thân trên / thân dưới'),
                            _PopularPlanChip(
                                title: '5×5 SỨC MẠNH',
                                subtitle: 'Nền tảng tăng lực'),
                          ],
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProgramsPage()),
                          ),
                          icon: const Icon(Icons.explore_outlined),
                          label: const Text('XEM TẤT CẢ CHƯƠNG TRÌNH'),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 10),
            // Start Workout Button
            ElevatedButton(
              onPressed: () {
                if (_step == 0) {
                  setState(() => _step = 1);
                  return;
                }
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ActiveWorkoutPage(
                      title: 'Bài tập AI · Ngực & Tay sau',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                minimumSize: const Size.fromHeight(52),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on, color: AppColors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _step == 0 ? 'XEM PHÂN TÍCH' : 'BẮT ĐẦU BUỔI TẬP AI',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputStep(dynamic profile, double bmi) {
    final items = <Map<String, String>>[
      {'label': 'BMI HIỆN TẠI', 'value': bmi.toStringAsFixed(1)},
      {'label': 'MỤC TIÊU', 'value': profile.trainingGoal.toString()},
      {'label': 'TẦN SUẤT', 'value': '${profile.daysPerWeek} buổi / tuần'},
      {'label': 'THỜI LƯỢNG', 'value': '${profile.sessionMinutes} phút / buổi'},
      {'label': 'HỒ SƠ', 'value': '${profile.gender} · ${profile.age} tuổi'},
    ];
    return ListView(
      children: [
        const Text('BƯỚC 1 / HỒ SƠ TẬP LUYỆN', style: AppTypography.label),
        const SizedBox(height: 8),
        const Text(
            'Kiểm tra dữ liệu đầu vào trước khi AI tạo lịch tập phù hợp cho bạn.',
            style: AppTypography.body),
        const SizedBox(height: 20),
        ...items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['label']!,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w800)),
                  Flexible(
                      child: Text(item['value']!,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w900))),
                ],
              ),
            )),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryBlueGlow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.tune_rounded, color: AppColors.primaryBlue),
              SizedBox(width: 10),
              Expanded(
                  child: Text(
                      'AI sẽ cân bằng khối lượng, ngày hồi phục và độ khó dựa trên hồ sơ này.',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.35))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPillSelector(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down,
              size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _PopularPlanChip extends StatelessWidget {
  const _PopularPlanChip({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(subtitle,
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      );
}
