import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doctor_appointment_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());  // 👈 SIN const

    // Verify that the app starts (basic smoke test)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
