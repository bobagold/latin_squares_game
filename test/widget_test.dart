// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:latinsquaresgame/main.dart';

void main() {
  testWidgets('Reset puts all to 0', (tester) async {
    await tester.pumpWidget(MaterialApp(home: GameScreen()));

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsNWidgets(5));

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    expect(find.text('0'), findsNWidgets(20));
  });
}
