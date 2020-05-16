import 'package:flutter/material.dart';
import '../logic/state.dart';
import '../translations/localizations.dart';

@immutable
class Message extends StatelessWidget {
  final Game gameState;

  const Message({Key key, this.gameState}) : super(key: key);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.center,
        child: _buildMessage(context, AppLocalizations.of(context)),
      );

  Widget _buildMessage(BuildContext context, AppLocalizations _) => Text(
        gameState.status != GameStatus.initialDemo
            ? (gameState.status != GameStatus.invalid
                ? (gameState.status == GameStatus.solved
                    ? _.solvedText
                    : _.validNotSolvedText)
                : _.invalidText)
            : _.beginText,
        style: Theme.of(context).textTheme.headline4,
        key: Key('status_message'),
      );
}
