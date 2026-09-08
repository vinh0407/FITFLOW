import 'package:flutter/material.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/discover_program_model.dart';
import 'program_card.dart';

class RecommendedProgramsSection extends StatelessWidget {
  const RecommendedProgramsSection({
    super.key,
    required this.onProgramTap,
  });

  final Function(DiscoverProgram program) onProgramTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final recommended = fitnessRepository.recommendedPrograms;
    final profile = fitnessRepository.profile;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Recommended For You',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isLight
                      ? AppColors.lightTextPrimary
                      : AppColors.darkTextPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.statusRecovery.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  profile.trainingGoal.isNotEmpty
                      ? profile.trainingGoal
                      : 'Cá nhân hóa',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.statusRecovery,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...recommended.map((prog) {
            return ProgramCard(
              program: prog,
              isCompact: false,
              onTap: () => onProgramTap(prog),
            );
          }),
        ],
      ),
    );
  }
}
