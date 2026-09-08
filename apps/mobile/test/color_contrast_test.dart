import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vincecore/core/theme/app_colors.dart';

void main() {
  test(
      'secondary and muted labels remain readable on their light and dark surfaces',
      () {
    for (final pair in [
      [AppColors.lightTextSecondary, AppColors.lightBg],
      [AppColors.lightTextMuted, AppColors.lightBg],
      [AppColors.lightTextMuted, AppColors.lightSurface],
      [AppColors.darkTextMuted, AppColors.darkSurface],
      [AppColors.darkTextSecondary, AppColors.darkBg],
    ]) {
      final luminances =
          pair.map((Color color) => color.computeLuminance()).toList()..sort();
      final ratio = (luminances.last + 0.05) / (luminances.first + 0.05);
      expect(ratio, greaterThanOrEqualTo(4.5), reason: '$pair');
    }
  });
}
