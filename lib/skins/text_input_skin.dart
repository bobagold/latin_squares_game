import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// TextInput skin for the game board
@immutable
class TextInputSkin extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  final bool readOnly;

  const TextInputSkin({
    Key key,
    @required this.controller,
    @required this.onChanged,
    @required this.readOnly,
  }) : super(key: key);

  TextEditingValue _textInputFormatter(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var startIndex = oldValue.selection.baseOffset;
    return oldValue.copyWith(
        text: newValue.text.substring(startIndex, startIndex + 1));
  }

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        readOnly: readOnly,
        onChanged: (t) => onChanged(),
        inputFormatters: [TextInputFormatter.withFunction(_textInputFormatter)],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.display1,
      );
}
