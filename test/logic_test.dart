import 'package:latinsquaresgame/logic/logic.dart';
import 'package:test/test.dart';

void main() {
  group('Latin squares solver', () {
    test('Returns true for solved input', () {
      expect(
          solve([
            [1, 2, 3],
            [2, 3, 1],
            [3, 1, 2]
          ]),
          true);
    });
    test('Returns false for input with duplicates', () {
      expect(
          solve([
            [1, 1, 3],
            [2, 3, 1],
            [3, 1, 2]
          ]),
          false);
    });
    test('Detect simple case is solvable', () {
      expect(isUnsolvableDiagonal([1, 1, 1]), false);
    });
    test('Can solve some simple case', () {
      expect(solve(fromDiagonal([1, 1, 1])), true);
    });
    test('Writes solution to the input parameter', () {
      var map = fromDiagonal([1, 1, 1]);
      solve(map);
      expect(map[0][1], 2);
    });
    test('Detect 112 is unsolvable', () {
      expect(isUnsolvableDiagonal([1, 1, 2]), true);
    });
    test('Detect 25555 is unsolvable', () {
      expect(isUnsolvableDiagonal([2, 5, 5, 5, 5]), true);
    });
    test('Cannot solve 112', () {
      expect(solve(fromDiagonal([1, 1, 2])), false);
    });
    test('Can solve 1122', () {
      expect(solve(fromDiagonal([1, 1, 2, 2])), true);
    });
  });
}
