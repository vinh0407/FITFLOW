import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OverallStatsHeader extends StatelessWidget {
  const OverallStatsHeader({
    super.key,
    this.onMenuTap,
  });

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Text(
          'Overall Stats',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: isLight
                ? AppColors.lightTextPrimary
                : AppColors.darkTextPrimary,
          ),
        )),
        const SizedBox(width: 8),
        Tooltip(
            message: 'Tùy chọn phân tích',
            child: InkWell(
              onTap: onMenuTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      isLight ? AppColors.lightSurface : AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        isLight ? AppColors.lightBorder : AppColors.darkBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isLight ? 0.02 : 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: isLight
                      ? AppColors.lightTextPrimary
                      : AppColors.darkTextPrimary,
                ),
              ),
            )),
      ],
    );
  }
}
