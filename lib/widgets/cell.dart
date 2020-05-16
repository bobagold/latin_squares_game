import 'package:flutter/material.dart';
import '../skins/text_input_skin.dart';
import '../skins/text_tap_skin.dart';

@immutable
class Cell extends StatelessWidget {
  final int i;
  final int j;
  final TextEditingController controller;
  final ValueSetter<int> onChanged;
  final BoxBorder border;
  final List<String> smileys;
  final bool useTextTapSkin;

  const Cell({
    @required Key key,
    @required this.i,
    @required this.j,
    @required this.controller,
    @required this.onChanged,
    @required this.border,
    @required this.smileys,
    @required this.useTextTapSkin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: border,
          color: i == j ? Colors.grey[200] : null,
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: _buildCell(context),
        ),
      );

  Widget _buildCell(BuildContext context) => useTextTapSkin
      ? TextTapSkin(
          key: Key('cell${i}x$j'),
          controller: controller,
          onChanged: onChanged,
          readOnly: i == j,
          values: smileys,
        )
      : TextInputSkin(
          key: Key('cell${i}x$j'),
          controller: controller,
          onChanged: onChanged,
          readOnly: i == j,
        );
}
