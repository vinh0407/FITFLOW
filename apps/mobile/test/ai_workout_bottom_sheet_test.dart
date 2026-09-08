import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vincecore/core/theme/app_theme.dart';
import 'package:vincecore/widgets/ai_workout_bottom_sheet.dart';
import 'package:vincecore/main.dart';

void main() {
  testWidgets('AI Coach follows input then result steps',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: SizedBox()),
      ),
    );

    AiWorkoutBottomSheet.show(tester.element(find.byType(SizedBox)));
    await tester.pumpAndSettle();

    expect(find.text('BƯỚC 1 / HỒ SƠ TẬP LUYỆN'), findsOneWidget);
    expect(find.text('XEM PHÂN TÍCH'), findsOneWidget);

    await tester.tap(find.text('XEM PHÂN TÍCH'));
    await tester.pumpAndSettle();

    expect(find.text('AI PHÂN TÍCH CHƯƠNG TRÌNH'), findsOneWidget);
    expect(find.text('BẮT ĐẦU BUỔI TẬP AI'), findsOneWidget);
  });

  testWidgets('AI Coach stays usable on compact phone widths',
      (WidgetTester tester) async {
    for (final width in [320.0, 360.0, 375.0, 390.0, 414.0]) {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: SizedBox()),
        ),
      );
      AiWorkoutBottomSheet.show(tester.element(find.byType(SizedBox)));
      await tester.pumpAndSettle();
      expect(find.text('XEM PHÂN TÍCH'), findsOneWidget);
      await tester.tap(find.byTooltip('Đóng'));
      await tester.pumpAndSettle();
    }
    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('mobile navigation exposes the central AI Coach action',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    ));
    expect(find.text('AI'), findsOneWidget);
    expect(find.text('Programs'), findsOneWidget);
    await tester.tap(find.text('AI'));
    await tester.pumpAndSettle();
    expect(find.text('BƯỚC 1 / HỒ SƠ TẬP LUYỆN'), findsOneWidget);
  });

  testWidgets('navigation adapts to tablet and larger text scale',
      (WidgetTester tester) async {
    tester.binding.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue();
    });

    for (final width in [768.0, 1024.0, 1280.0]) {
      tester.view.physicalSize = Size(width, 1366);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
      ));
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('HOME'), findsOneWidget);
    }
  });
}
