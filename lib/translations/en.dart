import 'package:flutter/material.dart';

@immutable
class TranslationEn {
  final String beginText = '''tap 🗑 to start
new game''';
  final String solvedText = 'you win!';
  final String validNotSolvedText = 'fill all cells';
  final String invalidText = 'there are duplicates';

  const TranslationEn();
}
