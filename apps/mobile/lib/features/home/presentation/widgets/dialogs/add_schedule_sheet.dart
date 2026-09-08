import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/fitness_repository.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/models/workout_schedule_model.dart';

class AddScheduleSheet extends StatefulWidget {
  const AddScheduleSheet({super.key});

  @override
  State<AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<AddScheduleSheet> {
  final _nameController = TextEditingController();
  final _exerciseController = TextEditingController();

  final List<int> _selectedDays = [1]; // Monday default
  final Set<String> _selectedMuscles = {'Ngực', 'Vai', 'Tay sau'};
  final List<String> _exercises = [
    'Chest Press',
    'Incline Dumbbell Press',
    'Dumbbell Lateral Raise',
  ];
  int _estimatedMinutes = 60;
  String? _errorText;
  bool _saving = false;

  static const _allMuscles = [
    'Ngực',
    'Lưng',
    'Vai',
    'Tay trước',
    'Tay sau',
    'Đùi trước',
    'Đùi sau',
    'Bắp chân',
    'Cơ bụng'
  ];

  static const _daysOfWeek = [
    {'day': 1, 'label': 'T2'},
    {'day': 2, 'label': 'T3'},
    {'day': 3, 'label': 'T4'},
    {'day': 4, 'label': 'T5'},
    {'day': 5, 'label': 'T6'},
    {'day': 6, 'label': 'T7'},
    {'day': 7, 'label': 'CN'},
  ];

  static const _durationOptions = [30, 45, 60, 75, 90];

  @override
  void dispose() {
    _nameController.dispose();
    _exerciseController.dispose();
    super.dispose();
  }

  void _addExercise() {
    final text = _exerciseController.text.trim();
    if (text.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _exercises.add(text);
        _exerciseController.clear();
      });
    }
  }

  void _removeExercise(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<void> _saveSchedule() async {
    if (_saving) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Vui lòng nhập tên lịch tập');
      return;
    }
    if (_selectedDays.isEmpty) {
      setState(() => _errorText = 'Vui lòng chọn ít nhất 1 ngày tập');
      return;
    }
    if (_exercises.isEmpty) {
      setState(() => _errorText = 'Vui lòng thêm ít nhất 1 bài tập');
      return;
    }

    final newSchedule = WorkoutScheduleModel(
      id: 'sch_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      daysOfWeek: _selectedDays,
      muscleGroups: _selectedMuscles.toList(),
      exercises: _exercises,
      estimatedDurationMinutes: _estimatedMinutes,
    );

    setState(() {
      _saving = true;
      _errorText = null;
    });
    try {
      await fitnessRepository.addSchedule(newSchedule);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _errorText = 'Chưa lưu được lịch tập. Vui lòng thử lại.';
        });
      }
      return;
    }
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm lịch tập "$name" thành công! 🎉'),
        backgroundColor: const Color(0xFF151515),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
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
                'THÊM LỊCH TẬP MỚI',
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

          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _errorText!,
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
                // 1. Name Input
                Text(
                  'TÊN LỊCH TẬP',
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
                    hintText: 'VD: PUSH DAY, LEG DAY, HYPERTROPHY...',
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
                    enabledBorder: OutlineInputBorder(
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

                // 2. Day Selector
                Text(
                  'NGÀY TRONG TUẦN',
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
                  spacing: 8,
                  runSpacing: 8,
                  children: _daysOfWeek.map((d) {
                    final dayNum = d['day'] as int;
                    final label = d['label'] as String;
                    final isSelected = _selectedDays.contains(dayNum);

                    return InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          if (isSelected) {
                            _selectedDays.remove(dayNum);
                          } else {
                            _selectedDays.add(dayNum);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        constraints:
                            const BoxConstraints(minWidth: 48, minHeight: 48),
                        padding: const EdgeInsets.all(8),
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
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
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

                const SizedBox(height: 18),

                // 3. Muscle Groups
                Text(
                  'NHÓM CƠ MỤC TIÊU',
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
                  children: _allMuscles.map((muscle) {
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

                // 4. Exercises List
                Text(
                  'DANH SÁCH BÀI TẬP (${_exercises.length})',
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _exerciseController,
                        onSubmitted: (_) => _addExercise(),
                        decoration: InputDecoration(
                          hintText: 'Nhập tên bài tập...',
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
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      child: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._exercises.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final name = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isLight
                          ? const Color(0xFFF8F9FA)
                          : const Color(0xFF242426),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isLight
                            ? AppColors.lightBorder
                            : AppColors.darkBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${idx + 1}. $name',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isLight
                                ? AppColors.lightTextPrimary
                                : AppColors.darkTextPrimary,
                          ),
                        ),
                        InkWell(
                          onTap: () => _removeExercise(idx),
                          child: const Icon(
                            Icons.remove_circle_outline_rounded,
                            size: 18,
                            color: AppColors.primaryBlueLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 18),

                // 5. Estimated Duration
                Text(
                  'THỜI GIAN DỰ KIẾN',
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
                  spacing: 8,
                  runSpacing: 8,
                  children: _durationOptions.map((duration) {
                    final isSelected = _estimatedMinutes == duration;
                    return InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _estimatedMinutes = duration);
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
                          '$duration p',
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
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _saveSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'LƯU LỊCH TẬP',
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
