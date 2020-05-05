import 'dart:math';

/// validate latin square
List<bool> validateLatinSquare(List<int> numbers, int dimension) {
  var valid = true;
  var solved = true;
  for (var i = 0; i < dimension; i++) {
    var rowMap = <int, int>{};
    var colMap = <int, int>{};
    for (var j = 0; j < dimension; j++) {
      var rowValue = numbers[i * dimension + j];
      var allowedNumber = rowValue > 0 && rowValue <= dimension;
      if (!allowedNumber) {
        solved = false;
      }
      if (rowMap.containsKey(rowValue)) {
        solved = false;
        valid = false;
        break;
      }
      if (allowedNumber) {
        rowMap[rowValue] = j;
      }
      var colValue = numbers[j * dimension + i];
      if (colMap.containsKey(colValue)) {
        solved = false;
        valid = false;
        break;
      }
      if (colValue > 0 && colValue <= dimension) {
        colMap[colValue] = j;
      }
    }
  }
  return [valid, solved];
}

/// detects unsolvable diagonals (112 or such)
bool isUnsolvableDiagonal(List<int> diagonal) {
  var unique = Set.of(diagonal);
  var first = unique.first;
  var cnt = diagonal.reduce((memo, el) => memo + (el == first ? 1 : 0));
  return unique.length == 2 && (cnt == 1 || cnt == diagonal.length - 1);
}

/// generate random diagonal for a latin square
List<int> randomizeDiagonal(int dimension, {bool onlyValid = true}) {
  if (onlyValid) {
    var diagonal;
    do {
      diagonal = randomizeDiagonal(dimension, onlyValid: false);
    } while (isUnsolvableDiagonal(diagonal));
    return diagonal;
  }
  var rand = Random();
  return List.generate(dimension, (i) => rand.nextInt(dimension) + 1);
}

/// convert 2-dimensional array to a plain one
List<int> toOneLiner(List<List<int>> map) {
  var oneLiner = <int>[];
  for (var row in map) {
    oneLiner.addAll(row);
  }
  return oneLiner;
}

/// create new game board with given diagonal
List<List<int>> fromDiagonal(List<int> diagonal) {
  return List.generate(diagonal.length,
      (i) => List.generate(diagonal.length, (j) => (i == j ? diagonal[i] : 0)));
}

/// solve the game or tell that it cannot be solved
bool solve(List<List<int>> map) {
  var dimension = map.length;
  var validation = validateLatinSquare(toOneLiner(map), dimension);
  if (!validation[0]) {
    return false;
  }
  if (validation[1]) {
    return true;
  }
  for (var i = 0; i < dimension; i++) {
    for (var j = 0; j < dimension; j++) {
      if (map[i][j] == 0) {
        for (var n = 1; n <= dimension; n++) {
          map[i][j] = n;
          if (solve(map)) {
            return true;
          }
        }
        map[i][j] = 0;
        return false;
      }
    }
  }
  return false;
}
