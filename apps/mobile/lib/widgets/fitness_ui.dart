import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';

class FitnessCard extends StatelessWidget {
  const FitnessCard({
    super.key,
    required this.child,
    this.padding = 16,
    this.margin,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final double padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? AppColors.lightSurface : AppColors.darkSurface;
    final cardBorder = isLight ? AppColors.lightBorder : AppColors.darkBorder;

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: isLight
            ? const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: child,
          ),
        ),
      ),
    );
    if (semanticLabel != null) {
      return Semantics(
        button: onTap != null,
        label: semanticLabel,
        onTap: onTap,
        excludeSemantics: true,
        child: card,
      );
    }
    return onTap == null
        ? card
        : Semantics(button: true, onTap: onTap, child: card);
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title,
      {super.key, this.subtitle, this.action, this.onAction});
  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5)),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                  ]),
            ),
            if (action != null)
              Semantics(
                button: true,
                label: action!,
                onTap: onAction,
                child: ScaleButton(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onAction?.call();
                  },
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          action!.toUpperCase(),
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? AppColors.primaryBlue
                                    : AppColors.primaryBlueLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

class Metric extends StatelessWidget {
  const Metric(
      {super.key,
      required this.value,
      required this.label,
      this.unit,
      this.accent = false});
  final String value;
  final String label;
  final String? unit;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryColor = accent
        ? (isLight ? AppColors.primaryBlue : AppColors.primaryBlueLight)
        : (isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary);
    final mutedColor =
        isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted;

    return Semantics(
        label: '$label: $value${unit == null ? '' : ' $unit'}',
        excludeSemantics: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value,
                    style: TextStyle(
                        color: primaryColor,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5)),
                if (unit != null)
                  Text(' $unit',
                      style: TextStyle(
                          color: mutedColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
              ]),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: mutedColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8)),
        ]));
  }
}

class ThinProgress extends StatelessWidget {
  const ThinProgress(
      {super.key, required this.value, this.color = AppColors.primaryBlue});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Semantics(
      label: 'Progress',
      value: '${(value.clamp(0, 1) * 100).round()} percent',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value.clamp(0, 1),
          minHeight: 6,
          backgroundColor:
              isLight ? AppColors.lightBorder : AppColors.surfaceHighest,
          color: color,
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, this.active = false, this.onTap});
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final inactiveBg =
        isLight ? AppColors.lightSurfaceMid : AppColors.darkSurfaceMid;
    final inactiveBorder =
        isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final inactiveText =
        isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary;
    final activeColor =
        isLight ? AppColors.primaryBlue : AppColors.primaryBlueLight;

    return Semantics(
      button: onTap != null,
      selected: active,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? activeColor : inactiveBg,
            border: Border.all(
              color: active ? activeColor : inactiveBorder,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.white : inactiveText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class WeekCalendarStrip extends StatelessWidget {
  final int selectedDayIndex;
  final Function(int) onSelectDay;

  const WeekCalendarStrip({
    super.key,
    required this.selectedDayIndex,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final dates =
        List<int>.generate(7, (index) => monday.add(Duration(days: index)).day);
    final activeColor =
        isLight ? AppColors.primaryBlue : AppColors.primaryBlueLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final isSelected = selectedDayIndex == i;
        return Semantics(
          button: true,
          selected: isSelected,
          label: '${days[i]}, day ${dates[i]}${isSelected ? ', selected' : ''}',
          onTap: () => onSelectDay(i),
          excludeSemantics: true,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelectDay(i);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              constraints: const BoxConstraints(minWidth: 42, minHeight: 52),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    days[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.white
                          : (isLight
                              ? AppColors.lightTextMuted
                              : AppColors.darkTextMuted),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dates[i]}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? AppColors.white
                          : (isLight
                              ? AppColors.lightTextPrimary
                              : AppColors.darkTextPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class DualFloatingWorkoutButtons extends StatelessWidget {
  final VoidCallback onFreeWorkout;
  final VoidCallback onAiWorkout;

  const DualFloatingWorkoutButtons({
    super.key,
    required this.onFreeWorkout,
    required this.onAiWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? AppColors.lightSurface : AppColors.darkSurface;
    final border = isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final activeColor =
        isLight ? AppColors.primaryBlue : AppColors.primaryBlueLight;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.08 : 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tập tự do Button
          ElevatedButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              onFreeWorkout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isLight
                  ? AppColors.lightSurfaceMid
                  : AppColors.darkSurfaceMid,
              foregroundColor: isLight
                  ? AppColors.lightTextPrimary
                  : AppColors.darkTextPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              minimumSize: const Size(115, 48),
            ),
            child: const Text(
              'Tập tự do',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),

          // Bài tập AI Button
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onAiWorkout();
            },
            icon: const Icon(Icons.auto_awesome,
                color: AppColors.white, size: 16),
            label: const Text(
              'Bài tập AI',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: AppColors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: activeColor,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              minimumSize: const Size(130, 48),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyPanel extends StatelessWidget {
  const EmptyPanel({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.onAction,
  });
  final String title;
  final String message;
  final IconData icon;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight
        ? AppColors.lightSurfaceMid
        : AppColors.darkSurface.withValues(alpha: 0.5);
    final border = isLight
        ? AppColors.lightBorder
        : AppColors.darkBorder.withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon,
              size: 48,
              color:
                  isLight ? AppColors.lightTextMuted : AppColors.textDisabled),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: isLight
                  ? AppColors.lightTextPrimary
                  : AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isLight
                  ? AppColors.lightTextSecondary
                  : AppColors.darkTextSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                onAction?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isLight
                    ? AppColors.primaryBlue
                    : AppColors.primaryBlueLight,
                foregroundColor: Colors.white,
                minimumSize: const Size(160, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                action!,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final iconBg =
        isLight ? AppColors.lightSurfaceMid : AppColors.darkSurfaceMid;
    final iconColor =
        isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary;
    final dividerColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;

    return Semantics(
      button: onTap != null,
      label: subtitle == null ? title : '$title, $subtitle',
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isLight
                                ? AppColors.lightTextPrimary
                                : AppColors.darkTextPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              color: isLight
                                  ? AppColors.lightTextMuted
                                  : AppColors.darkTextMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null)
                    trailing!
                  else
                    Icon(Icons.chevron_right,
                        color: isLight
                            ? AppColors.lightTextMuted
                            : AppColors.darkTextMuted,
                        size: 20),
                ],
              ),
            ),
            if (showDivider)
              Divider(
                height: 1,
                color: dividerColor,
                indent: 52,
              ),
          ],
        ),
      ),
    );
  }
}

class ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double scale;

  const ScaleButton({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 100),
    this.scale = 0.95,
  });

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => widget.onTap != null ? _controller.forward() : null,
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _animation,
        child: widget.child,
      ),
    );
  }
}

class CircularPercentGauge extends StatelessWidget {
  const CircularPercentGauge({
    super.key,
    required this.percent,
    this.size = 54,
    this.strokeWidth = 5,
    this.color = AppColors.primaryBlue,
    this.backgroundColor,
    this.label,
  });

  final double percent;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color? backgroundColor;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final defaultBg = backgroundColor ??
        (isLight
            ? Colors.grey.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.12));

    final displayText = label ?? '${(percent * 100).round()}%';

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            strokeWidth: strokeWidth,
            backgroundColor: defaultBg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeCap: StrokeCap.round,
          ),
          Text(
            displayText,
            style: TextStyle(
              fontSize: size * 0.26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
