import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('opens PvP from the main menu', (tester) async {
    await tester.pumpWidget(const BlokusApp());

    expect(find.text('対戦する'), findsOneWidget);
    expect(find.text('ルールを見る'), findsOneWidget);

    await tester.tap(find.text('対戦する'));
    await tester.pumpAndSettle();
    expect(find.text('対戦モードを選択'), findsOneWidget);

    await tester.tap(find.text('PvP'));
    await tester.pumpAndSettle();
    expect(find.text('対戦中'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });

  test('enforces first placement and awards edge points', () {
    final match = MatchState(false, Random(1));
    final firstPiece = match.players[0].hand.first;
    final shape = firstPiece.shape;
    final startRow = 10 - shape.map((cell) => cell[0]).reduce(max);
    final result = match.tryPlace(0, 0, startRow, 5);

    expect(result.success, isTrue);
    expect(match.players[0].hand.first.used, isTrue);
    expect(match.turn, 1);
    expect(match.players[0].score, 0);

    final secondPieceIndex = match.players[1].hand.indexWhere(
      (piece) => !piece.used,
    );
    expect(secondPieceIndex, greaterThanOrEqualTo(0));
    final secondPiece = match.players[1].hand[secondPieceIndex];
    final secondShape = secondPiece.shape;
    final secondRow = secondShape.map((cell) => cell[0]).reduce(max);
    PlacementResult secondResult = const PlacementResult(false, '');
    for (var rotation = 0; rotation < 4 && !secondResult.success; rotation++) {
      secondResult = match.tryPlace(secondPieceIndex, rotation, 0, 5);
    }
    expect(secondResult.success, isTrue);
    expect(match.players[1].hand[secondPieceIndex].used, isTrue);
    expect(secondRow, lessThan(11));
  });

  test('previews a placement before the second tap commits it', () {
    final match = MatchState(false, Random(3));
    final piece = match.players[0].hand.first;
    final row = 10 - piece.shape.map((cell) => cell[0]).reduce(max);

    final preview = match.previewPlacement(0, 0, row, 5);
    expect(preview.success, isTrue);
    expect(preview.positions, isNotEmpty);
    expect(match.board.every((cell) => cell == null), isTrue);
    expect(piece.used, isFalse);
    expect(match.players[0].score, 0);

    final placed = match.tryPlace(0, 0, row, 5);
    expect(placed.success, isTrue);
    expect(match.board.any((cell) => cell == 0), isTrue);
    expect(piece.used, isTrue);
  });

  testWidgets('shows the written rules', (tester) async {
    await tester.pumpWidget(const BlokusApp());
    await tester.tap(find.text('ルールを見る'));
    await tester.pumpAndSettle();

    expect(find.text('ブロックスのルール'), findsOneWidget);
    expect(find.textContaining('交互にブロックを置きます'), findsOneWidget);
  });
}
