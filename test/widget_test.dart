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
    expect(match.board[10 * 11 + 5], 0);
    expect(match.board[5], 1);
    final firstPiece = match.players[0].hand.first;
    final shape = firstPiece.shape;
    final startRow =
        10 - shape.map((cell) => cell[0]).reduce((a, b) => a > b ? a : b);
    final result = match.tryPlace(0, 0, startRow, 4);

    expect(result.success, isTrue);
    expect(match.players[0].hand.first.used, isTrue);
    expect(match.turn, 1);
    expect(match.players[0].score, greaterThan(0));

    final secondPieceIndex = match.players[1].hand.indexWhere(
      (piece) => !piece.used,
    );
    expect(secondPieceIndex, greaterThanOrEqualTo(0));
    final secondPiece = match.players[1].hand[secondPieceIndex];
    PlacementResult secondResult = const PlacementResult(false, '');
    for (var rotation = 0; rotation < 4 && !secondResult.success; rotation++) {
      for (var row = 0; row < 11 && !secondResult.success; row++) {
        for (var col = 0; col < 11 && !secondResult.success; col++) {
          secondResult = match.tryPlace(secondPieceIndex, rotation, row, col);
        }
      }
    }
    expect(secondResult.success, isTrue);
    expect(match.players[1].hand[secondPieceIndex].used, isTrue);
  });

  test('previews a placement before the second tap commits it', () {
    final match = MatchState(false, Random(3));
    final piece = match.players[0].hand.first;
    PlacementResult? legalPreview;
    var legalRow = 0;
    var legalCol = 0;
    for (var row = 0; row < 11 && legalPreview == null; row++) {
      for (var col = 0; col < 11 && legalPreview == null; col++) {
        final candidate = match.previewPlacement(0, 0, row, col);
        if (candidate.success) {
          legalPreview = candidate;
          legalRow = row;
          legalCol = col;
        }
      }
    }
    expect(legalPreview, isNotNull);

    expect(legalPreview!.positions, isNotEmpty);
    expect(match.board.where((cell) => cell != null).length, 2);
    expect(piece.used, isFalse);
    expect(match.players[0].score, 0);

    final overlap = match.previewPlacement(0, 0, 10, 5);
    expect(overlap.success, isFalse);
    expect(overlap.positions, isNotEmpty);
    expect(overlap.conflictingPositions, isNotEmpty);
    expect(piece.used, isFalse);

    final placed = match.tryPlace(0, 0, legalRow, legalCol);
    expect(placed.success, isTrue);
    expect(match.board.any((cell) => cell == 0), isTrue);
    expect(piece.used, isTrue);
  });

  test('allows the current orientation at zero energy', () {
    final match = MatchState(false, Random(8));
    final piece = match.players[0].hand.first;
    match.players[0].energy = 0;
    final legal = _findPlacement(match, 0, 0);

    expect(legal, isNotNull);
    final placed = match.tryPlace(0, 0, legal!.$1, legal.$2);
    expect(placed.success, isTrue);
    expect(piece.used, isTrue);
  });

  test('automatically skips a player with no remaining hand', () {
    final match = MatchState(false, Random(9));
    for (final piece in match.players[0].hand) {
      piece.used = true;
    }
    match.turn = 0;
    match.skipTurn();

    expect(match.turn, 1);
    expect(match.finished, isFalse);
  });

  testWidgets('shows the written rules', (tester) async {
    await tester.pumpWidget(const BlokusApp());
    await tester.tap(find.text('ルールを見る'));
    await tester.pumpAndSettle();

    expect(find.text('ブロックスのルール'), findsOneWidget);
    expect(find.textContaining('交互にブロックを置きます'), findsOneWidget);
  });
}

(int, int)? _findPlacement(MatchState match, int handIndex, int rotation) {
  for (var row = 0; row < 11; row++) {
    for (var col = 0; col < 11; col++) {
      if (match.previewPlacement(handIndex, rotation, row, col).success) {
        return (row, col);
      }
    }
  }
  return null;
}
