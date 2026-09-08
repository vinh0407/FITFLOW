import 'package:flutter/material.dart';
import '../../../../core/fitness_data.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/fitness_ui.dart';
import '../../../../widgets/vince_core_primary_button.dart';
import 'active_workout_page.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  int tab = 0;
  String query = '';
  String muscle = 'ALL';
  String equipmentFilter = 'ALL';
  final selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final filtered = fitnessRepository.exercises.where((exercise) {
      final matchesMuscle = muscle == 'ALL' || exercise.muscle == muscle;
      final matchesEquipment = equipmentFilter == 'ALL' ||
          exercise.equipment.toUpperCase() == equipmentFilter.toUpperCase();
      final matchesQuery =
          exercise.name.toLowerCase().contains(query.toLowerCase()) ||
              exercise.category.toLowerCase().contains(query.toLowerCase()) ||
              exercise.target.toLowerCase().contains(query.toLowerCase());
      return matchesMuscle && matchesEquipment && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: isLight ? AppColors.lightBg : AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'KHO BÀI TẬP',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.playlist_add,
                        color: AppColors.primaryBlue),
                    tooltip: 'Mở trình tạo buổi tập',
                    onPressed: () => setState(() => tab = 1),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(children: _tabs()),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                children: _content(filtered),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _tabs() {
    const labels = ['THƯ VIỆN BÀI TẬP', 'TỰ TẠO BUỔI TẬP'];
    final widgets = <Widget>[];
    for (var i = 0; i < labels.length; i++) {
      widgets.add(
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 1 ? 0 : 8),
            child: Pill(
              labels[i],
              active: tab == i,
              onTap: () => setState(() => tab = i),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _content(List<ExerciseRecord> exercises) {
    if (tab == 0) return _exercises(exercises);
    return _builder(exercises);
  }

  List<Widget> _exercises(List<ExerciseRecord> exercises) {
    final widgets = <Widget>[
      TextField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Tìm kiếm theo tên, nhóm cơ, mục tiêu...',
        ),
        onChanged: (value) => setState(() => query = value),
      ),
      const SizedBox(height: 12),
      // Muscle Category Filter
      SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            {'id': 'ALL', 'label': 'TẤT CẢ'},
            {'id': 'CHEST', 'label': 'NGỰC'},
            {'id': 'BACK', 'label': 'LƯNG & XÔ'},
            {'id': 'SHOULDERS', 'label': 'VAI'},
            {'id': 'LEGS', 'label': 'CHÂN & MÔNG'},
            {'id': 'ARMS', 'label': 'TAY'},
            {'id': 'CORE', 'label': 'BỤNG'},
            {'id': 'CARDIO', 'label': 'CARDIO'},
          ].map((item) {
            final active = muscle == item['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(item['label']!),
                selected: active,
                selectedColor: AppColors.primaryBlue,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  color: active ? AppColors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: active ? AppColors.primaryBlue : AppColors.border,
                  ),
                ),
                onSelected: (_) => setState(() => muscle = item['id']!),
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 8),
      // Equipment Filter
      SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            {'id': 'ALL', 'label': 'Mọi thiết bị'},
            {'id': 'BARBELL', 'label': 'Tạ đòn'},
            {'id': 'DUMBBELL', 'label': 'Tạ đơn'},
            {'id': 'CABLE', 'label': 'Dây cáp'},
            {'id': 'MACHINE', 'label': 'Máy tập'},
            {'id': 'BODYWEIGHT', 'label': 'Bodyweight'},
          ].map((item) {
            final active = equipmentFilter == item['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(item['label']!),
                selected: active,
                selectedColor: AppColors.surfaceHighest,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  color: active ? AppColors.textPrimary : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: active ? AppColors.textSecondary : AppColors.border,
                  ),
                ),
                onSelected: (_) =>
                    setState(() => equipmentFilter = item['id']!),
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 14),
    ];

    if (exercises.isEmpty) {
      widgets.add(const EmptyPanel(
        title: 'KHÔNG TÌM THẤY BÀI TẬP',
        message: 'Hãy thử tìm kiếm với từ khóa khác hoặc chọn lại nhóm cơ.',
      ));
    }

    for (final exercise in exercises) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FitnessCard(
            padding: 12,
            onTap: () => _showExercise(exercise),
            semanticLabel:
                'Mở ${exercise.name}, ${exercise.muscle}, ${exercise.equipment}',
            child: Row(
              children: [
                // Thumbnail container with image or GIF indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 64,
                    height: 64,
                    color: AppColors.surfaceMid,
                    child: exercise.imageUrl.isNotEmpty
                        ? RepaintBoundary(
                            child: Image.network(
                              exercise.imageUrl,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.low,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.fitness_center,
                                  color: AppColors.primaryBlue,
                                  size: 28,
                                ),
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.fitness_center,
                              color: AppColors.primaryBlue,
                              size: 28,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlueGlow,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              exercise.category,
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              exercise.equipment,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        exercise.target.isNotEmpty
                            ? exercise.target
                            : '${exercise.muscle} · ${exercise.difficulty}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _builder(List<ExerciseRecord> exercises) {
    final widgets = <Widget>[
      const Text(
        'TỰ TẠO BUỔI TẬP RIÊNG',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 4),
      const Text(
        'Chọn tối đa 6 bài tập bạn muốn tập luyện hôm nay và bắt đầu ngay.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      const SizedBox(height: 14),
      FitnessCard(
        padding: 14,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ĐÃ CHỌN',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
            Text(
              '${selected.length} / 6 BÀI TẬP',
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
    ];

    for (final exercise in exercises) {
      final isSelected = selected.contains(exercise.name);
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FitnessCard(
            padding: 12,
            onTap: () {
              setState(() {
                if (isSelected) {
                  selected.remove(exercise.name);
                } else if (selected.length < 6) {
                  selected.add(exercise.name);
                }
              });
            },
            semanticLabel:
                '${isSelected ? 'Selected' : 'Not selected'} ${exercise.name}. Double tap to ${isSelected ? 'remove it from' : 'add it to'} your workout.',
            child: Row(
              children: [
                Checkbox(
                  value: isSelected,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (value) {
                    setState(() {
                      if (value == true && selected.length < 6) {
                        selected.add(exercise.name);
                      } else {
                        selected.remove(exercise.name);
                      }
                    });
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${exercise.category} · ${exercise.equipment}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    widgets.add(const SizedBox(height: 14));
    widgets.add(
      VinceCorePrimaryButton(
        text: 'BẮT ĐẦU BUỔI TẬP ĐÃ CHỌN',
        onPressed: selected.isEmpty
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActiveWorkoutPage(
                      title: 'BUỔI TẬP TỰ TẠO (${selected.length} BÀI)',
                    ),
                  ),
                );
              },
      ),
    );
    return widgets;
  }

  void _showExercise(ExerciseRecord exercise) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.88,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              children: [
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
                Expanded(
                  child: ListView(
                    children: [
                      // Large GIF / Image Media Preview Box
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMid,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: exercise.gifUrl.isNotEmpty
                              ? Image.network(
                                  exercise.gifUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      exercise.imageUrl.isNotEmpty
                                          ? Image.network(
                                              exercise.imageUrl,
                                              fit: BoxFit.cover,
                                            )
                                          : const Center(
                                              child: Icon(
                                                Icons.fitness_center,
                                                color: AppColors.primaryBlue,
                                                size: 48,
                                              ),
                                            ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.fitness_center,
                                    color: AppColors.primaryBlue,
                                    size: 48,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Title & Badges
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlueGlow,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        exercise.category,
                                        style: const TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceHighest,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${exercise.equipment} · ${exercise.difficulty}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Target Muscles & Prescriptions
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMid,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Cơ mục tiêu chính',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  exercise.target,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            if (exercise.secondaryMuscles.isNotEmpty) ...[
                              const Divider(
                                  height: 16, color: AppColors.border),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Cơ hỗ trợ phụ',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      exercise.secondaryMuscles.join(', '),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const Divider(height: 16, color: AppColors.border),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text('Số hiệp gợi ý',
                                        style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text('${exercise.targetSets} Hiệp',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('Số lần lặp (Reps)',
                                        style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text(exercise.targetReps,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('Mức tạ đề xuất',
                                        style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text(exercise.suggestedWeight,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Step-by-step instructions
                      const Text(
                        'HƯỚNG DẪN KỸ THUẬT CHUẨN',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...exercise.instructions.asMap().entries.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    margin: const EdgeInsets.only(
                                        top: 2, right: 10),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryBlueGlow,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${item.key + 1}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      item.value,
                                      style: const TextStyle(
                                        height: 1.45,
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ActiveWorkoutPage(
                          title: exercise.name,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow,
                      color: AppColors.white, size: 20),
                  label: const Text(
                    'BẮT ĐẦU TẬP BÀI NÀY NGAY',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
