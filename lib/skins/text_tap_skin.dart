import 'package:flutter/material.dart';
import 'skin.dart';

/// Text tap skin for the game board
class TextTapSkin extends Skin {
  final List<String> values;

  const TextTapSkin({
    Key key,
    TextEditingController controller,
    VoidCallback onChanged,
    bool readOnly,
    @required this.values,
  }) : super(
          key: key,
          controller: controller,
          onChanged: onChanged,
          readOnly: readOnly,
        );

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: readOnly ? null : _onTap,
        child: Container(
          padding: EdgeInsets.all(12),
          child: AnimatedBuilder(
            animation: controller,
            builder: (_, __) => Text(
              values[int.parse(controller.text)],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        ),
      );

  void _onTap() {
    var oldValue = int.parse(controller.text);
    var newValue = (oldValue + 1) % (values.length);
    controller.text = newValue.toString();
    onChanged();
  }
}
