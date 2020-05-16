import 'dart:math';

import 'package:flutter/material.dart';
import '../logic/state.dart';
import 'cell.dart';

@immutable
class Board extends StatelessWidget {
  static const double _cellWidth = 60;
  final int dimension;
  final Game gameState;
  final List<TextEditingController> controllers;
  final ValueSetter<Move> onChanged;
  final List<String> smileys;
  final bool useTextTapSkin;

  const Board({
    @required Key key,
    @required this.dimension,
    @required this.gameState,
    @required this.controllers,
    @required this.onChanged,
    @required this.smileys,
    @required this.useTextTapSkin,
  }) : super(key: key);

  Color _validityCellBorderColor(int i, int j,
          {bool top = false, bool left = false}) =>
      gameState.status == GameStatus.solved
          ? Colors.green
          : (!_isValidCell(i, j) ||
                  top && i > 0 && !_isValidCell(i - 1, j) ||
                  left && j > 0 && !_isValidCell(i, j - 1)
              ? Colors.red
              : Colors.black);

  bool _isValidCell(int i, int j) =>
      !gameState.invalidCells.contains(i * dimension + j);

  Border _cellBorder(int i, int j, {double width = 1}) => Border(
        top: BorderSide(
          color: _validityCellBorderColor(i, j, top: true),
          width: width,
        ),
        left: BorderSide(
          color: _validityCellBorderColor(i, j, left: true),
          width: width,
        ),
        bottom: i == dimension - 1
            ? BorderSide(
                color: _validityCellBorderColor(i, j),
                width: width,
              )
            : BorderSide.none,
        right: j == dimension - 1
            ? BorderSide(
                color: _validityCellBorderColor(i, j),
                width: width,
              )
            : BorderSide.none,
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: _buildTable);

  Widget _buildTable(BuildContext context, BoxConstraints constraints) => Table(
        defaultColumnWidth: constraints.maxWidth.isFinite
            ? MinColumnWidth(
                const FixedColumnWidth(_cellWidth),
                FractionColumnWidth(0.95 / dimension),
              )
            : FixedColumnWidth(
                min(0.95 * constraints.maxHeight / dimension, _cellWidth)),
        children: List.generate(
          dimension,
          (i) => TableRow(
            children: List.generate(
              dimension,
              (j) => _buildCellWithBorder(context, i, j),
            ),
          ),
        ),
      );

  TextEditingController _controller(int i, int j) {
    var idx = i * dimension + j;
    return controllers[idx];
  }

  Widget _buildCellWithBorder(BuildContext context, int i, int j) => Cell(
        key: Key('cell$i/$j'),
        i: i,
        j: j,
        controller: _controller(i, j),
        onChanged: (value) => onChanged(Move(i, j, value)),
        border: _cellBorder(i, j, width: 0),
        smileys: smileys,
        useTextTapSkin: useTextTapSkin,
      );
}
