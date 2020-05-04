import 'dart:math';

import 'package:flutter/material.dart';
import 'skins/text_input_skin.dart';
import 'skins/text_tap_skin.dart';
import 'translations/en.dart';
import 'translations/ru.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final List<String> _smileys = ['', '🧛‍♀️', '🧟‍♂️', '🤦🏻‍♀️', '🗿', '🙄'];
  final TranslationEn _translations = TranslationRu();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Latin squares game',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: GameScreen(
        values: _smileys,
        translations: _translations,
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final List<String> values;
  final TranslationEn translations;
  GameScreen({Key key, this.values, this.translations}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final int _dimension = 5;
  final double _cellWidth = 60;
  TranslationEn _;
  bool _began = false;
  bool _valid = true;
  bool _solved = true;
  final List<TextEditingController> _controllers = [];
  List<String> _values;
  bool _useTextTapSkin = true;

  @override
  void initState() {
    _ = widget.translations ?? TranslationEn();
    _values = widget.values;
    if (_values == null) {
      _values = List.generate(_dimension + 1, (i) => i.toString());
    }
    super.initState();
  }

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

  void _switchLang() {
    setState(() {
      _ = _ is TranslationRu ? TranslationEn() : TranslationRu();
    });
  }

  void _switchSkin() {
    setState(() {
      _useTextTapSkin = !_useTextTapSkin;
    });
  }

  void _tapBottomNav(int idx) {
    if (idx == 0) {
      return _clear();
    }
    if (idx == 1) {
      return _switchLang();
    }
    return _switchSkin();
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
          child: Column(children: [
            Builder(builder: _buildTable),
            SizedBox(height: 0),
            Builder(builder: _buildMessage),
          ]),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _tapBottomNav,
        items: [
          BottomNavigationBarItem(
            title: Text('New'),
            icon: Icon(Icons.delete),
          ),
          BottomNavigationBarItem(
            title: Text('Language'),
            icon: Icon(Icons.language),
          ),
          BottomNavigationBarItem(
            title: Text('Skin'),
            icon: Icon(_useTextTapSkin ? Icons.looks_one : Icons.tag_faces),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(BuildContext context) => Text(
        _began
            ? (_valid
                ? (_solved ? _.solvedText : _.validNotSolvedText)
                : _.invalidText)
            : _.beginText,
        style: Theme.of(context).textTheme.display1,
      );

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

  Widget _buildCell(BuildContext context, int i, int j) => _useTextTapSkin
      ? TextTapSkin(
          controller: _controller(i, j),
          onChanged: _onChanged,
          readOnly: i == j,
          values: _values,
        )
      : TextInputSkin(
          controller: _controller(i, j),
          onChanged: _onChanged,
          readOnly: i == j,
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
    if (_valid != checks[0] || _solved != checks[1]) {
      setState(() {
        _began = true;
        _valid = checks[0];
        _solved = checks[1];
      });
    }
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
