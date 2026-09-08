import 'package:flutter/material.dart';
import 'package:vincecore/core/fitness_repository.dart';
import 'package:vincecore/core/theme/app_colors.dart';
import 'package:vincecore/features/discover/domain/models/discover_program_model.dart';
import 'package:vincecore/features/discover/presentation/widgets/program_card.dart';

class SavedProgramsSheet extends StatelessWidget {
  const SavedProgramsSheet({
    super.key,
    required this.onProgramTap,
  });

  final Function(DiscoverProgram program) onProgramTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final savedIds = fitnessRepository.savedProgramIds;
    final savedPrograms = fitnessRepository.discoverPrograms
        .where((p) => savedIds.contains(p.id))
        .toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      child: Column(
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
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bookmark_rounded,
                      color: AppColors.primaryBlue, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Saved Programs (${savedPrograms.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
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

          const SizedBox(height: 10),

          // List or Empty State
          Expanded(
            child: savedPrograms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔖', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 12),
                        Text(
                          'Bạn chưa lưu chương trình nào.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isLight
                                ? AppColors.lightTextPrimary
                                : AppColors.darkTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nhấn biểu tượng bookmark trên giáo án để lưu lại và truy cập nhanh sau này.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isLight
                                ? AppColors.lightTextMuted
                                : AppColors.darkTextMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: savedPrograms.length,
                    itemBuilder: (context, index) {
                      final p = savedPrograms[index];
                      return ProgramCard(
                        program: p,
                        onTap: () {
                          Navigator.pop(context);
                          onProgramTap(p);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
