import 'package:flutter/material.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/discover_program_model.dart';
import 'program_card.dart';

class TrendingProgramsSection extends StatelessWidget {
  const TrendingProgramsSection({
    super.key,
    required this.onProgramTap,
  });

  final Function(DiscoverProgram program) onProgramTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final trending = fitnessRepository.trendingPrograms;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending Programs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isLight
                      ? AppColors.lightTextPrimary
                      : AppColors.darkTextPrimary,
                ),
              ),
              Text(
                'Phổ biến nhất',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isLight
                      ? AppColors.primaryBlue
                      : AppColors.primaryBlueLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 195,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: trending.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final prog = trending[index];
              return ProgramCard(
                program: prog,
                isCompact: true,
                onTap: () => onProgramTap(prog),
              );
            },
          ),
        ),
      ],
    );
  }
}
