import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'en.dart';
import 'ru.dart';

Iterable<LocalizationsDelegate<dynamic>> _localizationsDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  const AppLocalizationsDelegate(),
];
List<Locale> _supportedLocales = [
  const Locale('en'),
  const Locale('ru'),
];

class AppLocalizationsWrapper extends StatefulWidget {
  final Widget Function({
    Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates,
    Iterable<Locale> supportedLocales,
    Locale locale,
    ValueSetter<Locale> setLocale,
  }) builder;

  const AppLocalizationsWrapper({Key key, this.builder}) : super(key: key);

  @override
  _AppLocalizationsWrapperState createState() {
    return _AppLocalizationsWrapperState();
  }
}

class _AppLocalizationsWrapperState extends State<AppLocalizationsWrapper> {
  Locale _locale;

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        localizationsDelegates: _localizationsDelegates,
        supportedLocales: _supportedLocales,
        locale: _locale,
        setLocale: _setLocale,
      );
}

@immutable
class AppLocalizationsWidgetWrapper extends StatelessWidget {
  final Widget child;
  final Locale locale;

  const AppLocalizationsWidgetWrapper({
    Key key,
    @required this.locale,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Localizations(
        delegates: _localizationsDelegates,
        locale: locale,
        child: child,
      );
}

class AppLocalizations extends TranslationEn {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Locale localeOf(BuildContext context) {
    return Localizations.localeOf(context);
  }

  static Locale nextLocaleOf(BuildContext context) {
    var locale = Localizations.localeOf(context);
    var list = _supportedLocales;
    var nextLocale = list[(list.indexOf(locale) + 1) % list.length];
    return nextLocale;
  }

  final Map<String, TranslationEn> _localizedValues = {
    'en': TranslationEn(),
    'ru': TranslationRu(),
  };

  String get beginText => _localizedValues[locale.languageCode].beginText;
  String get solvedText => _localizedValues[locale.languageCode].solvedText;
  String get validNotSolvedText =>
      _localizedValues[locale.languageCode].validNotSolvedText;
  String get invalidText => _localizedValues[locale.languageCode].invalidText;

  @override
  TextDirection get textDirection =>
      _localizedValues[locale.languageCode].textDirection;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ru'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
