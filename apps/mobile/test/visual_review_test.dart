import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vincecore/core/theme/app_theme.dart';
import 'package:vincecore/main.dart';

class _CaptureHttpOverrides extends HttpOverrides {}

void main() {
  // Optional real-font capture. Normal regression runs keep Flutter's strict test font.
  setUpAll(() async {
    if (!const bool.fromEnvironment('CAPTURE_UI')) return;
    final cache = await Directory.systemTemp.createTemp('fitflow-ui-fonts-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async => cache.path);
    await HttpOverrides.runWithHttpOverrides(() async {
      AppTheme.lightTheme;
      AppTheme.darkTheme;
      await GoogleFonts.pendingFonts();
    }, _CaptureHttpOverrides());
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  testWidgets('main destinations render without overflow across phone widths',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final width in [390.0, 320.0, 768.0]) {
      tester.view.physicalSize = Size(width, 900);
      for (final dark in [false, true]) {
        await tester.pumpWidget(MaterialApp(
          theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
          home: const MainScreen(),
        ));
        for (final label in [
          'Home',
          'Phân tích',
          'Programs',
          'Dinh dưỡng',
          'Hồ sơ'
        ]) {
          await tester.tap(find.text(label).last);
          await tester.pumpAndSettle();
          if (const bool.fromEnvironment('CAPTURE_UI')) {
            await expectLater(
                find.byType(MainScreen),
                matchesGoldenFile(
                    '../../../.impeccable/flutter-review/${width.toInt()}-${dark ? 'dark' : 'light'}-$label.png'));
          }
          expect(tester.takeException(), isNull,
              reason: '$label $width dark=$dark');
        }
        await tester.pumpWidget(const SizedBox());
      }
    }
  });
}
