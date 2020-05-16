import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/game.dart';
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
          smileys: _smileys,
          setLocale: setLocale,
          requests: requests,
          responses: responses,
        ),
      );
}
