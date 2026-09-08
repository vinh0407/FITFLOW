import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/training_style_model.dart';

class TrainingStylesSection extends StatelessWidget {
  const TrainingStylesSection({
    super.key,
    required this.onSelectStyle,
  });

  final Function(TrainingStyle style) onSelectStyle;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    const styles = TrainingStyle.defaultStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Training Styles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isLight
                  ? AppColors.lightTextPrimary
                  : AppColors.darkTextPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 140,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: styles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final s = styles[index];
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelectStyle(s);
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 220,
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
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: s.badgeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.fitness_center_rounded,
                                size: 20),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: s.badgeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s.goal,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: s.badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isLight
                                  ? AppColors.lightTextPrimary
                                  : AppColors.darkTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.tagline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
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
              );
            },
          ),
        ),
      ],
    );
  }
}
