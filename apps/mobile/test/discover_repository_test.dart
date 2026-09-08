import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vincecore/core/fitness_repository.dart';
import 'package:vincecore/features/discover/domain/models/discover_program_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saved programs persist across repository instances', () async {
    final firstRepository = FitnessRepository();
    await firstRepository.load();
    await firstRepository.toggleSaveProgram('prog_powerbuilding_5x');

    final secondRepository = FitnessRepository();
    await secondRepository.load();

    expect(secondRepository.isProgramSaved('prog_powerbuilding_5x'), isTrue);
  });

  test('AI programs persist with their saved state', () async {
    final firstRepository = FitnessRepository();
    await firstRepository.load();
    const program = DiscoverProgram(
      id: 'ai_prog_test',
      name: 'Test AI Program',
      author: 'FITFLOW AI',
      description: 'A locally saved personalized plan.',
      coverImage: '',
      difficulty: 'Beginner',
      goals: ['General Fitness'],
      frequencyDays: 3,
      durationWeeks: 4,
      exerciseCount: 9,
      rating: 5,
      reviewCount: 0,
      popularityScore: 0,
      trendingScore: 0,
      equipment: ['Bodyweight'],
      muscleGroups: ['Full Body'],
      category: 'General Fitness',
    );

    await firstRepository.addCustomAiProgram(program);

    final secondRepository = FitnessRepository();
    await secondRepository.load();

    expect(secondRepository.isProgramSaved(program.id), isTrue);
    expect(secondRepository.discoverPrograms.first.id, program.id);
  });
}
