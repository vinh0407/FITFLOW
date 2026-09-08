import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DiscoverSearchBar extends StatelessWidget {
  const DiscoverSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.02 : 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color:
              isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search exercises, programs, goals...',
          hintStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 22,
            color: isLight
                ? AppColors.lightTextSecondary
                : AppColors.darkTextSecondary,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: onClear,
                  color: isLight
                      ? AppColors.lightTextSecondary
                      : AppColors.darkTextSecondary,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
