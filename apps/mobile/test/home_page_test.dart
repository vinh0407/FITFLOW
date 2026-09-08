import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vincecore/core/theme/app_theme.dart';
import 'package:vincecore/features/home/presentation/pages/home_page.dart';
import 'package:vincecore/features/home/presentation/widgets/home_compact_week_calendar.dart';
import 'package:vincecore/features/home/presentation/widgets/home_nutrition_card.dart';

void main() {
  testWidgets(
      'calendar and nutrition remain readable with large text on compact phones',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final width in [320.0, 360.0, 414.0, 768.0]) {
      tester.view.physicalSize = Size(width, 900);
      for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
        await tester.pumpWidget(MaterialApp(
          theme: theme,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
                body: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    HomeCompactWeekCalendar(onDaySelected: (_) {}),
                    HomeNutritionCard(onTap: () {}),
                  ])),
            )),
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'width $width');
      }
    }
  });
  testWidgets('HomePage renders all 7 required core components',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const HomePage(),
      ),
    );

    // 1. Header greeting
    expect(find.textContaining('sẵn sàng tập luyện?'), findsOneWidget);

    // 2. Streak & Calendar
    expect(find.text('T2'), findsWidgets);

    // 3. Nutrition Card
    expect(find.text('DINH DƯỠNG HÔM NAY'), findsOneWidget);
    expect(find.text('Mục tiêu calo hàng ngày'), findsOneWidget);

    // 4. Muscle Recovery Card
    expect(find.text('PHỤC HỒI CƠ BẮP'), findsOneWidget);
    expect(find.text('Cơ bắp đã hồi phục 78%'), findsOneWidget);

    // 5. Today's Exercises
    expect(find.text('BÀI TẬP HÔM NAY'), findsOneWidget);
    expect(find.text('Chest Press'), findsWidgets);

    // 6. Workout Schedule
    expect(find.text('LỊCH TẬP'), findsOneWidget);
    expect(find.text('Thêm'), findsOneWidget);
    expect(find.text('Xem lịch tập các ngày sau trong tuần'), findsOneWidget);
  });

  testWidgets('nutrition card opens the nutrition tab',
      (WidgetTester tester) async {
    var selectedTab = -1;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: HomePage(onNavigateTab: (index) => selectedTab = index),
      ),
    );

    await tester.tap(find.text('DINH DƯỠNG HÔM NAY'));
    await tester.pump();

    expect(selectedTab, 3);
  });
}
