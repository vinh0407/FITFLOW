import 'package:flutter/material.dart';
import '../../../../core/fitness_data.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/fitness_ui.dart';
import 'active_workout_page.dart';

class WorkoutBuilderPage extends StatefulWidget {
  const WorkoutBuilderPage({super.key});

  @override
  State<WorkoutBuilderPage> createState() => _WorkoutBuilderPageState();
}

class _WorkoutBuilderPageState extends State<WorkoutBuilderPage> {
  final _titleController = TextEditingController(text: 'TẬP TỰ CHỌN (CUSTOM)');
  late List<Map<String, dynamic>> _selectedExercises;

  @override
  void initState() {
    super.initState();
    // Default with first 3 catalog exercises
    _selectedExercises = fitnessRepository.exercises.take(3).map((e) {
      return {
        'exercise': e,
        'sets': e.targetSets,
        'reps': e.targetReps,
        'weight': e.suggestedWeight,
      };
    }).toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showAddExerciseDialog() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? AppColors.lightSurface
          : AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        isLight ? AppColors.lightBorder : AppColors.darkBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'THÊM BÀI TẬP VÀO GIÁO ÁN',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isLight
                              ? AppColors.lightTextPrimary
                              : AppColors.darkTextPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: fitnessRepository.exercises.length,
                    itemBuilder: (c, i) {
                      final item = fitnessRepository.exercises[i];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isLight
                                ? AppColors.lightSurfaceMid
                                : AppColors.darkSurfaceMid,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            size: 20,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          '${item.muscle} · ${item.equipment}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: AppColors.primaryBlue),
                          onPressed: () {
                            setState(() {
                              _selectedExercises.add({
                                'exercise': item,
                                'sets': item.targetSets,
                                'reps': item.targetReps,
                                'weight': item.suggestedWeight,
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryAccent =
        isLight ? AppColors.primaryBlue : AppColors.primaryBlueLight;
    final estimatedMinutes = _selectedExercises.length * 8 + 5;

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
                    'Tự tạo giáo án',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: _showAddExerciseDialog,
                    icon: const Icon(Icons.add, size: 24),
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
                  // Title Input Card
                  FitnessCard(
                    padding: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TÊN GIÁO ÁN / BUỔI TẬP',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isLight
                                ? AppColors.lightTextMuted
                                : AppColors.darkTextMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleController,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _chip('${_selectedExercises.length} bài tập',
                                Icons.list_alt_rounded, isLight),
                            const SizedBox(width: 8),
                            _chip('~$estimatedMinutes phút',
                                Icons.timer_outlined, isLight),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section Header: Exercises
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DANH SÁCH BÀI TẬP (${_selectedExercises.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isLight
                              ? AppColors.lightTextPrimary
                              : AppColors.darkTextPrimary,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showAddExerciseDialog,
                        icon: const Icon(Icons.add,
                            size: 16, color: AppColors.primaryBlue),
                        label: const Text(
                          'THÊM BÀI',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Selected Exercise Items
                  if (_selectedExercises.isEmpty)
                    const EmptyPanel(
                      title: 'CHƯA CÓ BÀI TẬP',
                      message:
                          'Nhấn "Thêm bài" để bổ sung bài tập vào giáo án của bạn.',
                    )
                  else
                    ..._selectedExercises.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final ex = item['exercise'] as ExerciseRecord;
                      final sets = item['sets'] as int;
                      final reps = item['reps'] as String;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
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
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: primaryAccent.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: primaryAccent,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: isLight
                                          ? AppColors.lightTextPrimary
                                          : AppColors.darkTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${ex.muscle} · $sets Hiệp · $reps',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isLight
                                          ? AppColors.lightTextSecondary
                                          : AppColors.darkTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Xóa bài tập',
                              icon: const Icon(Icons.remove_circle_outline,
                                  size: 20, color: AppColors.error),
                              onPressed: () {
                                setState(() {
                                  _selectedExercises.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

            // Bottom CTA Bar
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
                onPressed: _selectedExercises.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ActiveWorkoutPage(
                              title: _titleController.text.trim().isNotEmpty
                                  ? _titleController.text.trim()
                                  : 'BUỔI TẬP TỰ TẠO',
                            ),
                          ),
                        );
                      },
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                label: const Text('BẮT ĐẦU BUỔI TẬP NÀY'),
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

  Widget _chip(String label, IconData icon, bool isLight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurfaceMid : AppColors.darkSurfaceMid,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
