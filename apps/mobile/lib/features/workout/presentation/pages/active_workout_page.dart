import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitflow_contracts/fitflow_contracts.dart';
import '../../../../core/fitness_data.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';
import 'workout_complete_page.dart';

class ActiveWorkoutPage extends StatefulWidget {
  final String title;
  const ActiveWorkoutPage({super.key, this.title = 'TẬP TỰ DO'});

  @override
  State<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends State<ActiveWorkoutPage> {
  late Timer _timer;
  int _seconds = 0;
  int _totalKcal = 0;
  double _totalVolume = 0;
  int _completedSets = 0;

  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  int _totalRestDuration = 60;

  String query = '';
  String selectedMuscle = 'Tất cả';

  late final List<Map<String, dynamic>> loggedExercises;

  @override
  void initState() {
    super.initState();
    loggedExercises = _recommendedExercises();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
          _totalKcal = (_seconds * 0.12).round();
          _recalculateVolume();
        });
      }
    });
  }

  void _startRestTimer([int duration = 60]) {
    _restTimer?.cancel();
    HapticFeedback.mediumImpact();
    setState(() {
      _totalRestDuration = duration;
      _restSecondsRemaining = duration;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_restSecondsRemaining <= 1) {
        timer.cancel();
        HapticFeedback.heavyImpact();
        setState(() => _restSecondsRemaining = 0);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.surface,
            duration: Duration(seconds: 2),
            content: Text(
              'HẾT GIỜ NGHỈ! BẮT ĐẦU HIỆP TIẾP THEO',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      } else {
        setState(() => _restSecondsRemaining--);
      }
    });
  }

  void _addRestTime(int seconds) {
    setState(() {
      _restSecondsRemaining += seconds;
      _totalRestDuration += seconds;
    });
  }

  void _subtractRestTime(int seconds) {
    setState(() {
      _restSecondsRemaining =
          (_restSecondsRemaining - seconds).clamp(0, _totalRestDuration);
      if (_restSecondsRemaining == 0) {
        _skipRestTimer();
      }
    });
  }

  void _skipRestTimer() {
    _restTimer?.cancel();
    setState(() => _restSecondsRemaining = 0);
  }

  List<Map<String, dynamic>> _recommendedExercises() {
    final profile = fitnessRepository.profile;
    final preferred = profile.focusAreas;
    final matching = fitnessRepository.exercises.where((exercise) {
      final equipment = exercise.equipment.toUpperCase();
      final hasEquipment = profile.equipment.isEmpty ||
          profile.equipment.any((item) =>
              equipment.contains(item) ||
              (item == 'BODYWEIGHT' && equipment.contains('BODY WEIGHT')));
      if (!hasEquipment) return false;
      if (preferred.isEmpty) return true;
      final muscle = exercise.muscle.toUpperCase();
      return preferred.any((area) =>
          muscle.contains(area) ||
          (area == 'CORE' && muscle.contains('ABS')) ||
          (area == 'ARMS' &&
              (muscle.contains('BICEPS') || muscle.contains('TRICEPS'))));
    }).toList();
    final selection =
        (matching.isEmpty ? fitnessRepository.exercises : matching).take(3);
    return selection.map((exercise) {
      final prescription = getExercisePrescription(
        exercise.name,
        exercise.equipment.toLowerCase().contains('cardio')
            ? 'cardio'
            : 'strength',
        profile,
        setsOverride: exercise.targetSets,
      );
      final target = prescription.reps ?? prescription.seconds ?? 10;
      return {
        'name': exercise.name,
        'muscle': exercise.muscle,
        'sets': List.generate(
            prescription.sets,
            (index) => {
                  'set': index + 1,
                  'kg': 0.0,
                  'reps': target,
                  'done': false,
                }),
      };
    }).toList();
  }

  void _recalculateVolume() {
    double vol = 0;
    int sets = 0;
    for (final ex in loggedExercises) {
      for (final s in (ex['sets'] as List)) {
        if (s['done'] == true) {
          vol += (s['kg'] as double) * (s['reps'] as int);
          sets++;
        }
      }
    }
    _totalVolume = vol;
    _completedSets = sets;
  }

  @override
  void dispose() {
    _timer.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final streakCount = _completedSets > 0
        ? (fitnessRepository.currentStreak > 0
            ? fitnessRepository.currentStreak
            : 1)
        : fitnessRepository.currentStreak;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _confirmExitWorkout();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Top Status Bar (Matching Gymwork Ảnh 52)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isLight ? AppColors.lightSurface : AppColors.darkSurface,
                  border: Border(
                    bottom: BorderSide(
                      color: isLight
                          ? AppColors.lightBorder
                          : AppColors.darkBorder,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Semantics(
                          button: true,
                          label:
                              'Exit workout. Elapsed time ${_formatTime(_seconds)}',
                          onTap: _confirmExitWorkout,
                          child: InkWell(
                            onTap: _confirmExitWorkout,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: Row(
                                children: [
                                  const Icon(Icons.keyboard_arrow_down,
                                      color: AppColors.textPrimary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Thời gian tập ${_formatTime(_seconds)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _finishWorkout,
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Xong',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 4 Summary Metrics (Volume, Kcal, Sets, Streak)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHeaderStat(
                            '${_totalVolume.toInt()} kg', 'Khối lượng'),
                        _buildHeaderStat('$_totalKcal kcal', 'Tiêu hao'),
                        _buildHeaderStat('$_completedSets Hiệp', 'Đã xong'),
                        _buildHeaderStat('$streakCount', 'Streak'),
                      ],
                    ),
                  ],
                ),
              ),

              // Exercise List & Add Exercise section
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                  children: [
                    // Section Header: "Thêm bài tập"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Danh sách bài tập',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton(
                          onPressed: _showAddExerciseSheet,
                          tooltip: 'Add an exercise to this workout',
                          icon: const Icon(Icons.add_circle,
                              color: AppColors.primaryBlue, size: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Logged Exercises Cards
                    ...loggedExercises.map((ex) {
                      final setsList = ex['sets'] as List<Map<String, dynamic>>;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isLight
                              ? AppColors.lightSurface
                              : AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isLight
                                ? AppColors.lightBorder
                                : AppColors.darkBorder,
                          ),
                          boxShadow: isLight
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    ex['name'] as String,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: isLight
                                          ? AppColors.lightTextPrimary
                                          : AppColors.darkTextPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlueGlow,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    ex['muscle'] as String,
                                    style: const TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Table Header (Set | Kg | Reps | Check)
                            const Row(
                              children: [
                                SizedBox(
                                    width: 40,
                                    child: Text('HIỆP',
                                        style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700))),
                                Expanded(
                                    child: Text('MỨC TẠ (KG)',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700))),
                                Expanded(
                                    child: Text('SỐ REPS',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700))),
                                SizedBox(
                                    width: 44,
                                    child: Text('XONG',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700))),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Sets Rows
                            ...setsList.asMap().entries.map((sEntry) {
                              final sIndex = sEntry.key;
                              final s = sEntry.value;
                              final isDone = s['done'] as bool;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? AppColors.primaryBlueGlow
                                      : AppColors.surfaceMid,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 32,
                                      child: Text(
                                        '${sIndex + 1}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13),
                                      ),
                                    ),
                                    Expanded(
                                      child: Semantics(
                                        button: true,
                                        label:
                                            'Edit weight for set ${sIndex + 1} of ${ex['name']}: ${s['kg']} kilograms',
                                        onTap: () => _showQuickEditSetModal(
                                            s,
                                            sIndex,
                                            ex['name'] as String,
                                            setsList),
                                        child: InkWell(
                                          onTap: () => _showQuickEditSetModal(
                                              s,
                                              sIndex,
                                              ex['name'] as String,
                                              setsList),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceHighest
                                                  .withValues(alpha: 0.35),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${s['kg']} kg',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 13),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Semantics(
                                        button: true,
                                        label:
                                            'Edit repetitions for set ${sIndex + 1} of ${ex['name']}: ${s['reps']} repetitions',
                                        onTap: () => _showQuickEditSetModal(
                                            s,
                                            sIndex,
                                            ex['name'] as String,
                                            setsList),
                                        child: InkWell(
                                          onTap: () => _showQuickEditSetModal(
                                              s,
                                              sIndex,
                                              ex['name'] as String,
                                              setsList),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceHighest
                                                  .withValues(alpha: 0.35),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${s['reps']} lần',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 13),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    SizedBox(
                                      width: 44,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          isDone
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: isDone
                                              ? AppColors.primaryBlue
                                              : AppColors.textMuted,
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            final nextDone = !isDone;
                                            s['done'] = nextDone;
                                            _recalculateVolume();
                                            if (nextDone) {
                                              _startRestTimer(60);
                                            }
                                          });
                                        },
                                        tooltip: isDone
                                            ? 'Mark set ${sIndex + 1} of ${ex['name']} incomplete'
                                            : 'Mark set ${sIndex + 1} of ${ex['name']} complete',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            const SizedBox(height: 8),
                            // Add Set Button
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  setsList.add({
                                    'set': setsList.length + 1,
                                    'kg': setsList.isNotEmpty
                                        ? setsList.last['kg']
                                        : 20.0,
                                    'reps': 10,
                                    'done': false,
                                  });
                                });
                              },
                              icon: const Icon(Icons.add,
                                  size: 16, color: AppColors.textSecondary),
                              label: const Text(
                                '+ Thêm hiệp',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: const Size.fromHeight(36),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              if (_restSecondsRemaining > 0) _buildRestTimerBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestTimerBar() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final progress = _totalRestDuration > 0
        ? (_restSecondsRemaining / _totalRestDuration).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurfaceMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLight
              ? AppColors.primaryBlue.withValues(alpha: 0.3)
              : AppColors.borderBlue,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.08 : 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'THỜI GIAN NGHỈ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isLight
                          ? AppColors.lightTextSecondary
                          : AppColors.darkTextSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                _formatTime(_restSecondsRemaining),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isLight
                      ? AppColors.primaryBlue
                      : AppColors.primaryBlueLight,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _subtractRestTime(15);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 40,
                      ),
                      decoration: BoxDecoration(
                        color: isLight
                            ? AppColors.lightSurfaceMid
                            : AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLight
                              ? AppColors.lightBorder
                              : AppColors.darkBorder,
                        ),
                      ),
                      child: Text(
                        '-15s',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isLight
                              ? AppColors.lightTextPrimary
                              : AppColors.darkTextPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _addRestTime(15);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 40,
                      ),
                      decoration: BoxDecoration(
                        color: isLight
                            ? AppColors.lightSurfaceMid
                            : AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLight
                              ? AppColors.lightBorder
                              : AppColors.darkBorder,
                        ),
                      ),
                      child: Text(
                        '+15s',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isLight
                              ? AppColors.lightTextPrimary
                              : AppColors.darkTextPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _skipRestTimer();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 40,
                      ),
                      child: Text(
                        'Bỏ qua',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isLight
                              ? AppColors.lightTextMuted
                              : AppColors.darkTextMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor:
                  isLight ? AppColors.lightBorder : AppColors.surfaceHighest,
              color:
                  isLight ? AppColors.primaryBlue : AppColors.primaryBlueLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  void _showAddExerciseSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final filtered = catalogExercises.where((ex) {
            return (selectedMuscle == 'Tất cả' ||
                    ex.muscle.toLowerCase() ==
                        _muscleToKey(selectedMuscle).toLowerCase()) &&
                ex.name.toLowerCase().contains(query.toLowerCase());
          }).toList();

          return SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thêm bài tập',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search input
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Tìm tên bài tập (VD: Squat)',
                    ),
                    onChanged: (val) {
                      setModalState(() => query = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Muscle Chips filter
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        'Tất cả',
                        'Ngực',
                        'Lưng',
                        'Vai',
                        'Chân',
                        'Tay',
                        'Bụng',
                        'Cardio',
                      ].map((m) {
                        final active = selectedMuscle == m;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(m),
                            selected: active,
                            selectedColor: AppColors.primaryBlue,
                            backgroundColor: AppColors.surfaceMid,
                            labelStyle: TextStyle(
                              color: active
                                  ? AppColors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            onSelected: (_) {
                              setModalState(() => selectedMuscle = m);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final ex = filtered[i];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 48,
                              height: 48,
                              color: AppColors.surfaceMid,
                              child: ex.imageUrl.isNotEmpty
                                  ? Image.network(
                                      ex.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.fitness_center,
                                        color: AppColors.primaryBlue,
                                        size: 22,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.fitness_center,
                                      color: AppColors.primaryBlue,
                                      size: 22,
                                    ),
                            ),
                          ),
                          title: Text(
                            ex.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                          subtitle: Text(
                            '${ex.category} · ${ex.equipment}',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: AppColors.primaryBlue),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                loggedExercises.add({
                                  'name': ex.name,
                                  'muscle': ex.muscle,
                                  'sets': [
                                    {
                                      'set': 1,
                                      'kg': double.tryParse(ex.suggestedWeight
                                              .replaceAll(
                                                  RegExp(r'[^0-9.]'), '')) ??
                                          20.0,
                                      'reps': 10,
                                      'done': false
                                    }
                                  ]
                                });
                              });
                              Navigator.pop(ctx);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _muscleToKey(String vietnamese) {
    switch (vietnamese) {
      case 'Ngực':
        return 'CHEST';
      case 'Lưng':
        return 'BACK';
      case 'Vai':
        return 'SHOULDERS';
      case 'Chân':
        return 'LEGS';
      case 'Tay':
        return 'ARMS';
      case 'Bụng':
        return 'CORE';
      case 'Cardio':
        return 'CARDIO';
      default:
        return 'ALL';
    }
  }

  void _finishWorkout() async {
    _timer.cancel();
    _restTimer?.cancel();
    final durationMin = (_seconds / 60).ceil().clamp(1, 999);
    final volumeInt = _totalVolume.toInt();
    final kcalBurned = _totalKcal > 0 ? _totalKcal : (durationMin * 7);

    await fitnessRepository.recordWorkout(
      name: widget.title,
      duration: durationMin,
      exercises: loggedExercises.length,
      kcal: kcalBurned,
      volume: volumeInt,
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutCompletePage(
          workoutTitle: widget.title,
          durationMinutes: durationMin,
          caloriesBurned: kcalBurned,
          totalVolumeKg: volumeInt,
          totalSets: _completedSets,
          exerciseCount: loggedExercises.length,
        ),
      ),
    );
  }

  void _confirmExitWorkout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'HỦY BUỔI TẬP HIỆN TẠI?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: const Text(
          'Dữ liệu và thời gian của buổi tập này sẽ không được lưu lại. Bạn có chắc chắn muốn thoát?',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'TIẾP TỤC TẬP',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _timer.cancel();
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'HỦY & THOÁT',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickEditSetModal(Map<String, dynamic> s, int setIndex,
      String exName, List<Map<String, dynamic>> setsList) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final kg = s['kg'] as double;
          final reps = s['reps'] as int;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'HIỆP ${setIndex + 1} · $exName',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (setsList.length > 1)
                        IconButton(
                          tooltip: 'Xóa hiệp này',
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.error, size: 22),
                          onPressed: () {
                            setState(() {
                              setsList.removeAt(setIndex);
                              for (int i = 0; i < setsList.length; i++) {
                                setsList[i]['set'] = i + 1;
                              }
                              _recalculateVolume();
                            });
                            Navigator.pop(modalCtx);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Weight Steppers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'MỨC TẠ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${kg.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _stepperButton('-5kg', () {
                        setSheetState(
                            () => s['kg'] = (kg - 5.0).clamp(0.0, 500.0));
                        setState(() => _recalculateVolume());
                      }),
                      const SizedBox(width: 8),
                      _stepperButton('-2.5kg', () {
                        setSheetState(
                            () => s['kg'] = (kg - 2.5).clamp(0.0, 500.0));
                        setState(() => _recalculateVolume());
                      }),
                      const SizedBox(width: 8),
                      _stepperButton('+2.5kg', () {
                        setSheetState(
                            () => s['kg'] = (kg + 2.5).clamp(0.0, 500.0));
                        setState(() => _recalculateVolume());
                      }),
                      const SizedBox(width: 8),
                      _stepperButton('+5kg', () {
                        setSheetState(
                            () => s['kg'] = (kg + 5.0).clamp(0.0, 500.0));
                        setState(() => _recalculateVolume());
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Reps Steppers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SỐ LẦN LẶP (REPS)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$reps lần',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _stepperButton('-5', () {
                        setSheetState(
                            () => s['reps'] = (reps - 5).clamp(1, 100));
                        setState(() => _recalculateVolume());
                      }),
                      const SizedBox(width: 8),
                      _stepperButton('-1', () {
                        setSheetState(
                            () => s['reps'] = (reps - 1).clamp(1, 100));
                        setState(() => _recalculateVolume());
                      }),
                      const SizedBox(width: 8),
                      _stepperButton('+1', () {
                        setSheetState(
                            () => s['reps'] = (reps + 1).clamp(1, 100));
                        setState(() => _recalculateVolume());
                      }),
                      const SizedBox(width: 8),
                      _stepperButton('+5', () {
                        setSheetState(
                            () => s['reps'] = (reps + 5).clamp(1, 100));
                        setState(() => _recalculateVolume());
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(modalCtx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'XÁC NHẬN',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _stepperButton(String label, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(42),
          padding: EdgeInsets.zero,
          side: const BorderSide(color: AppColors.border),
          backgroundColor: AppColors.surfaceMid,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
