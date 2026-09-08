import '../models/discover_program_model.dart';
import '../../../../core/theme/app_colors.dart';

class AiProgramRequest {
  const AiProgramRequest({
    required this.goal,
    required this.experienceLevel,
    required this.frequencyDays,
    required this.durationMinutes,
    required this.equipment,
    this.targetMuscles = const [],
    this.age = 25,
    this.gender = 'Nam',
    this.currentWeight = 75.0,
    this.limitations = '',
  });

  final String goal;
  final String experienceLevel;
  final int frequencyDays;
  final int durationMinutes;
  final String equipment;
  final List<String> targetMuscles;
  final int age;
  final String gender;
  final double currentWeight;
  final String limitations;
}

abstract class AiProgramService {
  Future<DiscoverProgram> generateProgram(AiProgramRequest request);
}

class DefaultAiProgramService implements AiProgramService {
  const DefaultAiProgramService();

  @override
  Future<DiscoverProgram> generateProgram(AiProgramRequest request) async {
    // Simulating intelligent AI generation delay
    await Future.delayed(const Duration(milliseconds: 600));

    final freq = request.frequencyDays;
    final goal = request.goal;
    final isHome = request.equipment == 'Dumbbells Only' ||
        request.equipment == 'Bodyweight';

    final days = <ProgramWeeklyDay>[];

    if (freq == 3) {
      // 3-day Full Body / Classic split
      days.addAll([
        ProgramWeeklyDay(
          dayOfWeek: 1,
          dayName: 'Thứ 2',
          workoutName: 'Full Body A · Phát lực & Sức mạnh',
          isRestDay: false,
          muscleGroups: ['Ngực', 'Lưng', 'Đùi trước'],
          estimatedMinutes: request.durationMinutes,
          exercises: isHome
              ? const [
                  ProgramWeeklyExercise(
                      name: 'Dumbbell Floor Press',
                      sets: 4,
                      reps: '10-12',
                      restSeconds: 90,
                      muscle: 'Ngực'),
                  ProgramWeeklyExercise(
                      name: 'Dumbbell Goblet Squat',
                      sets: 4,
                      reps: '12-15',
                      restSeconds: 90,
                      muscle: 'Đùi trước'),
                  ProgramWeeklyExercise(
                      name: 'Dumbbell Row',
                      sets: 4,
                      reps: '10-12',
                      restSeconds: 90,
                      muscle: 'Lưng'),
                  ProgramWeeklyExercise(
                      name: 'Plank',
                      sets: 3,
                      reps: '45s',
                      restSeconds: 60,
                      muscle: 'Bụng'),
                ]
              : const [
                  ProgramWeeklyExercise(
                      name: 'Barbell Bench Press',
                      sets: 4,
                      reps: '6-8',
                      restSeconds: 120,
                      muscle: 'Ngực'),
                  ProgramWeeklyExercise(
                      name: 'Barbell Back Squat',
                      sets: 4,
                      reps: '6-8',
                      restSeconds: 120,
                      muscle: 'Đùi trước'),
                  ProgramWeeklyExercise(
                      name: 'Lat Pulldown',
                      sets: 4,
                      reps: '10-12',
                      restSeconds: 90,
                      muscle: 'Lưng'),
                  ProgramWeeklyExercise(
                      name: 'Overhead Press',
                      sets: 3,
                      reps: '8-10',
                      restSeconds: 90,
                      muscle: 'Vai'),
                ],
        ),
        const ProgramWeeklyDay(
          dayOfWeek: 2,
          dayName: 'Thứ 3',
          workoutName: 'Nghỉ ngơi tích cực & Phục hồi cơ',
          isRestDay: true,
        ),
        ProgramWeeklyDay(
          dayOfWeek: 3,
          dayName: 'Thứ 4',
          workoutName: 'Full Body B · Thể tích & Phì đại',
          isRestDay: false,
          muscleGroups: ['Lưng', 'Đùi sau & Mông', 'Vai & Tay'],
          estimatedMinutes: request.durationMinutes,
          exercises: const [
            ProgramWeeklyExercise(
                name: 'Romanian Deadlift',
                sets: 4,
                reps: '8-10',
                restSeconds: 120,
                muscle: 'Đùi sau'),
            ProgramWeeklyExercise(
                name: 'Incline Dumbbell Press',
                sets: 4,
                reps: '10-12',
                restSeconds: 90,
                muscle: 'Ngực'),
            ProgramWeeklyExercise(
                name: 'Seated Cable Row',
                sets: 4,
                reps: '12',
                restSeconds: 90,
                muscle: 'Lưng'),
            ProgramWeeklyExercise(
                name: 'Dumbbell Lateral Raise',
                sets: 4,
                reps: '15',
                restSeconds: 60,
                muscle: 'Vai'),
          ],
        ),
        const ProgramWeeklyDay(
          dayOfWeek: 4,
          dayName: 'Thứ 5',
          workoutName: 'Nghỉ ngơi & Nạp Glycogen',
          isRestDay: true,
        ),
        ProgramWeeklyDay(
          dayOfWeek: 5,
          dayName: 'Thứ 6',
          workoutName: 'Full Body C · Sức bền & Cắt nét',
          isRestDay: false,
          muscleGroups: ['Chân', 'Ngực', 'Tay & Bụng'],
          estimatedMinutes: request.durationMinutes,
          exercises: const [
            ProgramWeeklyExercise(
                name: 'Leg Press 45°',
                sets: 4,
                reps: '12-15',
                restSeconds: 90,
                muscle: 'Đùi trước'),
            ProgramWeeklyExercise(
                name: 'Chest Dips',
                sets: 3,
                reps: '10-12',
                restSeconds: 90,
                muscle: 'Ngực dưới'),
            ProgramWeeklyExercise(
                name: 'Barbell Bicep Curl',
                sets: 3,
                reps: '12',
                restSeconds: 60,
                muscle: 'Tay trước'),
            ProgramWeeklyExercise(
                name: 'Hanging Leg Raise',
                sets: 3,
                reps: '15',
                restSeconds: 60,
                muscle: 'Bụng'),
          ],
        ),
        const ProgramWeeklyDay(
          dayOfWeek: 6,
          dayName: 'Thứ 7',
          workoutName: 'Cardio Zone 2 & Mobility',
          isRestDay: true,
        ),
        const ProgramWeeklyDay(
          dayOfWeek: 7,
          dayName: 'Chủ Nhật',
          workoutName: 'Nghỉ ngơi hoàn toàn',
          isRestDay: true,
        ),
      ]);
    } else if (freq == 4) {
      // 4-day Upper / Lower split
      days.addAll([
        ProgramWeeklyDay(
          dayOfWeek: 1,
          dayName: 'Thứ 2',
          workoutName: 'Upper Body A · Ngực, Lưng, Vai',
          isRestDay: false,
          muscleGroups: ['Ngực', 'Lưng', 'Vai'],
          estimatedMinutes: request.durationMinutes,
          exercises: const [
            ProgramWeeklyExercise(
                name: 'Barbell Bench Press',
                sets: 4,
                reps: '6-8',
                restSeconds: 120,
                muscle: 'Ngực'),
            ProgramWeeklyExercise(
                name: 'Barbell Bent-Over Row',
                sets: 4,
                reps: '8-10',
                restSeconds: 90,
                muscle: 'Lưng'),
            ProgramWeeklyExercise(
                name: 'Overhead Press',
                sets: 3,
                reps: '8-10',
                restSeconds: 90,
                muscle: 'Vai'),
            ProgramWeeklyExercise(
                name: 'Tricep Rope Pushdown',
                sets: 3,
                reps: '12-15',
                restSeconds: 60,
                muscle: 'Tay sau'),
          ],
        ),
        ProgramWeeklyDay(
          dayOfWeek: 2,
          dayName: 'Thứ 3',
          workoutName: 'Lower Body A · Đùi trước, Mông, Bắp chân',
          isRestDay: false,
          muscleGroups: ['Đùi trước', 'Cơ mông', 'Bắp chân'],
          estimatedMinutes: request.durationMinutes,
          exercises: const [
            ProgramWeeklyExercise(
                name: 'Barbell Back Squat',
                sets: 4,
                reps: '6-8',
                restSeconds: 120,
                muscle: 'Đùi trước'),
            ProgramWeeklyExercise(
                name: 'Leg Press 45°',
                sets: 4,
                reps: '10-12',
                restSeconds: 90,
                muscle: 'Đùi trước'),
            ProgramWeeklyExercise(
                name: 'Romanian Deadlift',
                sets: 3,
                reps: '10',
                restSeconds: 90,
                muscle: 'Đùi sau'),
            ProgramWeeklyExercise(
                name: 'Standing Calf Raise',
                sets: 4,
                reps: '15',
                restSeconds: 60,
                muscle: 'Bắp chân'),
          ],
        ),
        const ProgramWeeklyDay(
          dayOfWeek: 3,
          dayName: 'Thứ 4',
          workoutName: 'Nghỉ ngơi hồi phục',
          isRestDay: true,
        ),
        ProgramWeeklyDay(
          dayOfWeek: 4,
          dayName: 'Thứ 5',
          workoutName: 'Upper Body B · Thể tích ngực & tay',
          isRestDay: false,
          muscleGroups: ['Ngực trên', 'Cơ xô', 'Tay & Bụng'],
          estimatedMinutes: request.durationMinutes,
          exercises: const [
            ProgramWeeklyExercise(
                name: 'Incline Dumbbell Press',
                sets: 4,
                reps: '10-12',
                restSeconds: 90,
                muscle: 'Ngực trên'),
            ProgramWeeklyExercise(
                name: 'Lat Pulldown',
                sets: 4,
                reps: '10-12',
                restSeconds: 90,
                muscle: 'Lưng'),
            ProgramWeeklyExercise(
                name: 'Dumbbell Lateral Raise',
                sets: 4,
                reps: '15',
                restSeconds: 60,
                muscle: 'Vai'),
            ProgramWeeklyExercise(
                name: 'Barbell Bicep Curl',
                sets: 3,
                reps: '12',
                restSeconds: 60,
                muscle: 'Tay trước'),
          ],
        ),
        ProgramWeeklyDay(
          dayOfWeek: 5,
          dayName: 'Thứ 6',
          workoutName: 'Lower Body B · Đùi sau, Mông & Core',
          isRestDay: false,
          muscleGroups: ['Đùi sau', 'Mông', 'Cơ bụng'],
          estimatedMinutes: request.durationMinutes,
          exercises: const [
            ProgramWeeklyExercise(
                name: 'Deadlift',
                sets: 4,
                reps: '5',
                restSeconds: 180,
                muscle: 'Toàn thân'),
            ProgramWeeklyExercise(
                name: 'Hip Thrust',
                sets: 4,
                reps: '10-12',
                restSeconds: 90,
                muscle: 'Mông'),
            ProgramWeeklyExercise(
                name: 'Bulgarian Split Squat',
                sets: 3,
                reps: '10 mỗi chân',
                restSeconds: 90,
                muscle: 'Đùi'),
            ProgramWeeklyExercise(
                name: 'Hanging Leg Raise',
                sets: 3,
                reps: '15',
                restSeconds: 60,
                muscle: 'Bụng'),
          ],
        ),
        const ProgramWeeklyDay(
          dayOfWeek: 6,
          dayName: 'Thứ 7',
          workoutName: 'Nghỉ ngơi tích cực',
          isRestDay: true,
        ),
        const ProgramWeeklyDay(
          dayOfWeek: 7,
          dayName: 'Chủ Nhật',
          workoutName: 'Nghỉ ngơi hoàn toàn',
          isRestDay: true,
        ),
      ]);
    } else {
      // 5-6 day PPL Split
      days.addAll([
        ProgramWeeklyDay(
          dayOfWeek: 1,
          dayName: 'Thứ 2',
          workoutName: 'PUSH A · Ngực, Vai trước, Tay sau',
          isRestDay: false,
          muscleGroups: ['Ngực', 'Vai', 'Tay sau'],
          estimatedMinutes: request.durationMinutes,
          exercises: const [
            ProgramWeeklyExercise(
                name: 'Barbell Bench Press',
                sets: 4,
                reps: '6-8',
                restSeconds: 120,
                muscle: 'Ngực'),
            ProgramWeeklyExercise(
                name: 'Incline Dumbbell Press',
                sets: 3,
                reps: '10-12',
                restSeconds: 90,
                muscle: 'Ngực trên'),
            ProgramWeeklyExercise(
                name: 'Overhead Press',
                sets: 3,
                reps: '8-10',
                restSeconds: 90,
                muscle: 'Vai'),
            ProgramWeeklyExercise(
                name: 'Tricep Rope Pushdown',
                sets: 3,
                reps: '12-15',
                restSeconds: 60,
                muscle: 'Tay sau'),
          ],
        ),
        ProgramWeeklyDay(
          dayOfWeek: 2,
          dayName: 'Thứ 3',
          workoutName: 'PULL A · Lưng xô, Vai sau, Tay trước',
          isRestDay: false,
          muscleGroups: ['Lưng', 'Vai sau', 'Tay trước'],
          estimatedMinutes: request.durationMinutes,
          exercises: const [
            ProgramWeeklyExercise(
                name: 'Conventional Deadlift',
                sets: 4,
                reps: '5',
                restSeconds: 180,
                muscle: 'Lưng'),
            ProgramWeeklyExercise(
                name: 'Lat Pulldown',
                sets: 4,
                reps: '10-12',
                restSeconds: 90,
                muscle: 'Cơ xô'),
            ProgramWeeklyExercise(
                name: 'Barbell Bent-Over Row',
                sets: 3,
                reps: '8-10',
                restSeconds: 90,
                muscle: 'Lưng giữa'),
            ProgramWeeklyExercise(
                name: 'Barbell Bicep Curl',
                sets: 3,
                reps: '12',
                restSeconds: 60,
                muscle: 'Tay trước'),
          ],
        ),
        ProgramWeeklyDay(
          dayOfWeek: 3,
          dayName: 'Thứ 4',
          workoutName: 'LEGS A · Đùi trước, Mông, Bắp chân',
          isRestDay: false,
          muscleGroups: ['Đùi trước', 'Mông', 'Bắp chân'],
          estimatedMinutes: request.durationMinutes,
          exercises: const [
            ProgramWeeklyExercise(
                name: 'Barbell Back Squat',
                sets: 4,
                reps: '6-8',
                restSeconds: 120,
                muscle: 'Đùi trước'),
            ProgramWeeklyExercise(
                name: 'Leg Press 45°',
                sets: 4,
                reps: '10-12',
                restSeconds: 90,
                muscle: 'Đùi trước'),
            ProgramWeeklyExercise(
                name: 'Romanian Deadlift',
                sets: 3,
                reps: '10-12',
                restSeconds: 90,
                muscle: 'Đùi sau'),
            ProgramWeeklyExercise(
                name: 'Standing Calf Raise',
                sets: 4,
                reps: '15',
                restSeconds: 60,
                muscle: 'Bắp chân'),
          ],
        ),
        ProgramWeeklyDay(
          dayOfWeek: 4,
          dayName: 'Thứ 5',
          workoutName: 'PUSH B · Ngực trên, Vai giữa, Bụng',
          isRestDay: false,
          muscleGroups: ['Ngực trên', 'Vai giữa', 'Cơ bụng'],
          estimatedMinutes: request.durationMinutes,
          exercises: const [
            ProgramWeeklyExercise(
                name: 'Incline Dumbbell Press',
                sets: 4,
                reps: '8-10',
                restSeconds: 90,
                muscle: 'Ngực trên'),
            ProgramWeeklyExercise(
                name: 'Dumbbell Lateral Raise',
                sets: 4,
                reps: '15',
                restSeconds: 60,
                muscle: 'Vai giữa'),
            ProgramWeeklyExercise(
                name: 'Cable Chest Fly',
                sets: 3,
                reps: '12-15',
                restSeconds: 60,
                muscle: 'Ngực'),
            ProgramWeeklyExercise(
                name: 'Hanging Leg Raise',
                sets: 3,
                reps: '15',
                restSeconds: 60,
                muscle: 'Bụng'),
          ],
        ),
        ProgramWeeklyDay(
          dayOfWeek: 5,
          dayName: 'Thứ 6',
          workoutName: 'PULL B & ARMS · Lưng độ dày & Cánh tay',
          isRestDay: false,
          muscleGroups: ['Lưng giữa', 'Tay trước', 'Tay sau'],
          estimatedMinutes: request.durationMinutes,
          exercises: const [
            ProgramWeeklyExercise(
                name: 'Seated Cable Row',
                sets: 4,
                reps: '10-12',
                restSeconds: 90,
                muscle: 'Lưng'),
            ProgramWeeklyExercise(
                name: 'Rear Delt Fly',
                sets: 3,
                reps: '15',
                restSeconds: 60,
                muscle: 'Vai sau'),
            ProgramWeeklyExercise(
                name: 'Hammer Curl',
                sets: 3,
                reps: '12',
                restSeconds: 60,
                muscle: 'Tay trước'),
            ProgramWeeklyExercise(
                name: 'Skull Crushers',
                sets: 3,
                reps: '12',
                restSeconds: 60,
                muscle: 'Tay sau'),
          ],
        ),
        const ProgramWeeklyDay(
          dayOfWeek: 6,
          dayName: 'Thứ 7',
          workoutName: 'Nghỉ ngơi tích cực / Cardio Zone 2',
          isRestDay: true,
        ),
        const ProgramWeeklyDay(
          dayOfWeek: 7,
          dayName: 'Chủ Nhật',
          workoutName: 'Nghỉ ngơi hoàn toàn',
          isRestDay: true,
        ),
      ]);
    }

    final totalEx = days.fold<int>(
        0, (sum, d) => sum + (d.isRestDay ? 0 : d.exercises.length));

    return DiscoverProgram(
      id: 'ai_prog_${DateTime.now().millisecondsSinceEpoch}',
      name: 'AI Personalized · $goal ($freq Ngày/Tuần)',
      author: 'FitFlow AI Coach',
      description:
          'Giáo án được thiết kế chuyên biệt dựa trên thể trạng, mục tiêu $goal và tần suất $freq buổi/tuần của bạn. Tối ưu hóa khối lượng luyện tập và thời gian phục hồi cơ bắp.',
      coverImage:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80',
      difficulty: request.experienceLevel,
      goals: [goal, 'Hypertrophy'],
      frequencyDays: freq,
      durationWeeks: 8,
      exerciseCount: totalEx,
      rating: 5.0,
      reviewCount: 1,
      popularityScore: 100,
      trendingScore: 100,
      equipment: [request.equipment],
      muscleGroups: request.targetMuscles.isNotEmpty
          ? request.targetMuscles
          : ['Ngực', 'Lưng', 'Vai', 'Tay', 'Chân', 'Cơ bụng'],
      category: goal,
      isFeatured: true,
      isTrending: true,
      weeklySchedule: days,
      accentColor: AppColors.statusRecovery,
    );
  }
}
