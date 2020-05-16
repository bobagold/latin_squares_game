import 'package:flutter/material.dart';

import 'en.dart';

@immutable
class TranslationRu extends TranslationEn {
  final String beginText = '''нажми 🗑 чтобы
начать новую игру''';
  final String solvedText = 'молодец!';
  final String validNotSolvedText = 'заполни все клетки';
  final String invalidText = 'есть повторения';
  final String title = 'Латинские квадраты';

  const TranslationRu();
}
