import 'package:flutter/material.dart';

/// Text tap skin for the game board
class TextTapSkin extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  final bool readOnly;
  final List<String> values;

  const TextTapSkin({
    Key key,
    @required this.controller,
    @required this.onChanged,
    @required this.readOnly,
    @required this.values,
  }) : super(key: key);

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
              style: Theme.of(context).textTheme.display1,
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
