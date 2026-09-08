import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/fitness_repository.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/models/workout_goal_model.dart';

class CreateGoalSheet extends StatefulWidget {
  const CreateGoalSheet({super.key});

  @override
  State<CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<CreateGoalSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final Set<String> _selectedMuscles = {'Ngực', 'Tay sau'};
  int _targetExercises = 12;
  String? _error;
  bool _saving = false;

  static const _muscles = [
    'Ngực',
    'Lưng',
    'Vai',
    'Tay trước',
    'Tay sau',
    'Đùi trước',
    'Đùi sau',
    'Cơ mông',
    'Bắp chân',
    'Cơ bụng'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Vui lòng nhập tên mục tiêu');
      return;
    }
    if (_selectedMuscles.isEmpty) {
      setState(() => _error = 'Vui lòng chọn ít nhất 1 nhóm cơ');
      return;
    }

    final newGoal = WorkoutGoal(
      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : 'Mục tiêu tập luyện phát triển cơ bắp',
      muscleGroups: _selectedMuscles.toList(),
      exerciseCount: _targetExercises,
      completedExercises: 0,
      totalExercises: _targetExercises,
      progressPercentage: 0.0,
      iconEmoji: 'goal',
      cardColor: AppColors.statusRecovery,
    );

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await fitnessRepository.addWorkoutGoal(newGoal);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Chưa lưu được mục tiêu. Vui lòng thử lại.';
        });
      }
      return;
    }
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã tạo mục tiêu "$name" thành công!'),
        backgroundColor: const Color(0xFF151515),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
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
              Expanded(
                  child: Text(
                'TẠO MỤC TIÊU MỚI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isLight
                      ? AppColors.lightTextPrimary
                      : AppColors.darkTextPrimary,
                ),
              )),
              IconButton(
                tooltip: 'Đóng',
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

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

          Expanded(
            child: ListView(
              children: [
                // Name
                Text(
                  'TÊN MỤC TIÊU',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isLight
                        ? AppColors.lightTextMuted
                        : AppColors.darkTextMuted,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'VD: Chest Hypertrophy, Six Pack Abs...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isLight
                          ? AppColors.lightTextMuted
                          : AppColors.darkTextMuted,
                    ),
                    filled: true,
                    fillColor: isLight
                        ? const Color(0xFFF8F9FA)
                        : const Color(0xFF242426),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isLight
                            ? AppColors.lightBorder
                            : AppColors.darkBorder,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Description
                Text(
                  'MÔ TẢ NGẮN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isLight
                        ? AppColors.lightTextMuted
                        : AppColors.darkTextMuted,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descController,
                  decoration: InputDecoration(
                    hintText: 'Mục tiêu xây dựng cơ ngực dày và cắt nét...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isLight
                          ? AppColors.lightTextMuted
                          : AppColors.darkTextMuted,
                    ),
                    filled: true,
                    fillColor: isLight
                        ? const Color(0xFFF8F9FA)
                        : const Color(0xFF242426),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isLight
                            ? AppColors.lightBorder
                            : AppColors.darkBorder,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Muscle groups
                Text(
                  'NHÓM CƠ TRỌNG TÂM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isLight
                        ? AppColors.lightTextMuted
                        : AppColors.darkTextMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _muscles.map((muscle) {
                    final isSelected = _selectedMuscles.contains(muscle);
                    return FilterChip(
                      label: Text(muscle),
                      selected: isSelected,
                      selectedColor:
                          AppColors.statusRecovery.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.statusRecovery,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? AppColors.statusRecovery
                            : (isLight
                                ? AppColors.lightTextSecondary
                                : AppColors.darkTextSecondary),
                      ),
                      onSelected: (selected) {
                        HapticFeedback.lightImpact();
                        setState(() {
                          if (selected) {
                            _selectedMuscles.add(muscle);
                          } else {
                            _selectedMuscles.remove(muscle);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                // Target exercises count
                Text(
                  'SỐ LƯỢNG BÀI TẬP MỤC TIÊU',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isLight
                        ? AppColors.lightTextMuted
                        : AppColors.darkTextMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  runSpacing: 8,
                  children: [10, 12, 15, 18, 20].map((cnt) {
                    final isSelected = _targetExercises == cnt;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _targetExercises = cnt);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : (isLight
                                    ? const Color(0xFFF8F9FA)
                                    : const Color(0xFF242426)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : (isLight
                                      ? AppColors.lightBorder
                                      : AppColors.darkBorder),
                            ),
                          ),
                          child: Text(
                            '$cnt bài',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : (isLight
                                      ? AppColors.lightTextPrimary
                                      : AppColors.darkTextPrimary),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'LƯU MỤC TIÊU',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
