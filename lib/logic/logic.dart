import 'dart:math';

/// validate latin square
List<bool> validateLatinSquare(List<int> numbers, int dimension) {
  var lists = validateLatinSquareCells(numbers, dimension);
  var invalidCells = lists[0];
  var emptyCells = lists[1];
  return [invalidCells.isEmpty, invalidCells.isEmpty && emptyCells.isEmpty];
}

/// validate latin square cells, very slow
/// todo fast implementation
List<List<int>> validateLatinSquareCells(List<int> numbers, int dimension) {
  var invalidCells = <int>[];
  var emptyCells = <int>[];
  for (var i = 0; i < dimension; i++) {
    var rowMap = <int, int>{};
    var colMap = <int, int>{};
    for (var j = 0; j < dimension; j++) {
      var rowValue = numbers[i * dimension + j];
      var allowedNumber = rowValue > 0 && rowValue <= dimension;
      if (!allowedNumber) {
        emptyCells.add(i * dimension + j);
      }
      if (rowMap.containsKey(rowValue)) {
        invalidCells.add(rowMap[rowValue]);
        invalidCells.add(i * dimension + j);
//        break;
      }
      if (allowedNumber) {
        rowMap[rowValue] = i * dimension + j;
      }
      var colValue = numbers[j * dimension + i];
      if (colMap.containsKey(colValue)) {
        invalidCells.add(colMap[colValue]);
        invalidCells.add(j * dimension + i);
//        break;
      }
      if (colValue > 0 && colValue <= dimension) {
        colMap[colValue] = j * dimension + i;
      }
    }
  }
  return [invalidCells, emptyCells];
}

/// detects unsolvable diagonals (112 or such)
bool isUnsolvableDiagonal(List<int> diagonal) {
  var unique = Set.of(diagonal);
  var first = unique.first;
  var cnt = diagonal.fold(0, (memo, el) => memo + (el == first ? 1 : 0));
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
