import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../logic/state.dart';
import '../translations/localizations.dart';

@immutable
class StaticDrawer extends StatelessWidget {
  final Widget message;
  final Game gameState;
  final bool useTextTapSkin;
  final VoidCallback clear;
  final VoidCallback switchLang;
  final VoidCallback nextMove;
  final VoidCallback switchSkin;

  const StaticDrawer({
    @required Key key,
    @required this.message,
    @required this.gameState,
    @required this.useTextTapSkin,
    @required this.clear,
    @required this.switchLang,
    @required this.nextMove,
    @required this.switchSkin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                AppLocalizations.of(context).title,
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
                    enabled: onTap != null,
                    onTap: onTap,
                  )),
          message,
        ],
      ),
    );
  }

  List<Widget> _navItems(
          BuildContext context,
          Widget Function(String title, Widget icon, VoidCallback onTap)
              builder) =>
      [
        ['New', Icon(Icons.delete), clear],
        [
          'Help',
          FaIcon(FontAwesomeIcons.magic),
          gameState.status == GameStatus.solvable ? nextMove : null
        ],
        [
          AppLocalizations.nextLocaleOf(context).languageCode,
          Icon(Icons.language),
          switchLang
        ],
        [
          useTextTapSkin ? 'digits' : 'smileys',
          Icon(useTextTapSkin ? Icons.looks_one : Icons.tag_faces),
          switchSkin
        ],
      ]
          .map((arr) => builder(
                arr[0],
                arr[1],
                arr[2],
              ))
          .toList();

  Widget buildBottomNavBar(BuildContext context) => BottomAppBar(
        key: Key('bottomAppBar'),
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
}
