import 'package:flutter/material.dart';

@immutable
abstract class Skin extends StatelessWidget {
  final TextEditingController controller;
  final ValueSetter<int> onChanged;
  final bool readOnly;

  const Skin({
    Key key,
    @required this.controller,
    @required this.onChanged,
    @required this.readOnly,
  }) : super(key: key);
}
