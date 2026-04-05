import 'package:flutter_test/flutter_test.dart';
import 'package:timeleak/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Landing page loads smoke test', (WidgetTester tester) async {
    // Note: We can't easily test the full main() because of Firebase and Isar init
    // So we test the MyApp widget directly with a simple placeholder or mock if needed.
    // For a basic "run test" request, we'll just fix the compilation error and do a basic check.
    
    await tester.pumpWidget(const MyApp());

    // Verify that landing page text is present
    expect(find.text('Time Leak'), findsWidgets);
    expect(find.byType(ElevatedButton), findsWidgets);
  });
}
