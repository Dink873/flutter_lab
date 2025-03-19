import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:my_project/main.dart';

void main() {
  testWidgets('Перевірка генерації випадкового числа', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(Text), findsWidgets);

    final button = find.text("Згенерувати");
    expect(button, findsOneWidget);

    await tester.tap(button);
    await tester.pump();

    expect(find.byType(Text), findsWidgets);
  });
}
