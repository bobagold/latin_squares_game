import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

enum GameState { initialDemo, newGame, invalid, unsolvable, solvable, solved }

class _GameScreenState extends State<GameScreen> {
  final int _dimension = 5;
  static const double _cellWidth = 60;
  AppLocalizations _;
  GameState _gameState = GameState.initialDemo;
  List<int> _invalidCells = [];
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
    _gameState = GameState.newGame;
    _diagonal = List.generate(_dimension + 1, (i) => _initialValue(i, i));
    setState(() {});
  }

  void _switchLang() {
    widget.setLocale(AppLocalizations.nextLocaleOf(context));
  }

  void _nextMove() {
    var map = List.generate(_dimension, (index) => <int>[]);
    var zeroCellIndexes = <int>[];
    for (var entry in _controllers.asMap().entries) {
      var i = entry.key ~/ _dimension;
      var cellValue = int.tryParse(entry.value.text);
      if (cellValue == 0) {
        zeroCellIndexes.add(entry.key);
      }
      map[i].add(cellValue);
    }
    if (zeroCellIndexes.isNotEmpty) {
      if (solve(map)) {
        var rand = Random();
        var zeroCellIdx = zeroCellIndexes[rand.nextInt(zeroCellIndexes.length)];
        var i = zeroCellIdx ~/ _dimension;
        var j = zeroCellIdx % _dimension;
        _controllers[zeroCellIdx].text = '${map[i][j]}';
        _onChanged();
      }
    }
  }

  void _switchSkin() {
    setState(() {
      _useTextTapSkin = !_useTextTapSkin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: _build);
  }

  Widget _build(BuildContext context, Orientation orientation) {
    var title = 'Latin squares game';
    return Scaffold(
      appBar: orientation == Orientation.portrait
          ? AppBar(
              title: Text(title),
            )
          : null,
      body: Builder(
        builder: (context) => _bodyBuilder(
          context,
          child: orientation == Orientation.portrait
              ? Column(
                  children: [
                    LayoutBuilder(builder: _buildTable),
                    Builder(builder: _buildMessageArea),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                )
              : Row(
                  children: [
                    _buildDrawer(context, title),
                    LayoutBuilder(builder: _buildTable),
                    SizedBox(),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
        ),
      ),
      bottomNavigationBar: orientation == Orientation.portrait
          ? _buildBottomNavBar(context)
          : null,
    );
  }

  Widget _buildDrawer(BuildContext context, String title) {
    return Container(
      width: 300,
      child: ListView(
        children: [
          PhysicalModel(
            elevation: 3,
            color: Theme.of(context).accentColor,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
          ),
          ..._navItems(
              context,
              (title, icon, onTap) => ListTile(
                    key: Key(title),
                    title: Text(title),
                    leading: icon,
                    onTap: onTap,
                  )),
          Builder(builder: _buildMessageArea),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) => BottomAppBar(
        child: Row(
          children: _navItems(
              context,
              (title, icon, onTap) => Expanded(
                      child: IconButton(
                    key: Key(title),
                    tooltip: title,
                    icon: icon,
                    onPressed: onTap,
                  ))),
        ),
      );

  List<Widget> _navItems(
          BuildContext context,
          Widget Function(String title, Widget icon, VoidCallback onTap)
              builder) =>
      [
        ['New', Icon(Icons.delete), _clear],
        ['Help', FaIcon(FontAwesomeIcons.magic), _nextMove],
        [
          AppLocalizations.nextLocaleOf(context).languageCode,
          Icon(Icons.language),
          _switchLang
        ],
        [
          _useTextTapSkin ? 'digits' : 'smileys',
          Icon(_useTextTapSkin ? Icons.looks_one : Icons.tag_faces),
          _switchSkin
        ],
      ]
          .map((arr) => builder(
                arr[0],
                arr[1],
                arr[2],
              ))
          .toList();

  Widget _bodyBuilder(BuildContext context, {Widget child}) => GestureDetector(
        onTap: () => _unFocus(context),
        child: child,
      );

  void _unFocus(BuildContext context) {
    var currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  Widget _buildMessageArea(BuildContext context) => Align(
        alignment: Alignment.center,
        child: _buildMessage(context),
      );

  Widget _buildMessage(BuildContext context) => Text(
        _gameState != GameState.initialDemo
            ? (_gameState != GameState.invalid
                ? (_gameState == GameState.solved
                    ? _.solvedText
                    : _.validNotSolvedText)
                : _.invalidText)
            : _.beginText,
        style: Theme.of(context).textTheme.headline4,
        key: Key('status_message'),
      );

  Color _validityCellBorderColor(int i, int j,
          {bool top = false, bool left = false}) =>
      _gameState == GameState.solved
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

  Widget _buildTable(BuildContext context, BoxConstraints constraints) => Table(
        defaultColumnWidth: constraints.maxWidth.isFinite
            ? MinColumnWidth(
                const FixedColumnWidth(_cellWidth),
                FractionColumnWidth(0.95 / _dimension),
              )
            : FixedColumnWidth(
                min(0.95 * constraints.maxHeight / _dimension, _cellWidth)),
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
        decoration: BoxDecoration(
          border: _cellBorder(i, j, width: 0),
          color: i == j ? Colors.grey[200] : null,
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: _buildCell(context, i, j),
        ),
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
    var gameState;
    if (checks[0].isNotEmpty) {
      gameState = GameState.invalid;
    } else if (checks[1].isNotEmpty) {
      gameState = GameState.solvable;
    } else {
      gameState = GameState.solved;
    }
    if (_gameState != gameState || _invalidCells != checks[0]) {
      setState(() {
        _gameState = gameState;
        _invalidCells = checks[0];
      });
    }
  }
}
