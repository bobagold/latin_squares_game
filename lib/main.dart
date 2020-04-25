import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int _dimension = 5;
  final double _cellWidth = 60;
  bool _valid = true;
  bool _solved = true;
  final List<TextEditingController> _controllers = [];

  void _clear() {
    var diagonal = randomizeDiagonal(_dimension);
    for (var entry in _controllers.asMap().entries) {
      var i = entry.key ~/ _dimension;
      var j = entry.key % _dimension;
      var value = i == j ? diagonal[j] : 0;
      entry.value.text = '$value';
    }
    _onChanged();
  }

  TextEditingValue _textInputFormatter(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var startIndex = oldValue.selection.baseOffset;
    return oldValue.copyWith(
        text: newValue.text.substring(startIndex, startIndex + 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Latin squares game'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: _cellWidth),
        child: Align(
          alignment: Alignment.topCenter,
          child: Builder(builder: _buildTable),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clear,
        tooltip: 'Clear',
        child: Icon(Icons.delete),
      ),
    );
  }

  Color get _validityColor =>
      _valid ? (_solved ? Colors.green : Colors.black) : Colors.red;

  Widget _buildTable(BuildContext context) => Table(
        border: TableBorder.all(color: _validityColor),
        defaultColumnWidth: FixedColumnWidth(_cellWidth),
        children: List.generate(
          _dimension,
          (i) => TableRow(
            children: List.generate(
              _dimension,
              (j) => _buildCell(context, i, j),
            ),
          ),
        ),
      );

  Widget _buildCell(BuildContext context, int i, int j) => TextFormField(
        readOnly: i == j,
        controller: _controller(i, j),
        onChanged: (t) => _onChanged(),
        inputFormatters: [TextInputFormatter.withFunction(_textInputFormatter)],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.display1,
      );

  TextEditingController _controller(int i, int j) {
    var idx = i * _dimension + j;
    for (var k = _controllers.length; k <= idx; k++) {
      var value = _initialValue(k ~/ _dimension, k % _dimension);
      _controllers.add(TextEditingController(text: value.toString()));
    }
    return _controllers[idx];
  }

  int _initialValue(int i, int j) => 1 + (i + j) % _dimension;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged() {
    var numbers =
        _controllers.map((controller) => int.parse(controller.text)).toList();
    var checks = validateLatinSquare(numbers, _dimension);
    setState(() {
      _valid = checks[0];
      _solved = checks[1];
    });
  }
}

/// validate latin square
List<bool> validateLatinSquare(List<int> numbers, int dimension) {
  var valid = true;
  var solved = true;
  for (var i = 0; i < dimension; i++) {
    var rowMap = <int, int>{};
    var colMap = <int, int>{};
    for (var j = 0; j < dimension; j++) {
      var rowValue = numbers[i * dimension + j];
      var allowedNumber = rowValue > 0 && rowValue <= dimension;
      if (!allowedNumber) {
        solved = false;
      }
      if (rowMap.containsKey(rowValue)) {
        solved = false;
        valid = false;
        break;
      }
      if (allowedNumber) {
        rowMap[rowValue] = j;
      }
      var colValue = numbers[j * dimension + i];
      if (colMap.containsKey(colValue)) {
        solved = false;
        valid = false;
        break;
      }
      if (colValue > 0 && colValue <= dimension) {
        colMap[colValue] = j;
      }
    }
  }
  return [valid, solved];
}

/// generate random diagonal for a latin square
List<int> randomizeDiagonal(int dimension) {
  var rand = Random();
  return List.generate(dimension, (i) => rand.nextInt(dimension) + 1);
}
