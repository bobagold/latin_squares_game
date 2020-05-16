import 'dart:math';

import 'package:flutter/widgets.dart';

import 'logic.dart';

enum GameStatus { initialDemo, newGame, invalid, unsolvable, solvable, solved }

@immutable
class Move {
  final int i;
  final int j;
  final int value;

  Move(this.i, this.j, this.value);
}

@immutable
class Game {
  static const int dimension = 5;
  final GameStatus status;
  final List<int> cells;
  final List<int> invalidCells;

  Game._(this.status, this.cells, this.invalidCells);
  Game.initialDemo()
      : status = GameStatus.initialDemo,
        cells = _demoCells(),
        invalidCells = [];
  Game.newGame()
      : status = GameStatus.newGame,
        cells = _newGameCells(),
        invalidCells = [];

  List<int> get diagonal =>
      List.generate(dimension, (i) => cells[i * dimension + i]);

  Game move(Move m) {
    var cells = List.of(this.cells);
    cells[m.i * dimension + m.j] = m.value;
    var checks = validateLatinSquareCells(cells, dimension);
    var gameStatus;
    var invalidCells = checks[0];
    var hasInvalid = invalidCells.isNotEmpty;
    var hasEmptyCells = checks[1].isNotEmpty;
    if (hasInvalid) {
      gameStatus = GameStatus.invalid;
    } else if (hasEmptyCells) {
      gameStatus = GameStatus.solvable;
    } else {
      gameStatus = GameStatus.solved;
    }
    return Game._(gameStatus, cells, invalidCells);
  }

  void copyToControllers(List<TextEditingController> controllers) {
    for (var entry in controllers.asMap().entries) {
      entry.value.text = '${cells[entry.key]}';
    }
  }

  Move nextMove() {
    var map = List.generate(dimension, (index) => <int>[]);
    var zeroCellIndexes = <int>[];
    for (var entry in cells.asMap().entries) {
      var i = entry.key ~/ dimension;
      if (entry.value == 0) {
        zeroCellIndexes.add(entry.key);
      }
      map[i].add(entry.value);
    }
    if (zeroCellIndexes.isNotEmpty && solve(map)) {
      var rand = Random();
      var zeroCellIdx = zeroCellIndexes[rand.nextInt(zeroCellIndexes.length)];
      var i = zeroCellIdx ~/ dimension;
      var j = zeroCellIdx % dimension;
      var value = map[i][j];
      return Move(i, j, value);
    }
    return null;
  }

  static List<int> _demoCells() {
    var l = <int>[];
    for (var i = 0; i < dimension; i++) {
      for (var j = 0; j < dimension; j++) {
        l.add(1 + (i + j) % dimension);
      }
    }
    return List.unmodifiable(l);
  }

  static List<int> _newGameCells() {
    var diagonal = randomizeDiagonal(dimension);
    var l = <int>[];
    for (var i = 0; i < dimension; i++) {
      for (var j = 0; j < dimension; j++) {
        l.add(i == j ? diagonal[i] : 0);
      }
    }
    return List.unmodifiable(l);
  }
}
