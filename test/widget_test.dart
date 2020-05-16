// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:latinsquaresgame/screens/game.dart';
import 'package:latinsquaresgame/translations/localizations.dart';

void main() {
  testWidgets('Reset puts all to 0', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AppLocalizationsWidgetWrapper(
        locale: Locale('en'),
        child: GameScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsNWidgets(5));

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    expect(find.text('0'), findsNWidgets(20));
  });
}
