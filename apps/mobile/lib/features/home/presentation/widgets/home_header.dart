import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.onAvatarTap,
    this.onNotificationTap,
  });

  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Chào buổi sáng 👋';
    } else if (hour < 18) {
      return 'Chào buổi chiều 👋';
    } else {
      return 'Chào buổi tối 👋';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final profile = fitnessRepository.profile;
    final userName = profile.name.trim().isNotEmpty ? profile.name : 'Vinh';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar + Greeting
        Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onAvatarTap?.call();
                },
                child: Hero(
                  tag: 'user_avatar',
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isLight
                            ? AppColors.lightBorder
                            : AppColors.darkBorder,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.primaryBlue.withValues(alpha: 0.15),
                          child: Center(
                            child: Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : 'V',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: isLight
                                    ? AppColors.lightTextPrimary
                                    : AppColors.darkTextPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isLight
                            ? AppColors.lightTextMuted
                            : AppColors.darkTextMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chào $userName, sẵn sàng tập luyện?',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: isLight
                            ? AppColors.lightTextPrimary
                            : AppColors.darkTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Notification Bell Icon with 9+ badge
        Tooltip(
          message: 'Thông báo',
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onNotificationTap?.call();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 22,
                      color: isLight
                          ? AppColors.lightTextPrimary
                          : AppColors.darkTextPrimary,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 14,
                      ),
                      child: const Center(
                        child: Text(
                          '9+',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
