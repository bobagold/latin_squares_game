import 'dart:async';

import 'package:flutter/material.dart';
import '../logic/state.dart';
import '../translations/localizations.dart';
import '../widgets/board.dart';
import '../widgets/drawer.dart';
import '../widgets/message.dart';

class GameScreen extends StatefulWidget {
  final List<String> smileys;
  final ValueSetter<Locale> setLocale;
  final StreamController<String> requests;
  final StreamController<String> responses;

  GameScreen({
    Key key,
    this.smileys,
    this.setLocale,
    this.requests,
    this.responses,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final int _dimension = 5;
  AppLocalizations _;
  Game _gameState = Game.initialDemo();
  final List<TextEditingController> _controllers = [];
  List<String> _smileys;
  bool _useTextTapSkin = true;
  StreamSubscription<String> _subscription;

  @override
  void initState() {
    for (var k = _controllers.length; k < _dimension * _dimension; k++) {
      _controllers.add(TextEditingController());
    }
    _gameState.copyToControllers(_controllers);
    _smileys = widget.smileys;
    if (_smileys == null) {
      _smileys = List.generate(_dimension + 1, (i) => i.toString());
    }
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
        return widget.responses.sink.add(_gameState.diagonal.join(','));
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
    setState(() {
      _gameState = Game.newGame();
      _gameState.copyToControllers(_controllers);
    });
  }

  void _reset() {
    _useTextTapSkin = true;
    widget.setLocale(null);
    _gameState = Game.initialDemo();
    _gameState.copyToControllers(_controllers);
    setState(() {});
  }

  void _switchLang() {
    widget.setLocale(AppLocalizations.nextLocaleOf(context));
  }

  void _nextMove() {
    var nm = _gameState.nextMove();
    if (nm != null) {
      _controllers[nm.i * _dimension + nm.j].text = '${nm.value}';
      _onChanged(nm);
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
    return Scaffold(
      appBar: orientation == Orientation.portrait
          ? AppBar(
              title: Text(_.title),
            )
          : null,
      body: Builder(
        builder: (context) => _bodyBuilder(
          context,
          child: orientation == Orientation.portrait
              ? Column(
                  children: [
                    _buildTable(context),
                    Builder(builder: _buildMessageArea),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                )
              : Row(
                  children: [
                    _buildDrawer(context),
                    _buildTable(context),
                    SizedBox(),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
        ),
      ),
      bottomNavigationBar: orientation == Orientation.portrait
          ? _buildDrawer(context).buildBottomNavBar(context)
          : null,
    );
  }

  StaticDrawer _buildDrawer(BuildContext context) => StaticDrawer(
        key: Key('staticDrawer'),
        message: _buildMessageArea(context),
        gameState: _gameState,
        useTextTapSkin: _useTextTapSkin,
        clear: _clear,
        switchLang: _switchLang,
        switchSkin: _switchSkin,
        nextMove: _nextMove,
      );

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

  Widget _buildMessageArea(BuildContext context) => Message(
        key: Key('msg'),
        gameState: _gameState,
      );

  @override
  void dispose() {
    _subscription?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(Move m) {
    setState(() {
      _gameState = _gameState.move(m);
    });
  }

  Widget _buildTable(BuildContext context) => Board(
        key: Key('board'),
        dimension: _dimension,
        gameState: _gameState,
        controllers: _controllers,
        onChanged: _onChanged,
        smileys: _smileys,
        useTextTapSkin: _useTextTapSkin,
      );
}
