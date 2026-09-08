// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('shows the Blokus board and places a piece', (tester) async {
    await tester.pumpWidget(const BlokusApp());

    expect(find.text('BLOKUS'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('ピースを選んで盤面に置こう'), findsOneWidget);

    final board = find.byType(GridView);
    final firstCell = find
        .descendant(of: board, matching: find.byType(GestureDetector))
        .first;
    await tester.ensureVisible(firstCell);
    await tester.tap(firstCell);
    await tester.pump();

    expect(find.text('10'), findsOneWidget);
    expect(find.text('ナイス！ 次のピースを選ぼう'), findsOneWidget);
  });

  testWidgets('can rotate and reset the selected piece', (tester) async {
    await tester.pumpWidget(const BlokusApp());

    final rotateButton = find.byIcon(Icons.rotate_right_rounded);
    await tester.ensureVisible(rotateButton);
    await tester.tap(rotateButton);
    await tester.pump();
    expect(find.text('回転しました。置きたい場所をタップ'), findsOneWidget);

    final resetButton = find.byIcon(Icons.refresh_rounded);
    await tester.ensureVisible(resetButton);
    await tester.tap(resetButton);
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
    expect(find.text('ピースを選んで盤面に置こう'), findsOneWidget);
  });
}
