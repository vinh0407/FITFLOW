import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/discover_program_model.dart';

class ProgramCard extends StatelessWidget {
  const ProgramCard({
    super.key,
    required this.program,
    required this.onTap,
    this.isCompact = false,
  });

  final DiscoverProgram program;
  final VoidCallback onTap;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isSaved = fitnessRepository.isProgramSaved(program.id);

    if (isCompact) {
      // Horizontal compact card for carousels
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 260,
          decoration: BoxDecoration(
            color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isLight ? 0.03 : 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cover Image with Badge & Bookmark
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      program.coverImage,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 130,
                        color: const Color(0xFF2C3E50),
                        child: const Center(
                          child: Icon(Icons.fitness_center_rounded,
                              size: 40, color: Colors.white54),
                        ),
                      ),
                    ),
                  ),

                  // Dark gradient overlay for contrast
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Difficulty pill on top left
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        program.difficulty,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Bookmark button on top right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        fitnessRepository.toggleSaveProgram(program.id);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                        child: Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          size: 18,
                          color: isSaved ? AppColors.primaryBlue : Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Category & Rating on bottom of cover
                  Positioned(
                    bottom: 8,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          program.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white70,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 14, color: AppColors.statusWarning),
                            const SizedBox(width: 2),
                            Text(
                              program.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 2. Details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isLight
                            ? AppColors.lightTextPrimary
                            : AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${program.frequencyDays} ngày/tuần · ${program.durationWeeks} tuần · ${program.exerciseCount} bài',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isLight
                            ? AppColors.lightTextMuted
                            : AppColors.darkTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Full vertical card for lists & grids
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isLight ? 0.02 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                program.coverImage,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: const Color(0xFF2C3E50),
                  child: const Center(
                    child: Icon(Icons.fitness_center_rounded,
                        color: Colors.white54),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: program.accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          program.difficulty,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: program.accentColor,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.statusWarning),
                          const SizedBox(width: 2),
                          Text(
                            program.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isLight
                                  ? AppColors.lightTextPrimary
                                  : AppColors.darkTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    program.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${program.frequencyDays} ngày/tuần · ${program.durationWeeks} tuần · ${program.exerciseCount} bài',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isLight
                          ? AppColors.lightTextMuted
                          : AppColors.darkTextMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Bookmark icon
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                fitnessRepository.toggleSaveProgram(program.id);
              },
              icon: Icon(
                isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_outline_rounded,
                color: isSaved
                    ? AppColors.primaryBlue
                    : (isLight
                        ? AppColors.lightTextSecondary
                        : AppColors.darkTextSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
