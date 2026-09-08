import 'package:flutter_test/flutter_test.dart';
import 'package:vincecore/main.dart';

void main() {
  testWidgets('VinceCore starts with authentication',
      (WidgetTester tester) async {
    await tester.pumpWidget(const VinceCoreApp());

    expect(find.text('Chào mừng\ntrở lại!'), findsOneWidget);
    expect(find.text('ĐĂNG NHẬP'), findsOneWidget);
  });
}
