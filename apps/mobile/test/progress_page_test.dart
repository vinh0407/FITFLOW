import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vincecore/core/theme/app_theme.dart';
import 'package:vincecore/features/progress/presentation/pages/progress_page.dart';
import 'package:vincecore/features/progress/presentation/widgets/dialogs/add_weight_sheet.dart';
import 'package:vincecore/features/progress/presentation/widgets/dialogs/create_goal_sheet.dart';
import 'package:vincecore/features/home/presentation/widgets/dialogs/add_schedule_sheet.dart';

void main() {
  testWidgets('entry sheets stay usable with large text and an open keyboard',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      for (final size in [
        const Size(320, 800),
        const Size(360, 800),
        const Size(375, 812),
        const Size(414, 896),
        const Size(768, 600)
      ]) {
        tester.view.physicalSize = size;
        tester.view.viewInsets = const FakeViewPadding(bottom: 240);
        for (final sheet in [
          const AddWeightSheet(),
          const CreateGoalSheet(),
          const AddScheduleSheet()
        ]) {
          await tester.pumpWidget(MaterialApp(
            theme: theme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: Builder(
                builder: (context) => Scaffold(
                        body: TextButton(
                      onPressed: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => sheet),
                      child: const Text('Open'),
                    ))),
          ));
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull,
              reason: '${sheet.runtimeType} at $size');
          expect(find.byTooltip('Đóng'), findsOneWidget);
          await tester.ensureVisible(find.byType(ElevatedButton).last);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.byTooltip('Đóng'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Đóng'));
          await tester.pumpAndSettle();
          expect(find.byType(sheet.runtimeType), findsNothing);
          await tester.pumpWidget(const SizedBox());
        }
      }
    }
  });

  testWidgets('ProgressPage (Analysis) renders all core components and goals',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ProgressPage(),
      ),
    );

    // 1. Overall Stats Header
    expect(find.text('Overall Stats'), findsOneWidget);

    // 2. Current Weight Card
    expect(find.text('Current Weight'), findsOneWidget);
    expect(find.textContaining('75.3 kg'), findsOneWidget);
    expect(find.text('Yearly'), findsOneWidget);
    expect(find.text('Thêm cân nặng'), findsOneWidget);

    // 3. Workout Goals
    expect(find.text('Workout Goals'), findsOneWidget);
    expect(find.text('Arm & shoulder muscle'), findsOneWidget);
    expect(find.text('Core & abdominal'), findsOneWidget);
    expect(find.text('Leg & glute power'), findsOneWidget);
    expect(find.text('Tạo mục tiêu'), findsOneWidget);

    // 4. Muscle Recovery & 1RM
    expect(find.text('Phục hồi theo vị trí cơ'), findsOneWidget);
    expect(find.text('Mặt trước'), findsOneWidget);
    expect(find.text('Mặt sau'), findsOneWidget);
    expect(find.text('Mức 1RM & Xếp hạng sức mạnh'), findsOneWidget);
  });
}
