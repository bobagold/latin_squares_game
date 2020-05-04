import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'skin.dart';

/// TextInput skin for the game board
@immutable
class TextInputSkin extends Skin {
  const TextInputSkin({
    Key key,
    TextEditingController controller,
    VoidCallback onChanged,
    bool readOnly,
  }) : super(
          key: key,
          controller: controller,
          onChanged: onChanged,
          readOnly: readOnly,
        );

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
