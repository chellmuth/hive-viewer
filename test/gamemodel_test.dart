part of hive_console_test;

class TestGameModel {
  static void run() {
    test('Player equality', () {
      expect(Player.WHITE, equals(Player.WHITE));
      expect(Player.WHITE, isNot(equals(Player.BLACK)));
    });

    test('Bug equality', () {
      expect(Bug.ANT, equals(Bug.ANT));
      expect(Bug.ANT, isNot(equals(Bug.QUEEN)));
    });

    test('Direction equality', () {
      expect(Direction.LEFT, equals(Direction.LEFT));
      expect(Direction.LEFT, isNot(equals(Direction.RIGHT)));
    });

    test('Piece equality', () {
      expect(new Piece(Player.WHITE, Bug.ANT, 1), equals(new Piece(Player.WHITE, Bug.ANT, 1)));

      expect(new Piece(Player.WHITE, Bug.ANT, 1), isNot(equals(new Piece(Player.BLACK, Bug.ANT, 1))));
      expect(new Piece(Player.WHITE, Bug.ANT, 1), isNot(equals(new Piece(Player.WHITE, Bug.QUEEN, 1))));
      expect(new Piece(Player.WHITE, Bug.ANT, 1), isNot(equals(new Piece(Player.WHITE, Bug.ANT, 0))));
    });

    test('Piece hashCode', () {
      expect(new Piece(Player.WHITE, Bug.ANT, 1).hashCode, equals(new Piece(Player.WHITE, Bug.ANT, 1).hashCode));

      expect(new Piece(Player.WHITE, Bug.ANT, 1).hashCode, isNot(equals(new Piece(Player.BLACK, Bug.ANT, 1).hashCode)));
      expect(new Piece(Player.WHITE, Bug.ANT, 1).hashCode, isNot(equals(new Piece(Player.WHITE, Bug.QUEEN, 1).hashCode)));
      expect(new Piece(Player.WHITE, Bug.ANT, 1).hashCode, isNot(equals(new Piece(Player.WHITE, Bug.ANT, 0).hashCode)));
    });

    group('Coordinate', _coordinate);
  }

  static void _coordinate() {
    test('equality', () {
      expect(new Coordinate(20, 100), equals(new Coordinate(20, 100)));
      expect(new Coordinate(20, 100), isNot(equals(new Coordinate(20, 20))));
      expect(new Coordinate(20, 100), isNot(equals(new Coordinate(100, 100))));
    });

    test('direction', () {
      expect(new Coordinate(10, 12).direction(new Coordinate(9, 12)), equals(Direction.UP_RIGHT));
      expect(new Coordinate(9, 12).direction(new Coordinate(8, 12)), equals(Direction.UP_LEFT));
    });

    test('adjacent even row', () {
      Coordinate c = new Coordinate(2, 6);
      var adjacentCoordinates = [
        new Coordinate(2, 5), // start left, move clockwise
        new Coordinate(1, 5),
        new Coordinate(1, 6),
        new Coordinate(2, 7),
        new Coordinate(3, 5),
        new Coordinate(3, 6)
      ];
      for (var adjacentCoordinate in adjacentCoordinates) {
        expect(c.isAdjacent(adjacentCoordinate), isTrue);
      }

      var nonAdjacentCoordinates = [
        new Coordinate(2, 6),
        new Coordinate(2, 4),
        new Coordinate(2, 8),
        new Coordinate(1, 4),
        new Coordinate(1, 7),
        new Coordinate(3, 4),
        new Coordinate(3, 7)
      ];
      for (var nonAdjacentCoordinate in nonAdjacentCoordinates) {
        expect(c.isAdjacent(nonAdjacentCoordinate), isNot(isTrue));
      }
    });

    test('adjacent odd row', () {
      Coordinate c = new Coordinate(3, 6);
      var adjacentCoordinates = [
        new Coordinate(3, 5), // start left, move clockwise
        new Coordinate(2, 6),
        new Coordinate(2, 7),
        new Coordinate(3, 7),
        new Coordinate(4, 6),
        new Coordinate(4, 7)
      ];
      for (var adjacentCoordinate in adjacentCoordinates) {
        expect(c.isAdjacent(adjacentCoordinate), isTrue);
      }

      var nonAdjacentCoordinates = [
        new Coordinate(3, 6),
        new Coordinate(3, 4),
        new Coordinate(3, 8),
        new Coordinate(2, 5),
        new Coordinate(2, 8),
        new Coordinate(4, 5),
        new Coordinate(4, 8)
      ];
      for (var nonAdjacentCoordinate in nonAdjacentCoordinates) {
        expect(c.isAdjacent(nonAdjacentCoordinate), isNot(isTrue));
      }
    });
  }
}
