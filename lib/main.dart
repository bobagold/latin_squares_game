import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'logic/logic.dart';
import 'skins/text_input_skin.dart';
import 'skins/text_tap_skin.dart';
import 'translations/localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final List<String> _smileys = ['', '🧛‍♀️', '🧟‍♂️', '🤦🏻‍♀️', '🗿', '🙄'];
  final StreamController<String> requests;
  final StreamController<String> responses;

  MyApp({Key key, this.requests, this.responses}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      AppLocalizationsWrapper(builder: _builder);

  Widget _builder({
    localizationsDelegates,
    supportedLocales,
    locale,
    setLocale,
  }) =>
      MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        locale: locale,
        title: 'Latin squares game',
        theme: ThemeData(
          primarySwatch: Colors.yellow,
        ),
        home: GameScreen(
          values: _smileys,
          setLocale: setLocale,
          requests: requests,
          responses: responses,
        ),
      );
}

class GameScreen extends StatefulWidget {
  final List<String> values;
  final ValueSetter<Locale> setLocale;
  final StreamController<String> requests;
  final StreamController<String> responses;
  GameScreen({
    Key key,
    this.values,
    this.setLocale,
    this.requests,
    this.responses,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final int _dimension = 5;
  final double _cellWidth = 60;
  final double _cellHeight = 65;
  AppLocalizations _;
  bool _began = false;
  bool _valid = true;
  List<int> _invalidCells = [];
  bool _solved = true;
  final List<TextEditingController> _controllers = [];
  List<String> _values;
  bool _useTextTapSkin = true;
  List<int> _diagonal;
  StreamSubscription<String> _subscription;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _values = widget.values;
    if (_values == null) {
      _values = List.generate(_dimension + 1, (i) => i.toString());
    }
    _diagonal = List.generate(_dimension + 1, (i) => _initialValue(i, i));
    _subscribe();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _ = AppLocalizations.of(context);
    _subscribe();
    super.didChangeDependencies();
  }

  void _subscribe() {
    _subscription?.cancel();
    widget.requests?.stream?.listen((event) {
      if (event == 'diagonal'.toUpperCase()) {
        return widget.responses.sink.add(_diagonal.join(','));
      }
      if (event == 'is_smileys'.toUpperCase()) {
        return widget.responses.sink.add(_useTextTapSkin ? 'true' : 'false');
      }
      if (event == 'reset'.toUpperCase()) {
        _reset();
        return widget.responses.sink.add('ok');
      }
      widget.responses.sink.add('Hi, $event');
    });
  }

  void _clear() {
    var diagonal = randomizeDiagonal(_dimension);
    _diagonal = diagonal;
    for (var entry in _controllers.asMap().entries) {
      var i = entry.key ~/ _dimension;
      var j = entry.key % _dimension;
      var value = i == j ? diagonal[j] : 0;
      entry.value.text = '$value';
    }
    _onChanged();
  }

  void _reset() {
    _useTextTapSkin = true;
    widget.setLocale(null);
    for (var entry in _controllers.asMap().entries) {
      var i = entry.key ~/ _dimension;
      var j = entry.key % _dimension;
      var value = _initialValue(i, j);
      entry.value.text = '$value';
    }
    _began = false;
    _valid = true;
    _solved = true;
    _diagonal = List.generate(_dimension + 1, (i) => _initialValue(i, i));
    setState(() {});
  }

  void _switchLang() {
    widget.setLocale(AppLocalizations.nextLocaleOf(context));
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
      body: Builder(
        builder: (context) => _bodyBuilder(context, children: [
          Builder(builder: _buildTable),
          SizedBox(height: 30),
          Builder(builder: _buildMessageArea),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _tapBottomNav,
        items: [
          BottomNavigationBarItem(
            title: Text('New'),
            icon: Icon(Icons.delete),
          ),
          BottomNavigationBarItem(
            title: Text(AppLocalizations.nextLocaleOf(context).languageCode),
            icon: Icon(Icons.language),
          ),
          BottomNavigationBarItem(
            title: Text(_useTextTapSkin ? 'digits' : 'smileys'),
            icon: Icon(_useTextTapSkin ? Icons.looks_one : Icons.tag_faces),
          ),
        ],
      ),
    );
  }

  Widget _bodyBuilder(BuildContext context, {List<Widget> children}) =>
      GestureDetector(
        onTap: () => _unFocus(context),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: _cellWidth),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(children: children),
          ),
        ),
      );

  void _unFocus(BuildContext context) {
    var currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  Widget _buildMessageArea(BuildContext context) => Expanded(
        child: SingleChildScrollView(
          child: _buildMessage(context),
        ),
      );

  Widget _buildMessage(BuildContext context) => Text(
        _began
            ? (_valid
                ? (_solved ? _.solvedText : _.validNotSolvedText)
                : _.invalidText)
            : _.beginText,
        style: Theme.of(context).textTheme.headline4,
        key: Key('status_message'),
      );

  Color _validityCellBorderColor(int i, int j,
          {bool top = false, bool left = false}) =>
      _solved
          ? Colors.green
          : (!_isValidCell(i, j) ||
                  top && i > 0 && !_isValidCell(i - 1, j) ||
                  left && j > 0 && !_isValidCell(i, j - 1)
              ? Colors.red
              : Colors.black);

  bool _isValidCell(int i, int j) =>
      !_invalidCells.contains(i * _dimension + j);

  Border _cellBorder(int i, int j, {double width = 1}) => Border(
        top: BorderSide(
          color: _validityCellBorderColor(i, j, top: true),
          width: width,
        ),
        left: BorderSide(
          color: _validityCellBorderColor(i, j, left: true),
          width: width,
        ),
        bottom: i == _dimension - 1
            ? BorderSide(
                color: _validityCellBorderColor(i, j),
                width: width,
              )
            : BorderSide.none,
        right: j == _dimension - 1
            ? BorderSide(
                color: _validityCellBorderColor(i, j),
                width: width,
              )
            : BorderSide.none,
      );

  Widget _buildTable(BuildContext context) => Table(
        defaultColumnWidth: FixedColumnWidth(_cellWidth),
        children: List.generate(
          _dimension,
          (i) => TableRow(
            children: List.generate(
              _dimension,
              (j) => _buildCellWithBorder(context, i, j),
            ),
          ),
        ),
      );

  Widget _buildCellWithBorder(BuildContext context, int i, int j) => Container(
        height: _cellHeight,
        decoration: BoxDecoration(
          border: _cellBorder(i, j, width: 1),
        ),
        child: _buildCell(context, i, j),
      );

  Widget _buildCell(BuildContext context, int i, int j) => _useTextTapSkin
      ? TextTapSkin(
          key: Key('cell${i}x$j'),
          controller: _controller(i, j),
          onChanged: _onChanged,
          readOnly: i == j,
          values: _values,
        )
      : TextInputSkin(
          key: Key('cell${i}x$j'),
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
    _subscription?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged() {
    var numbers =
        _controllers.map((controller) => int.parse(controller.text)).toList();
    var checks = validateLatinSquareCells(numbers, _dimension);
    if (_valid != checks[0] || _solved != checks[1]) {
      setState(() {
        _began = true;
        _valid = checks[0].isEmpty;
        _solved = checks[0].isEmpty && checks[1].isEmpty;
        _invalidCells = checks[0];
      });
    }
  }
}
