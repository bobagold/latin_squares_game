import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:latinsquaresgame/logic/logic.dart';
import 'package:test/test.dart';

void main() {
  group('Latin Squares Game App', () {
    FlutterDriver driver;

    var timeout = Duration(seconds: 2);

    var findAllCellsMessage = find.text('fill all cells');

    Future _startNewGame() =>
        driver.tap(find.byValueKey('New'), timeout: timeout);

    Future _waitForIt(SerializableFinder finder) =>
        driver.waitFor(finder, timeout: timeout);

    Future _enterNumber(int i, int j, num) async {
      await driver.tap(find.byValueKey('cell${i}x$j'), timeout: timeout);
      await driver.enterText('$num', timeout: timeout);
    }

    Future<void> _reset() => driver.requestData('reset', timeout: timeout);

    Future<List<int>> _getDiagonal() async {
      return (await driver.requestData('diagonal', timeout: timeout))
          .split(',')
          .map(int.parse)
          .toList();
    }

    Future _digits() async {
      await driver.tap(find.byValueKey('digits'), timeout: timeout);
      await driver.waitFor(find.byValueKey('smileys'), timeout: timeout);
    }

    Future _smileys() async {
      await driver.tap(find.byValueKey('smileys'), timeout: timeout);
      await driver.waitFor(find.byValueKey('digits'), timeout: timeout);
    }

    Future<void> _takeScreenshot(String path) async {
      var pixels = await driver.screenshot();
      var file = File(path);
      await file.writeAsBytes(pixels);
    }

    setUpAll(() async {
      driver = await FlutterDriver.connect();
      await Directory('screenshots').create();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    setUp(() async {
      await _reset();
    });

    test('starts at smiley skin', () async {
      await _takeScreenshot('screenshots/start.png');
    });

    test('starts new game', () async {
      await _startNewGame();
      await _takeScreenshot('screenshots/new_game.png');
    });

    test('makes one move', () async {
      await _startNewGame();
      await _digits();
      await _waitForIt(findAllCellsMessage);
      var diagonal = await _getDiagonal();
      var unique = (diagonal[0] + diagonal[1]) % (diagonal.length + 1);
      await _enterNumber(0, 1, unique);
      await _waitForIt(findAllCellsMessage);
      await _enterNumber(0, 1, diagonal[0]);
      await _waitForIt(find.text('there are duplicates'));
      await _smileys();
      await _takeScreenshot('screenshots/wrong_move.png');
      await _digits();
      await _enterNumber(0, 1, unique);
      await _waitForIt(findAllCellsMessage);
      await _takeScreenshot('screenshots/new_game_numbers.png');
      await _smileys();
      await _takeScreenshot('screenshots/move.png');
    });

    test('solves', () async {
      await _startNewGame();
      await _digits();
      var diagonal = await _getDiagonal();
      var map = fromDiagonal(diagonal);
      expect(solve(map), true);
      for (var i = 0; i < diagonal.length; i++) {
        for (var j = 0; j < diagonal.length; j++) {
          if (i != j) {
            await _enterNumber(i, j, map[i][j]);
          }
        }
      }
      await _takeScreenshot('screenshots/win_numbers.png');
      await _smileys();
      await _takeScreenshot('screenshots/win.png');
    });
  }, skip: Platform.environment['VM_SERVICE_URL'] == null);
}
