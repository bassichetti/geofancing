// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:geofancing/main.dart';

void main() {
  testWidgets('Geofencing app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GeofencingApp());

    // Verify that the app loads and shows the geofencing title
    expect(find.text('Geofencing'), findsOneWidget);

    // Verify that the floating action buttons are present
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    expect(find.byIcon(Icons.pentagon_outlined), findsOneWidget);
    expect(find.byIcon(Icons.my_location), findsOneWidget);
  });
}
