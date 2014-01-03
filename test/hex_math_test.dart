part of hive_console_test;

class TestHexMath {
  static void run() {
    group('check hex', () {
      var width = 10;
      var height = 40;
      var hexmap = new Hexmap(width, height, .25);
      group('even', () {
        var row = 2, col = 4;
        test('hit upper triangle', () {
          expect(checkHex(hexmap, new Coordinate(row, col), new Point(width * col + 5, .75 * height * row + 1)), isTrue);
        });
        test('hit mid box', () {
          expect(checkHex(hexmap, new Coordinate(row, col), new Point(width * col + 5, .75 * height * row + 15)), isTrue);
        });
        test('hit lower triangle', () {
          expect(checkHex(hexmap, new Coordinate(row, col), new Point(width * col + 5, .75 * height * row + 39)), isTrue);
        });
        test('miss up left', () {
          expect(checkHex(hexmap, new Coordinate(row, col), new Point(width * col, .75 * height * row + 1)), isFalse);
        });
        test('miss up right', () {
          expect(checkHex(hexmap, new Coordinate(row, col), new Point(width * (col + 1), .75 * height * row + 1)), isFalse);
        });
        test('miss down left', () {
          expect(checkHex(hexmap, new Coordinate(row, col), new Point(width * col, .75 * height * row + 39)), isFalse);
        });
        test('miss down right', () {
          expect(checkHex(hexmap, new Coordinate(row, col), new Point(width * col + 1, .75 * height * row + 39)), isFalse);
        });
      });

      group('odd', () {
        var row = 3, col = 4;
        var xOffset = .5 * width;
        test('hit upper triangle', () {
          expect(checkHex(hexmap, new Coordinate(row, col), new Point(xOffset + width * col + 5, .75 * height * row + 1)), isTrue);
        });
        test('hit mid box', () {
          expect(checkHex(hexmap, new Coordinate(row, col), new Point(xOffset + width * col + 5, .75 * height * row + 15)), isTrue);
        });
        test('hit lower triangle', () {
          expect(checkHex(hexmap, new Coordinate(row, col), new Point(xOffset + width * col + 5, .75 * height * row + 39)), isTrue);
        });
        test('miss up left', () {
          expect(checkHex(hexmap, new Coordinate(row, col), new Point(xOffset + width * col, .75 * height * row + 1)), isFalse);
        });
        test('miss up right', () {
          expect(checkHex(hexmap, new Coordinate(row, col), new Point(xOffset + width * (col + 1), .75 * height * row + 1)), isFalse);
        });
        test('miss down left', () {
          expect(checkHex(hexmap, new Coordinate(row, col), new Point(xOffset + width * col, .75 * height * row + 39)), isFalse);
        });
        test('miss down right', () {
          expect(checkHex(hexmap, new Coordinate(row, col), new Point(xOffset + width * col + 1, .75 * height * row + 39)), isFalse);
        });
      });
    });

    group('hex ring', () {
      test('radius 0', () {
        expect(hexRing(0), equals([ new Coordinate(0, 0) ]));
      });
      test('radius 1', () {
        var coordinates = [
          new Coordinate(0, 1),
          new Coordinate(-1, 0),
          new Coordinate(-1, -1),
          new Coordinate(0, -1),
          new Coordinate(1, -1),
          new Coordinate(1, 0)
        ];
        expect(hexRing(1), equals(coordinates));
      });
      test('radius 2', () {
        var coordinates = [
          new Coordinate(0, 2),
          new Coordinate(-1, 1),
          new Coordinate(-2, 1),
          new Coordinate(-2, 0),
          new Coordinate(-2, -1),
          new Coordinate(-1, -2),
          new Coordinate(0, -2),
          new Coordinate(1, -2),
          new Coordinate(2, -1),
          new Coordinate(2, 0),
          new Coordinate(2, 1),
          new Coordinate(1, 1)
        ];
        expect(hexRing(2), equals(coordinates));
      });
    });
  }
}
