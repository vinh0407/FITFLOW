import 'package:flutter/material.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../workout/presentation/pages/exercise_detail_page.dart';

class PopularExercisesSection extends StatelessWidget {
  const PopularExercisesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final exercises = fitnessRepository.exercises.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Popular Exercises',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isLight
                      ? AppColors.lightTextPrimary
                      : AppColors.darkTextPrimary,
                ),
              ),
              Text(
                'Top kỹ thuật chuẩn ⭐',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isLight
                      ? AppColors.lightTextMuted
                      : AppColors.darkTextMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 180,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: exercises.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final ex = exercises[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExerciseDetailPage(exercise: ex),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 200,
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isLight ? 0.02 : 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18)),
                        child: Image.network(
                          ex.imageUrl,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 100,
                            color: const Color(0xFF2C3E50),
                            child: const Center(
                              child: Icon(Icons.fitness_center_rounded,
                                  color: Colors.white54),
                            ),
                          ),
                        ),
                      ),

                      // Info
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ex.name.split(' (').first,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: isLight
                                    ? AppColors.lightTextPrimary
                                    : AppColors.darkTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ex.muscle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isLight
                                        ? AppColors.primaryBlue
                                        : AppColors.primaryBlueLight,
                                  ),
                                ),
                                Text(
                                  '${ex.targetSets} hiệp · ${ex.targetReps}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isLight
                                        ? AppColors.lightTextMuted
                                        : AppColors.darkTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
