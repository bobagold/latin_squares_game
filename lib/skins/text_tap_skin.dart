import 'package:flutter/material.dart';

/// Text tap skin for the game board
class TextTapSkin extends StatefulWidget {
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
  State<StatefulWidget> createState() {
    return _TextTapSkinState();
  }
}

class _TextTapSkinState extends State<TextTapSkin> {
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: widget.readOnly ? null : _onTap,
        child: Container(
          padding: EdgeInsets.all(12),
          child: Text(
            widget.values[int.parse(widget.controller.text)],
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.display1,
          ),
        ),
      );

  void _onTap() {
    var oldValue = int.parse(widget.controller.text);
    var newValue = (oldValue + 1) % (widget.values.length);
    widget.controller.text = newValue.toString();
    widget.onChanged();
    setState(() {});
  }
}
