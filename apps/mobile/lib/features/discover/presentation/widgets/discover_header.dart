import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class DiscoverHeader extends StatelessWidget {
  const DiscoverHeader({
    super.key,
    required this.savedCount,
    required this.onSavedTap,
    required this.onAiTap,
  });

  final int savedCount;
  final VoidCallback onSavedTap;
  final VoidCallback onAiTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title + "9+" badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Discover',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: isLight
                    ? AppColors.lightTextPrimary
                    : AppColors.darkTextPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '9+',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),

        // Action Buttons: AI Program & Saved Bookmark
        Row(
          children: [
            // AI Program Quick Button
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onAiTap();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.aiPurple, AppColors.statusRecovery],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.aiPurple.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'AI Coach',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Saved Bookmark Button
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onSavedTap();
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      isLight ? AppColors.lightSurface : AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        isLight ? AppColors.lightBorder : AppColors.darkBorder,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_outline_rounded,
                      size: 20,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
                    if (savedCount > 0)
                      Positioned(
                        top: 7,
                        right: 7,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
