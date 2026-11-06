// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:instragram/main.dart';

void main() {
  testWidgets('Instagram app loads with bottom navigation', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const InstagramApp());

    // Verify that the app title is present.
    expect(find.text('Instagram'), findsOneWidget);

    // Verify that the bottom navigation items are present.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Create'), findsOneWidget);
    expect(find.text('Reels'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
